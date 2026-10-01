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

  bool _isApplyingFilter = false;

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
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Location
  // ---------------------------------------------------------------------------

  Future<bool> _requestLocationForNearby() async {
    final preferences = ref.read(appPreferencesProvider);

    if (!preferences.locationEnabled) {
      final shouldEnable = await _showEnableLocationDialog();

      if (!shouldEnable) {
        return false;
      }
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
      await _showLocationUnavailableDialog(
        'Location services are turned off. Please turn on location services and try again.',
      );
    } on LocationPermissionDeniedException {
      await _showLocationUnavailableDialog(
        'Location permission is required to find nearby donors.',
      );
    } on LocationPermissionPermanentlyDeniedException {
      await _showLocationUnavailableDialog(
        'Location permission is disabled. Please enable it in your device settings.',
      );
    } catch (_) {
      await _showLocationUnavailableDialog(
        'Unable to access your location right now. Please try again.',
      );
    }

    return false;
  }

  Future<bool> _showEnableLocationDialog() async {
    if (!mounted) {
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Enable Location?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Nearby donor search uses your current location to find donors within the selected radius.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Enable Location'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _showLocationUnavailableDialog(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Location unavailable',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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

    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _isApplyingFilter = true;
      });

      try {
        await _donorNotifier.searchDonors(value);
      } finally {
        if (mounted) {
          setState(() {
            _isApplyingFilter = false;
          });
        }
      }
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {});

    _applySearchClear();
  }

  Future<void> _applySearchClear() async {
    setState(() {
      _isApplyingFilter = true;
    });

    try {
      await _donorNotifier.searchDonors(null);
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Filter
  // ---------------------------------------------------------------------------

  Future<void> _openFilterSheet() async {
    final selection = await showModalBottomSheet<_DonorFilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (sheetContext) {
        String? temporaryBloodGroup = _selectedBloodGroup;
        double temporaryRadius = _selectedRadius ?? 25;

        return Consumer(
          builder: (context, ref, child) {
            final locationEnabled = ref.watch(
              appPreferencesProvider.select((state) => state.locationEnabled),
            );

            return StatefulBuilder(
              builder: (context, sheetSetState) {
                return SafeArea(
                  top: false,
                  child: Container(
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          // ----------------------------------------------------
                          // Drag handle
                          // ----------------------------------------------------

                          const SizedBox(height: AppSpacing.sm),

                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // ----------------------------------------------------
                          // Header
                          // ----------------------------------------------------
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.md,
                              AppSpacing.lg,
                              AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Filter donors',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'Choose how you want to find donors.',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                          ),

                          // ----------------------------------------------------
                          // Tabs
                          // ----------------------------------------------------
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const TabBar(
                                dividerColor: Colors.transparent,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: AppColors.textSecondary,
                                labelStyle: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                unselectedLabelStyle: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                tabs: [
                                  Tab(
                                    icon: Icon(
                                      Icons.bloodtype_outlined,
                                      size: 17,
                                    ),
                                    text: 'Blood Group',
                                  ),
                                  Tab(
                                    icon: Icon(
                                      Icons.location_on_outlined,
                                      size: 17,
                                    ),
                                    text: 'Location',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // ----------------------------------------------------
                          // Tab content
                          // ----------------------------------------------------
                          Expanded(
                            child: TabBarView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // ==================================================
                                // BLOOD GROUP
                                // ==================================================

                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    AppSpacing.sm,
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select blood group',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Choose a blood group to narrow donor results.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildSheetBloodChip(
                                            label: 'All',
                                            value: null,
                                            selected:
                                                temporaryBloodGroup == null,
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = null;
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'A+',
                                            value: 'A+',
                                            selected:
                                                temporaryBloodGroup == 'A+',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'A+';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'A−',
                                            value: 'A-',
                                            selected:
                                                temporaryBloodGroup == 'A-',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'A-';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'B+',
                                            value: 'B+',
                                            selected:
                                                temporaryBloodGroup == 'B+',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'B+';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'B−',
                                            value: 'B-',
                                            selected:
                                                temporaryBloodGroup == 'B-',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'B-';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'AB+',
                                            value: 'AB+',
                                            selected:
                                                temporaryBloodGroup == 'AB+',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'AB+';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'AB−',
                                            value: 'AB-',
                                            selected:
                                                temporaryBloodGroup == 'AB-',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'AB-';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'O+',
                                            value: 'O+',
                                            selected:
                                                temporaryBloodGroup == 'O+',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'O+';
                                              });
                                            },
                                          ),
                                          _buildSheetBloodChip(
                                            label: 'O−',
                                            value: 'O-',
                                            selected:
                                                temporaryBloodGroup == 'O-',
                                            onTap: () {
                                              sheetSetState(() {
                                                temporaryBloodGroup = 'O-';
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: AppSpacing.lg),

                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              size: 17,
                                              color: AppColors.textSecondary,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Select All to search donors from every blood group.',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  height: 1.35,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ==================================================
                                // LOCATION
                                // ==================================================
                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    AppSpacing.sm,
                                    AppSpacing.lg,
                                    AppSpacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.07,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.16,
                                            ),
                                          ),
                                        ),
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 19,
                                              color: AppColors.primary,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Use your current location to find available donors within the selected radius.',
                                                style: TextStyle(
                                                  fontSize: 11.8,
                                                  height: 1.4,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.md),

                                      // ------------------------------------------------
                                      // Location switch
                                      // ------------------------------------------------
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: locationEnabled
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.28,
                                                  )
                                                : AppColors.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: locationEnabled
                                                    ? AppColors.primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
                                                    : AppColors.background,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.location_on_outlined,
                                                size: 21,
                                                color: locationEnabled
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.sm,
                                            ),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Location',
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Use your current location to find nearby donors.',
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      height: 1.3,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Switch.adaptive(
                                              value: locationEnabled,
                                              activeTrackColor: AppColors
                                                  .primary
                                                  .withValues(alpha: 0.45),
                                              activeThumbColor:
                                                  AppColors.primary,
                                              onChanged: (value) async {
                                                if (!value) {
                                                  await ref
                                                      .read(
                                                        appPreferencesProvider
                                                            .notifier,
                                                      )
                                                      .setLocationEnabled(
                                                        false,
                                                      );

                                                  return;
                                                }

                                                await _requestLocationForNearby();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ------------------------------------------------
                                      // Radius
                                      // ------------------------------------------------
                                      if (locationEnabled) ...[
                                        const SizedBox(height: AppSpacing.md),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                            AppSpacing.sm,
                                            AppSpacing.sm,
                                            AppSpacing.sm,
                                            AppSpacing.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      'Search radius',
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 9,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withValues(
                                                            alpha: 0.09,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${temporaryRadius.toInt()} km',
                                                      style: const TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 4,
                                                  thumbShape:
                                                      const RoundSliderThumbShape(
                                                        enabledThumbRadius: 7,
                                                      ),
                                                  overlayShape:
                                                      const RoundSliderOverlayShape(
                                                        overlayRadius: 16,
                                                      ),
                                                  activeTrackColor:
                                                      AppColors.primary,
                                                  inactiveTrackColor:
                                                      AppColors.border,
                                                  thumbColor: AppColors.primary,
                                                  overlayColor: AppColors
                                                      .primary
                                                      .withValues(alpha: 0.10),
                                                ),
                                                child: Slider(
                                                  min: 5,
                                                  max: 50,
                                                  divisions: 9,
                                                  value: temporaryRadius
                                                      .clamp(5.0, 50.0)
                                                      .toDouble(),
                                                  onChanged: (value) {
                                                    sheetSetState(() {
                                                      temporaryRadius = value;
                                                    });
                                                  },
                                                ),
                                              ),

                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '5 km',
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                    Text(
                                                      '50 km',
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ----------------------------------------------------
                          // Bottom actions
                          // ----------------------------------------------------
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.sm,
                              AppSpacing.lg,
                              AppSpacing.md +
                                  MediaQuery.viewInsetsOf(context).bottom,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton(
                                    onPressed: () {
                                      Navigator.of(sheetContext).pop(
                                        _DonorFilterSelection(
                                          bloodGroup: temporaryBloodGroup,
                                          locationEnabled: locationEnabled,
                                          radius: locationEnabled
                                              ? temporaryRadius
                                              : null,
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text('Apply Filter'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (selection == null) {
      return;
    }

    await _applyFilterSelection(selection);
  }

  Future<void> _applyFilterSelection(_DonorFilterSelection selection) async {
    setState(() {
      _selectedBloodGroup = selection.bloodGroup;
      _selectedRadius = selection.locationEnabled ? selection.radius : null;
      _isApplyingFilter = true;
    });

    try {
      if (selection.locationEnabled) {
        await _donorNotifier.loadCurrentLocationDonors(
          radius: selection.radius ?? 25,
          bloodType: selection.bloodGroup,
          search: _searchController.text,
        );
      } else {
        _donorNotifier.clearLocation();

        await _donorNotifier.filterByBloodType(selection.bloodGroup);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    }
  }

  Widget _buildSheetBloodChip({
    required String label,
    required String? value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> _handleRefresh() async {
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

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search city or address',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 21,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded, size: 19),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildFilterButton(),
      ],
    );
  }

  Widget _buildFilterButton() {
    final hasActiveFilter =
        _selectedBloodGroup != null || _selectedRadius != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFilterSheet,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasActiveFilter
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasActiveFilter
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 21,
                color: hasActiveFilter
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              if (hasActiveFilter)
                Positioned(
                  right: -3,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Location Prompt
  // ---------------------------------------------------------------------------

  Widget _buildLocationPrompt(bool locationEnabled) {
    if (locationEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Turn on location to see accurate donor distances near you.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Donor Item
  // ---------------------------------------------------------------------------

  Widget _buildDonorItem(DonorModel donor, {required bool locationEnabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DonorListItem(
        donor: donor,
        locationEnabled: locationEnabled,
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

  Widget _buildDonorContent(
    List<DonorModel> donors, {
    required bool locationEnabled,
  }) {
    final content = donors.isEmpty
        ? _buildEmptyState()
        : Column(
            children: [
              for (final donor in donors)
                _buildDonorItem(donor, locationEnabled: locationEnabled),
              _buildPaginationLoader(),
              _buildNoMoreResults(),
            ],
          );

    if (!_isApplyingFilter) {
      return content;
    }

    return Stack(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: 0.45,
          child: content,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: const CircularProgressIndicator(strokeWidth: 2.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(bool locationEnabled) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSearchField(), _buildLocationPrompt(locationEnabled)],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final donorState = ref.watch(donorProvider);

    final locationEnabled = ref.watch(
      appPreferencesProvider.select((state) => state.locationEnabled),
    );

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
          return ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.huge),
            children: [
              _buildHeader(locationEnabled),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        locationEnabled
                            ? 'Available nearby'
                            : 'Available Donors',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (donors.isNotEmpty)
                      Text(
                        '${donors.length} donors',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildDonorContent(
                  donors,
                  locationEnabled: locationEnabled,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter Selection
// -----------------------------------------------------------------------------

class _DonorFilterSelection {
  const _DonorFilterSelection({
    required this.bloodGroup,
    required this.locationEnabled,
    required this.radius,
  });

  final String? bloodGroup;
  final bool locationEnabled;
  final double? radius;
}
