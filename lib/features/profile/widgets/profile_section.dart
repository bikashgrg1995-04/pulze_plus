import 'package:flutter/material.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final sectionSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      large: AppSpacing.md,
    );

    final sectionRadius = ResponsiveUtils.value(
      context,
      mobile: AppRadius.lg,
      tablet: AppRadius.xl,
      large: AppRadius.xl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: title,
        ),

        SizedBox(
          height: sectionSpacing,
        ),

        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              sectionRadius,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}