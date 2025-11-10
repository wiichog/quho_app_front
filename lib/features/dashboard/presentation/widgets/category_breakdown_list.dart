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

    // Diseño en cuadrícula con círculos progresivos
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _CategoryCircleItem(category: categories[index]);
      },
    );
  }
}

class _CategoryCircleItem extends StatelessWidget {
  final CategoryBreakdown category;

  const _CategoryCircleItem({required this.category});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final percentage = (category.spentPercentage * 100).clamp(0, 100).toInt();
    final hasNoBudget = category.budgeted == 0 && category.spent > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo de progreso
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: category.spentPercentage.clamp(0, 1),
                  strokeWidth: 6,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              hasNoBudget
                  ? Icon(
                      Icons.warning,
                      color: statusColor,
                      size: 24,
                    )
                  : Text(
                      '$percentage%',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        fontSize: 14,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 8),
          // Nombre de categoría
          Text(
            category.category,
            style: AppTextStyles.caption().copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Monto gastado con indicador de sin presupuesto
          hasNoBudget
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.currency(-category.spent),
                      style: AppTextStyles.caption(color: statusColor).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Sin presupuesto',
                      style: AppTextStyles.caption(color: statusColor).copyWith(
                        fontSize: 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Text(
                  Formatters.currency(category.spent),
                  style: AppTextStyles.caption(color: statusColor).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

