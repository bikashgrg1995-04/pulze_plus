import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/blood_request_model.dart';
import 'my_request_item.dart';

class MyRequestsSection extends StatelessWidget {
  const MyRequestsSection({
    super.key,
    required this.requests,
    this.onViewAll,
    this.onRequestTap,
  });

  final List<BloodRequestModel> requests;
  final VoidCallback? onViewAll;
  final ValueChanged<BloodRequestModel>? onRequestTap;

  @override
  Widget build(BuildContext context) {
    final visibleRequests = requests.take(2).toList();

    return Column(
      children: [
        AppSectionHeader(
          title: 'My Requests',
          actionLabel: requests.length > 2 ? 'View All' : null,
          onActionPressed: onViewAll,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (visibleRequests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
            ),
            child: Text(
              'You have no blood requests yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...visibleRequests.map(
            (request) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: MyRequestItem(
                request: request,
                onTap: () {
                  onRequestTap?.call(request);
                },
              ),
            ),
          ),
      ],
    );
  }
}