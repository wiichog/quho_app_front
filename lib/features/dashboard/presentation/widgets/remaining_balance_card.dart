import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/core/utils/formatters.dart';

class RemainingBalanceCard extends StatelessWidget {
  final double remainingForMonth;
  final int daysRemaining;

  const RemainingBalanceCard({
    super.key,
    required this.remainingForMonth,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final dailyBudget = daysRemaining > 0 ? remainingForMonth / daysRemaining : 0.0;
    final isPositive = remainingForMonth >= 0;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: isPositive ? AppColors.tealPale : AppColors.redLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isPositive ? AppColors.teal.withOpacity(0.3) : AppColors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.teal.withOpacity(0.2) : AppColors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? AppColors.teal : AppColors.red,
                  size: 20,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Para sobrevivir el mes',
                      style: AppTextStyles.bodySmall(
                        color: AppColors.gray700,
                      ),
                    ),
                    Text(
                      '$daysRemaining días restantes',
                      style: AppTextStyles.caption(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          Text(
            Formatters.currency(remainingForMonth),
            style: AppTextStyles.h2(
              color: isPositive ? AppColors.teal : AppColors.red,
            ).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSm,
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.gray600,
                ),
                AppSpacing.horizontalXs,
                Text(
                  '${Formatters.currency(dailyBudget)} / día',
                  style: AppTextStyles.caption(color: AppColors.gray700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

