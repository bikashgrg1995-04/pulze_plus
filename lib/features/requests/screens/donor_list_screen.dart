import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/location/location_providers.dart';

import '../../../core/location/location_service.dart';
import '../../../core/preferences/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/donor_model.dart';
import '../providers/donor_provider.dart';
import '../widgets/donor_list_item.dart';

class DonorListScreen extends ConsumerStatefulWidget {
  const DonorListScreen({super.key});

  @override
  ConsumerState<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends ConsumerState<DonorListScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final DonorNotifier _donorNotifier;

  Timer? _searchDebounce;

  String? _selectedBloodGroup;
  double? _selectedRadius;

  @override
  void initState() {
    super.initState();

    _donorNotifier = ref.read(donorProvider.notifier);

    _searchController = TextEditingController();
    _scrollController = ScrollController();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _donorNotifier.clearFilters();
    _donorNotifier.clearLocation();

    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<bool> _ensureLocationForNearbySearch() async {
    final preferences = ref.read(appPreferencesProvider);

    if (preferences.locationEnabled) {
      return true;
    }

    final locationService = ref.read(locationServiceProvider);

    try {
      final granted = await locationService.ensurePermission();

      if (!granted) {
        return false;
      }

      await ref.read(appPreferencesProvider.notifier).setLocationEnabled(true);

      return true;
    } on LocationServiceDisabledException {
      _showLocationMessage('Turn on location services to find nearby donors.');
    } on LocationPermissionDeniedException {
      _showLocationMessage(
        'Location permission is needed to find nearby donors.',
      );
    } on LocationPermissionPermanentlyDeniedException {
      _showLocationMessage(
        'Location permission is disabled. Please enable it in Settings.',
      );
    } catch (_) {
      _showLocationMessage('Unable to access your location right now.');
    }

    return false;
  }

  void _showLocationMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      if (!_donorNotifier.isLoadingMore && _donorNotifier.hasMore) {
        _donorNotifier.loadMore();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void _handleSearchChanged(String value) {
    setState(() {});

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }

      _donorNotifier.searchDonors(value);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {});

    _donorNotifier.searchDonors(null);
  }

  // ---------------------------------------------------------------------------
  // Blood Group
  // ---------------------------------------------------------------------------

  Future<void> _handleBloodGroupChanged(String? bloodGroup) async {
    if (_selectedRadius != null) {
      final locationReady = await _ensureLocationForNearbySearch();

      if (!locationReady) {
        return;
      }

      setState(() {
        _selectedBloodGroup = bloodGroup;
      });

      await _donorNotifier.loadCurrentLocationDonors(
        radius: _selectedRadius!,
        bloodType: bloodGroup,
        search: _searchController.text,
      );

      return;
    }

    setState(() {
      _selectedBloodGroup = bloodGroup;
    });

    await _donorNotifier.filterByBloodType(bloodGroup);
  }

  // ---------------------------------------------------------------------------
  // Radius
  // ---------------------------------------------------------------------------

