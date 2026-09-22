import 'package:flutter/material.dart';

import '../../../core/utils/responsive_utils.dart';

class OnboardingBottomAction extends StatelessWidget {
  const OnboardingBottomAction({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.onPressed,
    required this.horizontalPadding,
  });

  final int currentPage;
  final int lastPage;
  final VoidCallback onPressed;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = ResponsiveUtils.value(
      context,
      mobile: double.infinity,
      tablet: 420,
      large: 480,
    );

    return SizedBox(
      width: buttonWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isMobile(context)
              ? horizontalPadding
              : 0,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(
              currentPage == lastPage
                  ? 'Get Started'
                  : 'Next',
            ),
          ),
        ),
      ),
    );
  }
}