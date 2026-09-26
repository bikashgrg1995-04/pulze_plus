import 'package:flutter/material.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.expandable = false,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final String? subtitle;
  final bool expandable;
  final bool initiallyExpanded;

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();

    _isExpanded = widget.expandable && widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    if (!widget.expandable) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.expandable)
            _ExpandableSectionHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              isExpanded: _isExpanded,
              onTap: _toggleExpanded,
            )
          else
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppSectionHeader(title: ''),
            ),

          if (widget.expandable)
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Column(children: widget.children)
                  : const SizedBox.shrink(),
            )
          else
            Column(children: widget.children),
        ],
      ),
    );
  }
}

class _ExpandableSectionHeader extends StatelessWidget {
  const _ExpandableSectionHeader({
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(title: title),

                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.expand_more_rounded,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
