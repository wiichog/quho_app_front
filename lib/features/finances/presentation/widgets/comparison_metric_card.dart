import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

/// Card that shows a comparison between theoretical and actual values
class ComparisonMetricCard extends StatelessWidget {
  final String title;
  final double theoretical;
  final double actual;
  final IconData icon;
  final bool higherIsBetter; // true for income, false for expenses

  const ComparisonMetricCard({
    super.key,
    required this.title,
    required this.theoretical,
    required this.actual,
    required this.icon,
    required this.higherIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    final difference = actual - theoretical;
    final percentage = theoretical != 0 ? (actual / theoretical * 100) : 0.0;
    
    // Determine if the result is "good" based on the metric type
    final bool isGood = higherIsBetter 
        ? (difference >= 0) // For income, higher is better
        : (difference <= 0); // For expenses, lower is better
    
    final statusColor = isGood ? AppColors.green : AppColors.orange;
    final statusIcon = isGood ? Icons.trending_up : Icons.trending_down;

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                statusIcon,
                size: 20,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Theoretical vs Actual
          Row(
            children: [
              // Theoretical
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teórico',
                      style: AppTextStyles.caption(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(theoretical),
                      style: AppTextStyles.bodyLarge().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Divider
              Container(
                height: 40,
                width: 1,
                color: AppColors.gray300,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              
              // Actual
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real',
                      style: AppTextStyles.caption(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(actual),
                      style: AppTextStyles.bodyLarge().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 6,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Percentage and difference
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption(color: statusColor).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${difference >= 0 ? '+' : ''}${Formatters.currency(difference)}',
                style: AppTextStyles.bodySmall().copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