  Future<void> _handleRadiusChanged(double radius) async {
    final locationReady = await _ensureLocationForNearbySearch();

    if (!locationReady) {
      return;
    }

    setState(() {
      _selectedRadius = radius;
    });

    await _donorNotifier.loadCurrentLocationDonors(
      radius: radius,
      bloodType: _selectedBloodGroup,
      search: _searchController.text,
    );
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> _handleRefresh() async {
    await _donorNotifier.refreshDonors();
  }

  // ---------------------------------------------------------------------------
  // Nearby
  // ---------------------------------------------------------------------------

  Future<void> _handleUseNearby() async {
    final locationReady = await _ensureLocationForNearbySearch();

    if (!locationReady) {
      return;
    }

    await _donorNotifier.loadCurrentLocationDonors(
      radius: _selectedRadius ?? 50,
      bloodType: _selectedBloodGroup,
      search: _searchController.text,
    );
  }

  // ---------------------------------------------------------------------------
  // Clear Filters
  // ---------------------------------------------------------------------------

  Future<void> _clearFilters() async {
    setState(() {
      _selectedBloodGroup = null;
      _selectedRadius = null;
    });

    _donorNotifier.clearFilters();
    _donorNotifier.clearLocation();

    await _donorNotifier.refreshDonors();
  }

  // ---------------------------------------------------------------------------
  // Donor actions
  // ---------------------------------------------------------------------------

  void _handleDonorTap(DonorModel donor) {
    // Donor detail flow can be connected later.
  }

  void _handleDonorRequest(DonorModel donor) {
    // Existing donor request flow can be connected later.
  }

  // ---------------------------------------------------------------------------
  // Search UI
  // ---------------------------------------------------------------------------

  Widget _buildSearchField() {
    final hasText = _searchController.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search city or address',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 20),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter Section
  // ---------------------------------------------------------------------------

  Widget _buildFilterSection() {
    final hasLocation =
        _donorNotifier.latitude != null && _donorNotifier.longitude != null;

    final hasActiveFilters =
        _selectedBloodGroup != null || _selectedRadius != null || hasLocation;

    final activeFilterCount =
        (_selectedBloodGroup != null ? 1 : 0) +
        (_selectedRadius != null ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Find donors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            if (activeFilterCount > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$activeFilterCount active',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (hasActiveFilters)
              TextButton(
                onPressed: _clearFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(
                icon: Icons.bloodtype_outlined,
                label: _selectedBloodGroup ?? 'Blood Group',
                isActive: _selectedBloodGroup != null,
                onTap: _showBloodGroupSheet,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip(
                icon: hasLocation
                    ? Icons.my_location_rounded
                    : Icons.location_on_outlined,
                label: hasLocation
                    ? 'Nearby ${_selectedRadius?.toInt() ?? 50} km'
                    : 'Nearby',
                isActive: hasLocation,
                onTap: _handleUseNearby,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip(
                icon: Icons.tune_rounded,
                label: _selectedRadius != null
                    ? '${_selectedRadius!.toInt()} km'
                    : 'Radius',
                isActive: _selectedRadius != null,
                onTap: _showRadiusSheet,
                showArrow: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Location Prompt
  // ---------------------------------------------------------------------------

  Widget _buildLocationPrompt() {
    final locationEnabled = ref.watch(appPreferencesProvider).locationEnabled;

    if (locationEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn on location',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 3),
                Text(
                  'Enable location to see accurate donor distances near you.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Blood Group Sheet
  // ---------------------------------------------------------------------------

  Future<void> _showBloodGroupSheet() async {
    const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood Group',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Choose the blood group you need.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildBloodGroupChip(sheetContext, label: 'All', value: ''),
                    ...bloodGroups.map(
                      (group) => _buildBloodGroupChip(
                        sheetContext,
                        label: group,
                        value: group,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    final bloodGroup = selected.isEmpty ? null : selected;

    await _handleBloodGroupChanged(bloodGroup);
  }

  Widget _buildBloodGroupChip(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final currentValue = _selectedBloodGroup ?? '';

    final isSelected = currentValue == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        Navigator.of(context).pop(value);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundColor: AppColors.background,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ---------------------------------------------------------------------------
  // Radius Sheet
  // ---------------------------------------------------------------------------

  Future<void> _showRadiusSheet() async {
    const radiusOptions = [5.0, 10.0, 25.0, 50.0];

    final selected = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Radius',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'How far should we search for donors?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...radiusOptions.map(
                  (radius) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      '${radius.toInt()} km',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: _selectedRadius == radius
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(sheetContext).pop(radius);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    await _handleRadiusChanged(selected);
  }

  // ---------------------------------------------------------------------------
  // Donor Item
  // ---------------------------------------------------------------------------

  Widget _buildDonorItem(DonorModel donor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DonorListItem(
        donor: donor,
        onRequest: () {
          _handleDonorRequest(donor);
        },
        onTap: () {
          _handleDonorTap(donor);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pagination UI
  // ---------------------------------------------------------------------------

  Widget _buildPaginationLoader() {
    if (!_donorNotifier.isLoadingMore) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }

  Widget _buildNoMoreResults() {
    if (_donorNotifier.hasMore) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
      child: Center(
        child: Text(
          'No more donors to show',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    final search = _searchController.text.trim();

    final hasFilter = _selectedBloodGroup != null || _selectedRadius != null;

    String description;

    if (search.isNotEmpty) {
      description =
          'No donors found for "$search". Try a different city or address.';
    } else if (_selectedBloodGroup != null) {
      description =
          'No ${_selectedBloodGroup!} donors were found with the current filters.';
    } else if (hasFilter) {
      description = 'No donors were found within the selected search area.';
    } else {
      description = 'There are no available donors to show right now.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: AppEmptyState(
        title: 'No donors found',
        description: description,
        icon: Icons.person_search_outlined,
        actionLabel: search.isNotEmpty ? 'Clear search' : null,
        onActionPressed: search.isNotEmpty ? _clearSearch : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Donor List
  // ---------------------------------------------------------------------------

  Widget _buildDonorContent(List<DonorModel> donors) {
    if (donors.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        for (final donor in donors) _buildDonorItem(donor),
        _buildPaginationLoader(),
        _buildNoMoreResults(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          const SizedBox(height: AppSpacing.lg),
          _buildFilterSection(),
          _buildLocationPrompt(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: AppSpacing.md,
        title: const Text(
          'Available Donors',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: donorState.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SizedBox(
                height: 220,
                child: Center(
                  child: AppEmptyState(
                    title: 'Unable to load donors',
                    description: 'Something went wrong while loading donors.',
                    icon: Icons.error_outline,
                    actionLabel: 'Try again',
                    onActionPressed: _handleRefresh,
                  ),
                ),
              ),
            ],
          );
        },
        data: (donors) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: AppSpacing.huge),
              children: [
                _buildHeader(),
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    0,
                  ),
                  child: _buildDonorContent(donors),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
