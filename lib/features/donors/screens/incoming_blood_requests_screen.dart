import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/widgets/app_empty_state.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/requests/models/blood_request_model.dart';
import 'package:pulze_plus/features/requests/providers/blood_request_provider.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';

class IncomingBloodRequestsScreen extends ConsumerStatefulWidget {
  const IncomingBloodRequestsScreen({super.key});

  @override
  ConsumerState<IncomingBloodRequestsScreen> createState() =>
      _IncomingBloodRequestsScreenState();
}

class _IncomingBloodRequestsScreenState
    extends ConsumerState<IncomingBloodRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRequests() async {
    await ref
        .read(incomingBloodRequestsProvider.notifier)
        .refreshRequests();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  List<BloodRequestModel> _filterRequests(
    List<BloodRequestModel> requests,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return requests;
    }

    return requests.where((request) {
      final bloodGroup = request.bloodGroup.toLowerCase();
      final patientName = request.patientName.toLowerCase();
      final hospitalName = request.hospitalName.toLowerCase();
      final purpose = request.purpose.toLowerCase();
      final urgency = request.urgency.toLowerCase();

      return bloodGroup.contains(query) ||
          patientName.contains(query) ||
          hospitalName.contains(query) ||
          purpose.contains(query) ||
          urgency.contains(query);
    }).toList();
  }

  void _openRequestDetail(BloodRequestModel request) {
    context.push(
      AppRoutes.bloodRequestDetail,
      extra: BloodRequestDetailArgs(
        request: request,
        onAccept: () => _handleAccept(request),
        onDecline: () => _handleDecline(request),
      ),
    );
  }

  Future<void> _handleAccept(BloodRequestModel request) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref
          .read(bloodRequestsProvider.notifier)
          .acceptRequest(id: request.id);

      await ref
          .read(incomingBloodRequestsProvider.notifier)
          .refreshRequests();

      if (!mounted) return;

      AppSnackBar.success(
        context,
        'Blood request accepted successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(
        context,
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleDecline(BloodRequestModel request) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await ref
          .read(bloodRequestsProvider.notifier)
          .declineRequest(id: request.id);

      await ref
          .read(incomingBloodRequestsProvider.notifier)
          .refreshRequests();

      if (!mounted) return;

      AppSnackBar.success(
        context,
        'Blood request declined.',
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(
        context,
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final requestsAsync = ref.watch(incomingBloodRequestsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: _refreshRequests,
          child: requestsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
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
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: _IncomingRequestCard(
                          request: request,
                          onTap: () {
                            _openRequestDetail(request);
                          },
                          onAccept: () {
                            _handleAccept(request);
                          },
                          onDecline: () {
                            _handleDecline(request);
                          },
                          isProcessing: _isProcessing,
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
        'Incoming Requests',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return TextField(
      controller: _searchController,
      onChanged: _handleSearchChanged,
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Search incoming requests',
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
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
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
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(
    BuildContext context, {
    required int requestsCount,
    required int totalCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isFiltered = _searchQuery.trim().isNotEmpty;

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
            onPressed: _clearSearch,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
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
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
      ),
      child: AppEmptyState(
        title: 'No incoming requests',
        description:
            'Direct blood requests sent to you will appear here.',
        icon: Icons.inbox_outlined,
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
      ),
      child: AppEmptyState(
        title: 'No matching requests',
        description:
            'Try changing your search to find another incoming request.',
        icon: Icons.search_off_rounded,
        actionLabel: _searchQuery.isNotEmpty
            ? 'Clear search'
            : null,
        onActionPressed:
            _searchQuery.isNotEmpty ? _clearSearch : null,
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
          title: 'Unable to load incoming requests',
          description:
              'Something went wrong while loading your incoming blood requests.',
          icon: Icons.error_outline_rounded,
          actionLabel: 'Try again',
          onActionPressed: _refreshRequests,
        ),
      ],
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  const _IncomingRequestCard({
    required this.request,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
    required this.isProcessing,
  });

  final BloodRequestModel request;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUrgent = request.urgency.toUpperCase() == 'URGENT';

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isProcessing ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      request.bloodGroup,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.patientName.isNotEmpty
                              ? request.patientName
                              : 'Blood request',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${request.unitsRemaining} '
                          '${request.unitsRemaining == 1 ? 'unit' : 'units'} needed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'URGENT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (request.hospitalName.isNotEmpty)
                _InfoRow(
                  icon: Icons.local_hospital_outlined,
                  text: request.hospitalName,
                ),
              if (request.purpose.isNotEmpty) ...[
                const SizedBox(height: 5),
                _InfoRow(
                  icon: Icons.description_outlined,
                  text: request.purpose,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: isProcessing ? null : onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}