import 'package:flutter/material.dart';
import 'package:pulze_plus/features/requests/widgets/request_donor_sheet.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../data/demo_blood_requests.dart';
import '../data/demo_donors.dart';
import '../models/donor_model.dart';
import '../widgets/create_request_card.dart';
import '../widgets/donor_filter_bar.dart';
import '../widgets/donor_list_section.dart';
import '../widgets/my_requests_section.dart';
import '../widgets/requests_header.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
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

            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(content: Text('Request submitted successfully.')),
            );
          },
        );
      },
    );
  }

  void _handleCreateRequest() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Create blood request')));
  }

  @override
  Widget build(BuildContext context) {
    final filteredDonors = _filteredDonors;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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

              CreateRequestCard(onPressed: _handleCreateRequest),

              const SizedBox(height: AppSpacing.xxl),

              MyRequestsSection(
                requests: demoBloodRequests,
                onViewAll: () {
                  // Full request history will be added later.
                },
                onRequestTap: (request) {
                  // Request detail will be added later.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
