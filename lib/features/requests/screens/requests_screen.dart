import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/requests/providers/blood_request_provider.dart';
import 'package:pulze_plus/features/requests/providers/donor_provider.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';
import 'package:pulze_plus/features/requests/widgets/create_blood_request_sheet.dart';
import 'package:pulze_plus/features/requests/widgets/my_request_item.dart';
import 'package:pulze_plus/features/requests/widgets/request_donor_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/blood_request_model.dart';
import '../models/donor_model.dart';
import '../widgets/create_request_card.dart';
import '../widgets/donor_list_section.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  void _handleDonorRequest(DonorModel donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return RequestDonorSheet(
          donor: donor,
          onSubmit: () {
            Navigator.of(context).pop();

            AppSnackBar.success(context, 'Request submitted successfully.');
          },
        );
      },
    );
  }

  void _handleCreateRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return CreateBloodRequestSheet(
          onCreate: (data) async {
            try {
              await ref
                  .read(bloodRequestsProvider.notifier)
                  .createRequest(data: data);

              if (!mounted) return;
              if (!sheetContext.mounted) return;

              Navigator.of(sheetContext).pop();

              AppSnackBar.success(
                context,
                'Blood request created successfully.',
              );
            } catch (error) {
              if (!sheetContext.mounted) return;

              AppSnackBar.error(sheetContext, error.toString());

              rethrow;
            }
          },
        );
      },
    );
  }

  Future<void> _handleEditRequest(BloodRequestModel request) async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return CreateBloodRequestSheet(
          request: request,
          onCreate: (data) async {
            try {
              await ref
                  .read(bloodRequestsProvider.notifier)
                  .updateRequest(id: request.id, data: data);

              if (!mounted) return;
              if (!sheetContext.mounted) return;

              Navigator.of(sheetContext).pop();

              AppSnackBar.success(
                context,
                'Blood request updated successfully.',
              );
            } catch (error) {
              if (!sheetContext.mounted) return;

              AppSnackBar.error(sheetContext, error.toString());

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
      description:
          'This will stop the request and prevent further donor matching. '
          'This action cannot be undone.',
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

  Future<void> _refreshRequests() async {
    await ref.read(bloodRequestsProvider.notifier).refreshRequests();

    await ref.read(donorProvider.notifier).refreshDonors();
  }

  Widget _buildDonorSection() {
    final donorState = ref.watch(donorProvider);
    final locationEnabled = ref.watch(appPreferencesProvider).locationEnabled;

    return donorState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: AppEmptyState(
          title: 'Unable to load donors',
          description: 'Something went wrong while loading available donors.',
          icon: Icons.error_outline,
          actionLabel: 'Try again',
          onActionPressed: () {
            ref.read(donorProvider.notifier).refreshDonors();
          },
        ),
      ),
      data: (donors) {
        return DonorListSection(
          donors: donors,
          onViewAll: () {
            context.push(AppRoutes.donors);
          },
          onDonorRequest: _handleDonorRequest,
          locationEnabled: locationEnabled,
        );
      },
    );
  }

  Widget _buildMyRequestsSection() {
    final requestsAsync = ref.watch(bloodRequestsProvider);

    return requestsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: AppEmptyState(
          title: 'Unable to load requests',
          description: 'Something went wrong while loading your requests.',
          icon: Icons.error_outline,
          actionLabel: 'Try again',
          onActionPressed: _refreshRequests,
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
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

        final previewRequests = requests.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Blood Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push(AppRoutes.myBloodRequests);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View More'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...previewRequests.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MyRequestItem(
                  request: request,
                  onTap: () {
                    context.push(
                      AppRoutes.bloodRequestDetail,
                      extra: BloodRequestDetailArgs(
                        request: request,
                        onEdit: () => _handleEditRequest(request),
                        onTerminate: () => _handleTerminateRequest(request),
                      ),
                    );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        ref.watch(authProvider).status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRequests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.huge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood Requests',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: AppSpacing.xs),

                const Text(
                  'Find donors and manage your blood requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                _buildDonorSection(),

                const SizedBox(height: AppSpacing.lg),

                if (isAuthenticated) ...[
                  CreateRequestCard(onPressed: _handleCreateRequest),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildMyRequestsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
