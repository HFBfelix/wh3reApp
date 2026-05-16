import 'package:flutter/material.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/utils/haptics.dart';
import 'package:wh3re/models/response_model.dart';

/// Sélecteur de poids : Indifférent / Souhaité / Rédhibitoire.
class WeightSelector extends StatelessWidget {
  const WeightSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AnswerWeight selected;
  final ValueChanged<AnswerWeight> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _WeightChip(
            label: 'Indifférent',
            weight: AnswerWeight.indifferent,
            color: AppColors.weightIndifferent,
            isSelected: selected == AnswerWeight.indifferent,
            onTap: () => _select(AnswerWeight.indifferent),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WeightChip(
            label: 'Souhaité',
            weight: AnswerWeight.wished,
            color: AppColors.weightWished,
            isSelected: selected == AnswerWeight.wished,
            onTap: () => _select(AnswerWeight.wished),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _WeightChip(
            label: 'Rédhibitoire',
            weight: AnswerWeight.redhibitory,
            color: AppColors.weightRedhibitory,
            isSelected: selected == AnswerWeight.redhibitory,
            onTap: () => _select(AnswerWeight.redhibitory),
          ),
        ),
      ],
    );
  }

  Future<void> _select(AnswerWeight weight) async {
    await Wh3reHaptics.lightImpact();
    onChanged(weight);
  }
}

class _WeightChip extends StatelessWidget {
  const _WeightChip({
    required this.label,
    required this.weight,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final AnswerWeight weight;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isVeto = weight == AnswerWeight.redhibitory;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isVeto ? AppColors.errorLight : color.withOpacity(0.15))
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isVeto ? AppColors.weightRedhibitory : color)
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isVeto ? AppColors.weightRedhibitory : color)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
