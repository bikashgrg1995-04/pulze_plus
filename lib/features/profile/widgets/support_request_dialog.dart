import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/profile/providers/help_support_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';

enum SupportRequestType { contact, problem, feedback }

class SupportRequestDialog extends ConsumerStatefulWidget {
  const SupportRequestDialog({
    super.key,
    required this.parentContext,
    required this.type,
  });

  final BuildContext parentContext;
  final SupportRequestType type;

  @override
  ConsumerState<SupportRequestDialog> createState() =>
      _SupportRequestDialogState();
}

class _SupportRequestDialogState
    extends ConsumerState<SupportRequestDialog> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  String _title(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.contactSupport;
      case SupportRequestType.problem:
        return l10n.reportAProblem;
      case SupportRequestType.feedback:
        return l10n.sendFeedback;
    }
  }

  String _subtitle(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.tellUsHowWeCanHelp;
      case SupportRequestType.problem:
        return l10n.tellUsWhatWentWrong;
      case SupportRequestType.feedback:
        return l10n.shareYourThoughtsAndHelpUsImprove;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SupportRequestType.contact:
        return Icons.support_agent_rounded;
      case SupportRequestType.problem:
        return Icons.bug_report_outlined;
      case SupportRequestType.feedback:
        return Icons.rate_review_outlined;
    }
  }

  String _subjectHint(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.whatDoYouNeedHelpWith;
      case SupportRequestType.problem:
        return l10n.whatProblemAreYouExperiencing;
      case SupportRequestType.feedback:
        return l10n.whatWouldYouLikeToShare;
    }
  }

  String _messageHint(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.describeYourQuestionOrIssue;
      case SupportRequestType.problem:
        return l10n.describeTheProblemAndWhatHappened;
      case SupportRequestType.feedback:
        return l10n.tellUsAboutYourExperienceOrSuggestion;
    }
  }

  String _buttonText(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.sendMessage;
      case SupportRequestType.problem:
        return l10n.submitReport;
      case SupportRequestType.feedback:
        return l10n.sendFeedback;
    }
  }

  String _successMessage(AppLocalizations l10n) {
    switch (widget.type) {
      case SupportRequestType.contact:
        return l10n.supportRequestSubmittedSuccessfully;
      case SupportRequestType.problem:
        return l10n.problemReportSubmittedSuccessfully;
      case SupportRequestType.feedback:
        return l10n.thankYouForYourFeedback;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository =
          ref.read(helpSupportRepositoryProvider);

      switch (widget.type) {
        case SupportRequestType.contact:
          await repository.contactSupport(
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );
          break;

        case SupportRequestType.problem:
          await repository.reportProblem(
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );
          break;

        case SupportRequestType.feedback:
          await repository.submitFeedback(
            subject: _subjectController.text.trim(),
            message: _messageController.text.trim(),
          );
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      final l10n = AppLocalizations.of(context)!;
      final successMessage = _successMessage(l10n);

      Navigator.of(context).pop();

      if (widget.parentContext.mounted) {
        Navigator.of(widget.parentContext).pop();

        AppSnackBar.success(
          widget.parentContext,
          successMessage,
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      AppSnackBar.error(
        context,
        error.toString(),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: colorScheme.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: mediaQuery.viewInsets.bottom > 0
            ? AppSpacing.md
            : AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 680,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          AppRadius.lg,
                        ),
                      ),
                      child: Icon(
                        _icon,
                        color: AppColors.primary,
                        size: 28,
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
                            _title(l10n),
                            style: theme
                                .textTheme.titleLarge
                                ?.copyWith(
                              color:
                                  colorScheme.onSurface,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle(l10n),
                            style: theme
                                .textTheme.bodyMedium
                                ?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    IconButton(
                      tooltip: l10n.close,
                      onPressed: _isSubmitting
                          ? null
                          : () =>
                              Navigator.of(context)
                                  .pop(),
                      visualDensity:
                          VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: AppSpacing.xl,
                ),

                AppTextField(
                  controller: _subjectController,
                  label: l10n.subject,
                  hint: _subjectHint(l10n),
                  prefixIcon: Icons.subject_rounded,
                  textInputAction:
                      TextInputAction.next,
                  validator: (value) {
                    final text =
                        value?.trim() ?? '';

                    if (text.isEmpty) {
                      return l10n
                          .pleaseEnterASubject;
                    }

                    if (text.length < 3) {
                      return l10n
                          .subjectMustBeAtLeast3Characters;
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.md,
                ),

                AppTextField(
                  controller: _messageController,
                  label: l10n.message,
                  hint: _messageHint(l10n),
                  prefixIcon:
                      Icons.chat_bubble_outline_rounded,
                  minLines: 5,
                  maxLines: 8,
                  textInputAction:
                      TextInputAction.newline,
                  validator: (value) {
                    final text =
                        value?.trim() ?? '';

                    if (text.isEmpty) {
                      return l10n
                          .pleaseEnterYourMessage;
                    }

                    if (text.length < 10) {
                      return l10n
                          .messageMustBeAtLeast10Characters;
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary.withValues(
                      alpha: 0.05,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.md,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      Expanded(
                        child: Text(
                          l10n
                              .provideEnoughDetailsToRespond,
                          style: theme
                              .textTheme.bodySmall
                              ?.copyWith(
                            color: colorScheme
                                .onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: AppSpacing.lg,
                ),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _buttonText(l10n),
                    onPressed: _isSubmitting
                        ? null
                        : _submit,
                    isLoading: _isSubmitting,
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