import 'package:flutter/material.dart';

import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsConditions,
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isPrivacyPolicy =
        type == LegalDocumentType.privacyPolicy;

    final title = isPrivacyPolicy
        ? l10n.privacyPolicy
        : l10n.termsConditions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          child: isPrivacyPolicy
              ? _PrivacyPolicyContent(l10n: l10n)
              : _TermsConditionsContent(l10n: l10n),
        ),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentIntro(
          title: l10n.privacyPolicy,
          lastUpdated: l10n.legalLastUpdated,
          description: l10n.privacyPolicyIntro,
        ),
        const SizedBox(height: AppSpacing.xl),
        _DocumentSection(
          title: l10n.privacyInformationWeCollect,
          paragraphs: [
            l10n.privacyInformationWeCollectParagraph1,
            l10n.privacyInformationWeCollectParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyHowWeUseInformation,
          paragraphs: [
            l10n.privacyHowWeUseInformationParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyLocationInformation,
          paragraphs: [
            l10n.privacyLocationInformationParagraph1,
            l10n.privacyLocationInformationParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyNotifications,
          paragraphs: [
            l10n.privacyNotificationsParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyInformationSharing,
          paragraphs: [
            l10n.privacyInformationSharingParagraph1,
            l10n.privacyInformationSharingParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyYourChoices,
          paragraphs: [
            l10n.privacyYourChoicesParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyDataSecurity,
          paragraphs: [
            l10n.privacyDataSecurityParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyChangesToPolicy,
          paragraphs: [
            l10n.privacyChangesToPolicyParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.privacyContact,
          paragraphs: [
            l10n.privacyContactParagraph,
          ],
        ),
      ],
    );
  }
}

class _TermsConditionsContent extends StatelessWidget {
  const _TermsConditionsContent({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DocumentIntro(
          title: l10n.termsConditions,
          lastUpdated: l10n.legalLastUpdated,
          description: l10n.termsConditionsIntro,
        ),
        const SizedBox(height: AppSpacing.xl),
        _DocumentSection(
          title: l10n.termsAcceptance,
          paragraphs: [
            l10n.termsAcceptanceParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsUseOfPulze,
          paragraphs: [
            l10n.termsUseOfPulzeParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsBloodDonationInformation,
          paragraphs: [
            l10n.termsBloodDonationInformationParagraph1,
            l10n.termsBloodDonationInformationParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.termsBloodRequests,
          paragraphs: [
            l10n.termsBloodRequestsParagraph1,
            l10n.termsBloodRequestsParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.termsAccountResponsibility,
          paragraphs: [
            l10n.termsAccountResponsibilityParagraph1,
            l10n.termsAccountResponsibilityParagraph2,
          ],
        ),
        _DocumentSection(
          title: l10n.termsProhibitedUse,
          paragraphs: [
            l10n.termsProhibitedUseParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsServiceAvailability,
          paragraphs: [
            l10n.termsServiceAvailabilityParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsLimitationOfResponsibility,
          paragraphs: [
            l10n.termsLimitationOfResponsibilityParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsChanges,
          paragraphs: [
            l10n.termsChangesParagraph,
          ],
        ),
        _DocumentSection(
          title: l10n.termsContact,
          paragraphs: [
            l10n.termsContactParagraph,
          ],
        ),
      ],
    );
  }
}

class _DocumentIntro extends StatelessWidget {
  const _DocumentIntro({
    required this.title,
    required this.lastUpdated,
    required this.description,
  });

  final String title;
  final String lastUpdated;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          lastUpdated,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: Text(
                paragraph,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}