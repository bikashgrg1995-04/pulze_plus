import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_search_field.dart';

class RequestsHeader extends StatelessWidget {
  const RequestsHeader({
    super.key,
    this.controller,
    this.onSearchChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find a Donor',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Find eligible and available donors near you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppSearchField(
          controller: controller,
          hint: 'Search by blood group or location',
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}