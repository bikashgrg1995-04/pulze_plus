import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/donors/data/donor_repository.dart';

import 'package:pulze_plus/features/donors/models/external_donor_model.dart';
import 'package:pulze_plus/features/donors/providers/donor_provider.dart';

class ExternalDonorNotifier
    extends AsyncNotifier<List<ExternalDonorModel>> {
  late final DonorRepository _donorRepository;

  String? _search;
  String? _bloodType;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;

  @override
  Future<List<ExternalDonorModel>> build() async {
    _donorRepository = ref.read(donorRepositoryProvider);

    _resetPagination();

    final page = await _donorRepository.getExternalDonors(
      page: _currentPage,
      search: _search,
      bloodType: _bloodType,
    );

    _hasMore = page.hasNext;

    return page.results;
  }

  Future<List<ExternalDonorModel>> _loadFirstPage() async {
    _currentPage = 1;

    final page = await _donorRepository.getExternalDonors(
      page: _currentPage,
      search: _search,
      bloodType: _bloodType,
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

      final page = await _donorRepository.getExternalDonors(
        page: nextPage,
        search: _search,
        bloodType: _bloodType,
      );

      _currentPage = nextPage;
      _hasMore = page.hasNext;

      state = AsyncData([
        ...currentDonors,
        ...page.results,
      ]);
    } catch (_) {
      state = AsyncData(currentDonors);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> searchDonors(String? search) async {
    _search = search?.trim();

    await _reloadFromFirstPage();
  }

  Future<void> filterByBloodType(String? bloodType) async {
    _bloodType = bloodType;

    await _reloadFromFirstPage();
  }

  Future<void> refreshDonors() async {
    state = const AsyncLoading();

    try {
      final donors = await _loadFirstPage();

      state = AsyncData(donors);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _reloadFromFirstPage() async {
    _isRefreshing = true;

    try {
      final donors = await _loadFirstPage();

      state = AsyncData(donors);
    } catch (error, stackTrace) {
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

    _resetPagination();
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
}

final externalDonorProvider =
    AsyncNotifierProvider<ExternalDonorNotifier,
        List<ExternalDonorModel>>(
  ExternalDonorNotifier.new,
);