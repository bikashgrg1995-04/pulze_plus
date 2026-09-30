import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/requests/models/blood_request_model.dart';
import 'package:pulze_plus/features/requests/providers/profile_provider.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';
import 'package:pulze_plus/features/requests/widgets/create_blood_request_sheet.dart';
import 'package:pulze_plus/features/requests/widgets/my_request_item.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';

class MyBloodRequestsScreen extends ConsumerStatefulWidget {
  const MyBloodRequestsScreen({super.key});

  @override
  ConsumerState<MyBloodRequestsScreen> createState() =>
      _MyBloodRequestsScreenState();
}

class _MyBloodRequestsScreenState extends ConsumerState<MyBloodRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'ALL';

  static const List<_StatusFilter> _statusFilters = [
    _StatusFilter(value: 'ALL', label: 'All'),
    _StatusFilter(value: 'ACTIVE', label: 'Active'),
    _StatusFilter(value: 'FULFILLED', label: 'Fulfilled'),
    _StatusFilter(value: 'CANCELLED', label: 'Cancelled'),
    _StatusFilter(value: 'EXPIRED', label: 'Expired'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRequests() async {
    await ref.read(bloodRequestsProvider.notifier).refreshRequests();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _handleStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  List<BloodRequestModel> _filterRequests(List<BloodRequestModel> requests) {
    final query = _searchQuery.trim().toLowerCase();

    return requests.where((request) {
      final matchesStatus =
          _selectedStatus == 'ALL' ||
          request.status.toUpperCase() == _selectedStatus;

      if (!matchesStatus) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final matchesBloodGroup = request.bloodGroup.toLowerCase().contains(
        query,
      );

      final matchesPatient = request.patientName.toLowerCase().contains(query);

      final matchesHospital = request.hospitalName.toLowerCase().contains(
        query,
      );

      final matchesPurpose = request.purpose.toLowerCase().contains(query);

      return matchesBloodGroup ||
          matchesPatient ||
          matchesHospital ||
          matchesPurpose;
    }).toList();
  }

  void _openRequestDetail(BloodRequestModel request) {
    context.push(
      AppRoutes.bloodRequestDetail,
      extra: BloodRequestDetailArgs(
        request: request,
        onEdit: () => _handleEditRequest(request),
        onTerminate: () => _handleTerminateRequest(request),
      ),
    );
  }

  Future<void> _handleEditRequest(BloodRequestModel request) async {
  if (!mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return CreateBloodRequestSheet(
        request: request,
        onCreate: (data) async {
          try {
            await ref
                .read(bloodRequestsProvider.notifier)
                .updateRequest(
                  id: request.id,
                  data: data,
                );

            if (!mounted) return;
            if (!sheetContext.mounted) return;

            Navigator.of(sheetContext).pop();

            AppSnackBar.success(
              context,
              'Blood request updated successfully.',
            );
          } catch (error) {
            if (!sheetContext.mounted) return;

            AppSnackBar.error(
              sheetContext,
              error.toString(),
            );

            rethrow;
          }
        },
      );
    },
  );
}
  Future<void> _handleTerminateRequest(BloodRequestModel request) async {
    final shouldTerminate = await AppConfirmationDialog.show(
      context: context,
      title: 'Terminate Blood Request?',
      description: 'This will stop the request and prevent further donor matching. This action cannot be undone.',
      confirmLabel: 'Terminate',
      cancelLabel: 'Keep Request',
      icon: Icons.stop_circle_outlined,
      isDestructive: true,
    );

    if (shouldTerminate != true) return;

    try {
      await ref
          .read(bloodRequestsProvider.notifier)
          .cancelRequest(id: request.id);

      if (!mounted) return;

      AppSnackBar.success(context, 'Blood request terminated successfully.');
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requestsAsync = ref.watch(bloodRequestsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: _refreshRequests,
          child: requestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorState(context),
            data: (requests) {
              final filteredRequests = _filterRequests(requests);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.huge,
                ),
                children: [
                  _buildSearchField(context, colorScheme),
                  const SizedBox(height: AppSpacing.sm),
                  _buildStatusFilters(context, colorScheme),
                  const SizedBox(height: AppSpacing.lg),
                  _buildResultHeader(
                    context,
                    requestsCount: filteredRequests.length,
                    totalCount: requests.length,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (requests.isEmpty)
                    _buildEmptyState(context)
                  else if (filteredRequests.isEmpty)
                    _buildNoResultsState(context)
                  else
                    ...filteredRequests.map(
                      (request) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MyRequestItem(
                          request: request,
                          onTap: () {
                            _openRequestDetail(request);
                          },
                          onEdit: () {
                            _handleEditRequest(request);
                          },
                          onTerminate: () {
                            _handleTerminateRequest(request);
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      titleSpacing: 0,
      title: Text(
        'My Blood Requests',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return TextField(
      controller: _searchController,
      onChanged: _handleSearchChanged,
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search requests',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 21,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: _clearSearch,
                icon: const Icon(Icons.close_rounded, size: 19),
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Row(
      children: _statusFilters.map((filter) {
        final isSelected = _selectedStatus == filter.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: filter == _statusFilters.last ? 0 : AppSpacing.xs,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _handleStatusChanged(filter.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.65,
                          ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    filter.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultHeader(
    BuildContext context, {
    required int requestsCount,
    required int totalCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isFiltered =
        _selectedStatus != 'ALL' || _searchQuery.trim().isNotEmpty;

    final countText = isFiltered
        ? '$requestsCount '
              '${requestsCount == 1 ? 'request' : 'requests'} found'
        : '$totalCount '
              '${totalCount == 1 ? 'request' : 'requests'}';

    return Row(
      children: [
        Expanded(
          child: Text(
            countText,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (isFiltered)
          TextButton(
            onPressed: () {
              _searchController.clear();

              setState(() {
                _searchQuery = '';
                _selectedStatus = 'ALL';
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reset'),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: AppEmptyState(
        title: 'No blood requests',
        description:
            'Your blood requests will appear here once you create one.',
        icon: Icons.bloodtype_outlined,
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: AppEmptyState(
        title: 'No matching requests',
        description:
            'Try changing your search or selecting a different status.',
        icon: Icons.search_off_rounded,
        actionLabel: _searchQuery.isNotEmpty ? 'Clear search' : null,
        onActionPressed: _searchQuery.isNotEmpty ? _clearSearch : null,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        AppEmptyState(
          title: 'Unable to load requests',
          description:
              'Something went wrong while loading your blood requests.',
          icon: Icons.error_outline_rounded,
          actionLabel: 'Try again',
          onActionPressed: _refreshRequests,
        ),
      ],
    );
  }
}

class _StatusFilter {
  const _StatusFilter({required this.value, required this.label});

  final String value;
  final String label;
}
