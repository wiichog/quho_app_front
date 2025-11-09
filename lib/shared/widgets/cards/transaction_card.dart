import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/core/utils/helpers.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Card de transacción de QUHO
class TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final VoidCallback? onTap;
  final String? originalCurrency;
  final double? originalAmount;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.isIncome = false,
    this.onTap,
    this.originalCurrency,
    this.originalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Helpers.getCategoryColor(category);
    final categoryIcon = Helpers.getCategoryIcon(category);
    final amountColor = isIncome ? AppColors.green : AppColors.red;
    final amountPrefix = isIncome ? '+' : '-';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: AppSpacing.iconMd,
                ),
              ),
              
              AppSpacing.horizontalMd,
              
              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h5(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalXxs,
                    Text(
                      Formatters.relativeDate(date),
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.horizontalMd,
              
              // Amount + original (si aplica)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${Formatters.currency(amount)}',
                    style: AppTextStyles.numberSmall(color: amountColor),
                  ),
                  if (originalCurrency != null && originalCurrency != 'GTQ' && originalAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        Formatters.currencyWithCode(originalCurrency!, originalAmount!),
                        style: AppTextStyles.caption(color: AppColors.gray600),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

