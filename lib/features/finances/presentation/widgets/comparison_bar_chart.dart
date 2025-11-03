import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

/// Bar chart widget for comparing ideal vs actual spending by category
class ComparisonBarChart extends StatelessWidget {
  final List<CategoryComparison> categories;

  const ComparisonBarChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Sin datos para comparar',
            style: AppTextStyles.bodyMedium().copyWith(color: AppColors.gray500),
          ),
        ),
      );
    }

    // Take top 6 categories by spending
    final topCategories = (categories.toList()
          ..sort((a, b) => b.spent.compareTo(a.spent)))
        .take(6)
        .toList();

    final maxValue = topCategories.fold<double>(
      0,
      (max, cat) => [max, cat.budgeted, cat.spent].reduce((a, b) => a > b ? a : b),
    );

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
            'Comparación: Presupuestado vs Real',
            style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem('Presupuestado', AppColors.teal.withOpacity(0.3)),
              const SizedBox(width: 16),
              _buildLegendItem('Gastado', AppColors.teal),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = topCategories[group.x.toInt()];
                      final isBudgeted = rodIndex == 0;
                      final value = isBudgeted ? category.budgeted : category.spent;
                      return BarTooltipItem(
                        '${category.category}\n',
                        AppTextStyles.bodySmall().copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${isBudgeted ? "Presupuestado" : "Gastado"}: ${Formatters.currency(value)}',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= topCategories.length) {
                          return const SizedBox.shrink();
                        }
                        final category = topCategories[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _shortenCategoryName(category.category),
                            style: AppTextStyles.bodySmall().copyWith(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatAmount(value),
                          style: AppTextStyles.bodySmall().copyWith(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.gray200,
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: topCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Budgeted bar
                      BarChartRodData(
                        toY: category.budgeted,
                        color: AppColors.teal.withOpacity(0.3),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      // Actual spending bar
                      BarChartRodData(
                        toY: category.spent,
                        color: category.isOverBudget ? AppColors.red : AppColors.teal,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall(),
        ),
      ],
    );
  }

  String _shortenCategoryName(String name) {
    if (name.length <= 10) return name;
    return '${name.substring(0, 8)}...';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return 'Q${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'Q${amount.toStringAsFixed(0)}';
  }
}

