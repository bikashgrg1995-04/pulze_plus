import 'package:flutter/material.dart';

abstract final class ResponsiveUtils {
  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double height(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static bool isSmallMobile(BuildContext context) {
    return width(context) < 360;
  }

  static bool isMobile(BuildContext context) {
    return width(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    final screenWidth = width(context);
    return screenWidth >= 600 && screenWidth < 900;
  }

  static bool isLargeScreen(BuildContext context) {
    return width(context) >= 900;
  }

  static double widthPercent(
    BuildContext context,
    double percent,
  ) {
    return width(context) * percent;
  }

  static double heightPercent(
    BuildContext context,
    double percent,
  ) {
    return height(context) * percent;
  }

  static double value(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? large,
  }) {
    if (isLargeScreen(context)) {
      return large ?? tablet ?? mobile;
    }

    if (isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}