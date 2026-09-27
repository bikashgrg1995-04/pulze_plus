import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.showHandle = true,
    this.padding,
  });

  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? titleWidget,
    bool showHandle = true,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AppBottomSheet(
          title: title,
          titleWidget: titleWidget,
          showHandle: showHandle,
          padding: padding,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final hasTitle = title != null || titleWidget != null;

    return Material(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xxl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            bottomPadding + AppSpacing.xl,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHandle)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(
                          AppRadius.pill,
                        ),
                      ),
                    ),
                  ),

                if (showHandle && hasTitle)
                  const SizedBox(height: AppSpacing.lg),

                if (hasTitle)
                  titleWidget ??
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                if (hasTitle)
                  const SizedBox(height: AppSpacing.lg),

                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: padding,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}