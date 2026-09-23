import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum AppSnackBarType {
  success,
  error,
  info,
  warning,
}

abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          backgroundColor: _backgroundColor(type),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          content: Row(
            children: [
              Icon(
                _icon(type),
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onActionPressed ?? () {},
                ),
        ),
      );
  }

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.info,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.warning,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static Color _backgroundColor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return AppColors.success;

      case AppSnackBarType.error:
        return AppColors.error;

      case AppSnackBarType.info:
        return AppColors.info;

      case AppSnackBarType.warning:
        return AppColors.warning;
    }
  }

  static IconData _icon(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return Icons.check_circle_outline_rounded;

      case AppSnackBarType.error:
        return Icons.error_outline_rounded;

      case AppSnackBarType.info:
        return Icons.info_outline_rounded;

      case AppSnackBarType.warning:
        return Icons.warning_amber_rounded;
    }
  }
}