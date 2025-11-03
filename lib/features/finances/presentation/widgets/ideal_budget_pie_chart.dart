import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

/// Pie chart widget for ideal budget breakdown
class IdealBudgetPieChart extends StatelessWidget {
  final List<BudgetCategoryItem> categories;

  const IdealBudgetPieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Sin datos de presupuesto',
            style: AppTextStyles.bodyMedium().copyWith(color: AppColors.gray500),
          ),
        ),
      );
    }

    // Take top 5 categories
    final topCategories = categories.take(5).toList();
    final hasMore = categories.length > 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución del Presupuesto Ideal',
            style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: topCategories.asMap().entries.map((entry) {
                        final category = entry.value;
                        return PieChartSectionData(
                          color: Color(int.parse('FF${category.color.substring(1)}', radix: 16)),
                          value: category.budgeted,
                          title: '${category.percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: AppTextStyles.bodySmall().copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: topCategories.length,
                    itemBuilder: (context, index) {
                      final category = topCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(int.parse('FF${category.color.substring(1)}', radix: 16)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.category,
                                style: AppTextStyles.bodySmall(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              Formatters.currency(category.budgeted),
                              style: AppTextStyles.bodySmall().copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${categories.length - 5} categorías más',
              style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }
}

