import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/core/utils/helpers.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Card de transacción optimizado para vista en cuadrícula
class TransactionGridCard extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final VoidCallback? onTap;
  final String? originalCurrency;
  final double? originalAmount;

  const TransactionGridCard({
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
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono y badge
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: amountColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: amountColor,
                      size: 9,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // Categoría
              Text(
                category,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.gray600,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Monto
              Text(
                '$amountPrefix${Formatters.currency(amount)}',
                style: TextStyle(
                  fontSize: 14,
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (originalCurrency != null &&
                  originalCurrency != 'GTQ' &&
                  originalAmount != null) ...[
                const SizedBox(height: 1),
                Text(
                  Formatters.currencyWithCode(originalCurrency!, originalAmount!),
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Fecha
              const SizedBox(height: 2),
              Text(
                Formatters.relativeDate(date),
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

