import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/core/widgets/app_text_field.dart';
import 'package:pulze_plus/features/profile/providers/help_support_providers.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

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

class _SupportRequestDialogState extends ConsumerState<SupportRequestDialog> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  String get _title {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'Contact Support';
      case SupportRequestType.problem:
        return 'Report a Problem';
      case SupportRequestType.feedback:
        return 'Send Feedback';
    }
  }

  String get _subtitle {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'Tell us how we can help you.';
      case SupportRequestType.problem:
        return 'Tell us what went wrong so we can fix it.';
      case SupportRequestType.feedback:
        return 'Share your thoughts and help us improve Pulze+.';
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

  String get _subjectHint {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'What do you need help with?';
      case SupportRequestType.problem:
        return 'What problem are you experiencing?';
      case SupportRequestType.feedback:
        return 'What would you like to share?';
    }
  }

  String get _messageHint {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'Describe your question or issue...';
      case SupportRequestType.problem:
        return 'Describe the problem and what happened...';
      case SupportRequestType.feedback:
        return 'Tell us about your experience or suggestion...';
    }
  }

  String get _buttonText {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'Send Message';
      case SupportRequestType.problem:
        return 'Submit Report';
      case SupportRequestType.feedback:
        return 'Send Feedback';
    }
  }

  String get _successMessage {
    switch (widget.type) {
      case SupportRequestType.contact:
        return 'Your support request has been submitted successfully.';
      case SupportRequestType.problem:
        return 'Your problem report has been submitted successfully.';
      case SupportRequestType.feedback:
        return 'Thank you for your feedback.';
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
      final repository = ref.read(helpSupportRepositoryProvider);

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

      Navigator.of(context).pop();

      if (widget.parentContext.mounted) {
        Navigator.of(widget.parentContext).pop();

        AppSnackBar.success(widget.parentContext, _successMessage);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      AppSnackBar.error(context, error.toString());
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
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      backgroundColor: AppColors.surface,
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
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(_icon, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  controller: _subjectController,
                  label: 'Subject',
                  hint: _subjectHint,
                  prefixIcon: Icons.subject_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Please enter a subject.';
                    }

                    if (text.length < 3) {
                      return 'Subject must be at least 3 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  controller: _messageController,
                  label: 'Message',
                  hint: _messageHint,
                  prefixIcon: Icons.chat_bubble_outline_rounded,

                  minLines: 5,
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return 'Please enter your message.';
                    }

                    if (text.length < 10) {
                      return 'Message must be at least 10 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Please provide enough details so we can respond appropriately.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _buttonText,
                    onPressed: _isSubmitting ? null : _submit,
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
