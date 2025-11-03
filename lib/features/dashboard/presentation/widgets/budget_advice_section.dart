import 'package:flutter/material.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_advice.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

class BudgetAdviceSection extends StatelessWidget {
  final List<BudgetAdvice> advice;

  const BudgetAdviceSection({
    super.key,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    if (advice.isEmpty) {
      return Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSm,
            Text(
              'Sin consejos',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
            ),
            const SizedBox(height: 4),
            Text(
              'Claude los generará basándose en tu actividad',
              style: AppTextStyles.caption(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: advice.take(2).map((item) {
        return _BudgetAdviceCard(advice: item);
      }).toList(),
    );
  }
}

class _BudgetAdviceCard extends StatelessWidget {
  final BudgetAdvice advice;

  const _BudgetAdviceCard({required this.advice});

  Color _getPriorityColor() {
    switch (advice.priorityColor) {
      case 'red':
        return AppColors.red;
      case 'orange':
        return AppColors.orange;
      case 'green':
        return AppColors.green;
      default:
        return AppColors.gray500;
    }
  }

  String _getPriorityLabel() {
    switch (advice.priority) {
      case 'high':
        return 'Alta prioridad';
      case 'medium':
        return 'Media prioridad';
      case 'low':
        return 'Baja prioridad';
      default:
        return 'Sin prioridad';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priorityColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                advice.categoryIcon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  advice.title,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            advice.description,
            style: AppTextStyles.caption(color: AppColors.gray600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (advice.estimatedImpact.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tealPale,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.insights,
                    size: 12,
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      advice.estimatedImpact,
                      style: AppTextStyles.caption(color: AppColors.teal).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

