import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class CreateBloodRequestSheet extends StatefulWidget {
  const CreateBloodRequestSheet({
    super.key,
    this.onCreate,
  });

  final VoidCallback? onCreate;

  @override
  State<CreateBloodRequestSheet> createState() =>
      _CreateBloodRequestSheetState();
}

class _CreateBloodRequestSheetState
    extends State<CreateBloodRequestSheet> {
  final _unitsController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedBloodGroup = 'O+';
  String _selectedUrgency = 'Urgent';

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const _urgencies = [
    'Urgent',
    'Normal',
  ];

  @override
  void dispose() {
    _unitsController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Create Blood Request',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Tell nearby eligible donors what you need.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Blood Group',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _bloodGroups.map(
                (bloodGroup) {
                  final selected =
                      _selectedBloodGroup == bloodGroup;

                  return ChoiceChip(
                    label: Text(bloodGroup),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedBloodGroup = bloodGroup;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _unitsController,
              label: 'Units Needed',
              hint: 'e.g. 2',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _locationController,
              label: 'Hospital / Location',
              hint: 'Enter hospital or treatment location',
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Urgency',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: _urgencies.map(
                (urgency) {
                  final selected =
                      _selectedUrgency == urgency;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: urgency == _urgencies.last
                            ? 0
                            : AppSpacing.xs,
                      ),
                      child: ChoiceChip(
                        label: Text(urgency),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedUrgency = urgency;
                          });
                        },
                        selectedColor: urgency == 'Urgent'
                            ? AppColors.error
                            : AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _noteController,
              label: 'Additional Note',
              hint: 'Add any important information',
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Create Request',
              onPressed: widget.onCreate,
            ),
          ],
        ),
      ),
    );
  }
}