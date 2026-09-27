import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/profile/providers/help_support_providers.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class FaqScreen extends ConsumerWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final bottomPadding = ResponsiveUtils.value(
      context,
      mobile: 100.0,
      tablet: 80.0,
      large: 80.0,
    );

    final faqAsync = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.sm,
          horizontalPadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FaqIntro(),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                faqAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.xxxl,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                  error: (error, stackTrace) => _FaqError(
                    onRetry: () {
                      ref.invalidate(faqProvider);
                    },
                  ),

                  data: (faqs) {
                    if (faqs.isEmpty) {
                      return const _EmptyFaq();
                    }

                    return Column(
                      children: [
                        for (final faq in faqs)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _FaqTile(
                              question: faq.question,
                              answer: faq.answer,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqIntro extends StatelessWidget {
  const _FaqIntro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: colorScheme.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(
                AppRadius.md,
              ),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequently Asked Questions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.xxs,
                ),

                Text(
                  'Find quick answers about Pulze+, blood donation, '
                  'and your account.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    color:
                        colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() =>
      _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 200,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: _isExpanded
              ? colorScheme.primary.withValues(
                  alpha: 0.35,
                )
              : colorScheme.outline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(
            AppRadius.lg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: AppSpacing.sm,
                    ),

                    AnimatedRotation(
                      turns:
                          _isExpanded ? 0.5 : 0,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      child: Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                AnimatedCrossFade(
                  firstChild:
                      const SizedBox.shrink(),

                  secondChild: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        widget.answer,
                        style: theme
                            .textTheme.bodySmall
                            ?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,

                  duration: const Duration(
                    milliseconds: 200,
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

class _FaqError extends StatelessWidget {
  const _FaqError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 40,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            'Unable to load FAQs.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          TextButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyFaq extends StatelessWidget {
  const _EmptyFaq();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxxl,
      ),
      child: Center(
        child: Text(
          'No FAQs available right now.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}