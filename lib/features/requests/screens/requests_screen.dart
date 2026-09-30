import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/requests/providers/profile_provider.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';
import 'package:pulze_plus/features/requests/widgets/create_blood_request_sheet.dart';
import 'package:pulze_plus/features/requests/widgets/my_request_item.dart';
import 'package:pulze_plus/features/requests/widgets/request_donor_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../data/demo_donors.dart';
import '../models/blood_request_model.dart';
import '../models/donor_model.dart';
import '../widgets/create_request_card.dart';
import '../widgets/donor_filter_bar.dart';
import '../widgets/donor_list_section.dart';
import '../widgets/requests_header.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedBloodGroup;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DonorModel> get _filteredDonors {
    final query = _searchQuery.trim().toLowerCase();

    return demoDonors.where((donor) {
      final matchesBloodGroup =
          _selectedBloodGroup == null ||
          donor.bloodGroup == _selectedBloodGroup;

      final matchesSearch =
          query.isEmpty || donor.bloodGroup.toLowerCase().contains(query);

      return matchesBloodGroup && matchesSearch;
    }).toList();
  }

  void _handleBloodGroupChanged(String? bloodGroup) {
    setState(() {
      _selectedBloodGroup = bloodGroup;
    });
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

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

  Future<void> _refreshRequests() async {
    await ref.read(bloodRequestsProvider.notifier).refreshRequests();
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
    final filteredDonors = _filteredDonors;

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
                RequestsHeader(
                  controller: _searchController,
                  onSearchChanged: _handleSearchChanged,
                ),

                const SizedBox(height: AppSpacing.md),

                DonorFilterBar(
                  selectedBloodGroup: _selectedBloodGroup,
                  onBloodGroupChanged: _handleBloodGroupChanged,
                  onFilterPressed: () {
                    // More filters will be added here.
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                if (filteredDonors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: AppEmptyState(
                      title: 'No matching donors',
                      description:
                          'Try changing your blood group or search criteria.',
                      icon: Icons.person_search_outlined,
                    ),
                  )
                else
                  DonorListSection(
                    donors: filteredDonors,
                    onViewAll: () {
                      // Full donor list will be added later.
                    },
                    onDonorRequest: _handleDonorRequest,
                  ),

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
