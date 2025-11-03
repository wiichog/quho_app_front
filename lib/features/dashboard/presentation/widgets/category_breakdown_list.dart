import 'package:flutter/material.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/core/utils/formatters.dart';

class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdown> categories;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 32,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalSm,
            Text(
              'Sin categorías',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
            ),
            const SizedBox(height: 4),
            Text(
              'Categoriza gastos para ver el desglose',
              style: AppTextStyles.caption(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: categories.map((category) {
        return _CategoryBreakdownItem(category: category);
      }).toList(),
    );
  }
}

class _CategoryBreakdownItem extends StatelessWidget {
  final CategoryBreakdown category;

  const _CategoryBreakdownItem({required this.category});

  Color _getStatusColor() {
    switch (category.status) {
      case CategoryStatus.good:
        return AppColors.green;
      case CategoryStatus.warning:
        return AppColors.orange;
      case CategoryStatus.danger:
        return AppColors.red;
      case CategoryStatus.neutral:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon() {
    switch (category.status) {
      case CategoryStatus.good:
        return Icons.check_circle;
      case CategoryStatus.warning:
        return Icons.warning;
      case CategoryStatus.danger:
        return Icons.error;
      case CategoryStatus.neutral:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final percentage = category.spentPercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: statusColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.category,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(category.spent),
                    style: AppTextStyles.bodyMedium(color: statusColor).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'de ${Formatters.currency(category.budgeted)}',
                    style: AppTextStyles.caption(color: AppColors.gray600),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          AppSpacing.verticalXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${(percentage * 100).toInt()}% gastado',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Restante: ${Formatters.currency(category.remaining)}',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

