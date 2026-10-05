import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/navigation/providers/navigation_provider.dart';
import 'package:pulze_plus/features/requests/providers/blood_request_provider.dart';
import 'package:pulze_plus/features/donors/providers/donor_provider.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';
import 'package:pulze_plus/features/requests/widgets/create_blood_request_sheet.dart';
import 'package:pulze_plus/features/requests/widgets/my_request_item.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/blood_request_model.dart';
import '../../donors/models/donor_model.dart';
import '../widgets/create_request_card.dart';
import '../../donors/widgets/donor_list_section.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  // ---------------------------------------------------------------------------
  // Authentication / Guest Access
  // ---------------------------------------------------------------------------

  bool get _isAuthenticated {
    return ref.read(authProvider).status == AuthStatus.authenticated;
  }

  void _navigateToLogin() {
    ref.read(navigationIndexProvider.notifier).setIndex(4);
  }

  void _showLoginRequired({
    required String title,
    required String description,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          icon: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Not Now',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _navigateToLogin();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleCreateRequestPressed() {
    if (!_isAuthenticated) {
      _showLoginRequired(
        title: 'Login required',
        description:
            'Please log in to create a blood request and connect with donors.',
      );
      return;
    }

    _handleCreateRequest();
  }

  void _handleMyRequestsPressed() {
    if (!_isAuthenticated) {
      _showLoginRequired(
        title: 'Login to view your requests',
        description:
            'Please log in to create, track, and manage your blood requests.',
      );
      return;
    }

    context.push(AppRoutes.myBloodRequests);
  }

  // ---------------------------------------------------------------------------
  // Donor Request
  // ---------------------------------------------------------------------------

  void _handleDonorRequest(DonorModel donor) {
    if (!_isAuthenticated) {
      _showLoginRequired(
        title: 'Login required',
        description: 'Please log in to create a blood request and request help from this donor.',
      );
      return;
    }

    _handleCreateRequest();
  }

  // ---------------------------------------------------------------------------
  // Create Request
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Edit Request
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Terminate Request
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Refresh
  // ---------------------------------------------------------------------------

  Future<void> _refreshRequests() async {
    await ref.read(bloodRequestsProvider.notifier).refreshRequests();

    await ref.read(donorProvider.notifier).refreshDonors();
  }

  // ---------------------------------------------------------------------------
  // Donor Section
  // ---------------------------------------------------------------------------

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
          locationEnabled: locationEnabled,
          onViewAll: () {
            context.push(AppRoutes.donors);
          },
          onDonorRequest: _handleDonorRequest,
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Guest My Requests
  // ---------------------------------------------------------------------------

  Widget _buildGuestMyRequestsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bloodtype_outlined,
              color: AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'My Blood Requests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Log in to create, track, and manage your blood requests.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _navigateToLogin,
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Login to Continue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // My Requests Section
  // ---------------------------------------------------------------------------

  Widget _buildMyRequestsSection({required bool isAuthenticated}) {
    if (!isAuthenticated) {
      return _buildGuestMyRequestsSection();
    }

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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    ref.listen(appPreferencesProvider, (previous, next) {
      if (previous?.locationEnabled != next.locationEnabled) {
        ref.read(donorProvider.notifier).refreshDonors();
      }
    });

    final isAuthenticated =
        ref.watch(authProvider).status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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

              const Text(
                'Find donors and manage your blood requests.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppSpacing.xl),

              // -------------------------------------------------------------
              // Available Donors
              // -------------------------------------------------------------
              _buildDonorSection(),

              const SizedBox(height: AppSpacing.lg),

              // -------------------------------------------------------------
              // Create Blood Request
              //
              // Visible for both guests and authenticated users.
              // Guest -> login prompt
              // Authenticated -> create request sheet
              // -------------------------------------------------------------
              CreateRequestCard(onPressed: _handleCreateRequestPressed),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Blood Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _handleMyRequestsPressed,
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
              const SizedBox(height: AppSpacing.sm),
              // -------------------------------------------------------------
              // My Blood Requests
              //
              // Guest -> login card
              // Authenticated -> actual requests
              // -------------------------------------------------------------
              _buildMyRequestsSection(isAuthenticated: isAuthenticated),
            ],
          ),
        ),
      ),
    );
  }
}
