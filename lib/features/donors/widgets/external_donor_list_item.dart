import 'package:flutter/material.dart';

import 'package:pulze_plus/features/donors/models/external_donor_model.dart';

class ExternalDonorListItem extends StatelessWidget {
  const ExternalDonorListItem({
    super.key,
    required this.donor,
    this.onTap,
  });

  final ExternalDonorModel donor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBloodGroupBadge(theme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (donor.city.isNotEmpty)
                      _InfoRow(
                        icon: Icons.location_city_outlined,
                        text: donor.city,
                      ),
                    if (donor.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: donor.address,
                      ),
                    ],
                    if (donor.phoneNumber != null &&
                        donor.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        text: donor.phoneNumber!,
                      ),
                    ],
                    if (donor.source.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        donor.source,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBloodGroupBadge(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        donor.bloodGroup,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}