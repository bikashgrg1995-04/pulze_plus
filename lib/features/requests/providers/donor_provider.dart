
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:pulze_plus/core/location/location_providers.dart';
import 'package:pulze_plus/core/location/location_service.dart';
import 'package:pulze_plus/core/network/network_providers.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/features/requests/data/donor_repository.dart';

import '../models/donor_model.dart';

class DonorNotifier extends AsyncNotifier<List<DonorModel>> {
  late final DonorRepository _donorRepository;
  late final LocationService _locationService;

  String? _search;
  String? _bloodType;

  double? _latitude;
  double? _longitude;
  double _radius = 50;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  @override
  Future<List<DonorModel>> build() async {
    _donorRepository = ref.read(donorRepositoryProvider);
    _locationService = ref.read(locationServiceProvider);

    _resetPagination();

    await _loadInitialLocation();

    final page = await _donorRepository.getDonors(
      page: _currentPage,
      search: _search,
      bloodType: _bloodType,
      latitude: _latitude,
      longitude: _longitude,
      radius: _radius,
    );

    _hasMore = page.hasNext;

    return page.results;
  }

  Future<void> _loadInitialLocation() async {
    final preferences = ref.read(appPreferencesProvider);

    // Location is disabled at the app level.
    if (!preferences.locationEnabled) {
      _clearLocationCoordinates();
      return;
    }

    try {
      final serviceEnabled =
          await _locationService.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _clearLocationCoordinates();
        return;
      }

      final permission = await _locationService.checkPermission();

      final hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!hasPermission) {
        _clearLocationCoordinates();
        return;
      }

      final position = await _locationService.getCurrentPosition();

      _latitude = position.latitude;
      _longitude = position.longitude;
    } catch (_) {
      // Location should never prevent the donor list from loading.
      _clearLocationCoordinates();
    }
  }

  Future<List<DonorModel>> _loadFirstPage() async {
    _currentPage = 1;

    final page = await _donorRepository.getDonors(
      page: _currentPage,
      search: _search,
      bloodType: _bloodType,
      latitude: _latitude,
      longitude: _longitude,
      radius: _radius,
    );

    _hasMore = page.hasNext;

    return page.results;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    final currentDonors = state.asData?.value;

    if (currentDonors == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final nextPage = _currentPage + 1;

      final page = await _donorRepository.getDonors(
        page: nextPage,
        search: _search,
        bloodType: _bloodType,
        latitude: _latitude,
        longitude: _longitude,
        radius: _radius,
      );

      _currentPage = nextPage;
      _hasMore = page.hasNext;

      state = AsyncData([
        ...currentDonors,
        ...page.results,
      ]);
    } catch (_) {
      // Keep the already loaded donors visible.
      state = AsyncData(currentDonors);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> searchDonors(String? search) async {
    _search = search?.trim();

    await _reloadFromFirstPage();
  }

  Future<void> loadNearbyDonors({
    required double latitude,
    required double longitude,
    double radius = 50,
    String? bloodType,
    String? search,
  }) async {
    _latitude = latitude;
    _longitude = longitude;
    _radius = radius;
    _bloodType = bloodType;
    _search = search?.trim();

    await _reloadFromFirstPage();
  }

  Future<void> loadCurrentLocationDonors({
    double radius = 50,
    String? bloodType,
    String? search,
  }) async {
    _radius = radius;
    _bloodType = bloodType;
    _search = search?.trim();

    _isRefreshing = true;

    try {
      await _locationService.ensurePermission();

      final Position position =
          await _locationService.getCurrentPosition();

      _latitude = position.latitude;
      _longitude = position.longitude;

      final donors = await _loadFirstPage();

      state = AsyncData(donors);
    } catch (error, stackTrace) {
      // Keep the existing donor list visible if the refresh fails.
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> filterByBloodType(String? bloodType) async {
    _bloodType = bloodType;

    await _reloadFromFirstPage();
  }

  Future<void> filterByRadius(double radius) async {
    _radius = radius;

    await _reloadFromFirstPage();
  }

  Future<void> refreshDonors() async {
    state = const AsyncLoading();

    try {
      final preferences = ref.read(appPreferencesProvider);

      if (preferences.locationEnabled) {
        await _refreshCurrentLocation();
      } else {
        _clearLocationCoordinates();
      }

      final donors = await _loadFirstPage();

      state = AsyncData(donors);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _refreshCurrentLocation() async {
    try {
      final serviceEnabled =
          await _locationService.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _clearLocationCoordinates();
        return;
      }

      final permission = await _locationService.checkPermission();

      final hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!hasPermission) {
        _clearLocationCoordinates();
        return;
      }

      final position = await _locationService.getCurrentPosition();

      _latitude = position.latitude;
      _longitude = position.longitude;
    } catch (_) {
      _clearLocationCoordinates();
    }
  }

  Future<void> _reloadFromFirstPage() async {
    _isRefreshing = true;

    try {
      final donors = await _loadFirstPage();

      state = AsyncData(donors);
    } catch (error, stackTrace) {
      // Keep the existing donor list visible if the request fails.
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  void clearFilters() {
    _search = null;
    _bloodType = null;
    _radius = 50;

    _resetPagination();
  }

  void clearLocation() {
    _clearLocationCoordinates();
    _radius = 50;
  }

  void _clearLocationCoordinates() {
    _latitude = null;
    _longitude = null;
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
  }

  bool get hasMore => _hasMore;

  bool get isLoadingMore => _isLoadingMore;

  bool get isRefreshing => _isRefreshing;

  int get currentPage => _currentPage;

  String? get searchQuery => _search;

  String? get selectedBloodType => _bloodType;

  double get selectedRadius => _radius;

  double? get latitude => _latitude;

  double? get longitude => _longitude;
}

final donorRepositoryProvider = Provider<DonorRepository>((ref) {
  return DonorRepository(
    apiService: ref.read(apiServiceProvider),
  );
});

final donorProvider =
    AsyncNotifierProvider<DonorNotifier, List<DonorModel>>(
  DonorNotifier.new,
);
