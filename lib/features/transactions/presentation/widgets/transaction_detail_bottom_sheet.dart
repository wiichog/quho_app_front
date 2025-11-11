import 'package:flutter/material.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/core/utils/helpers.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/transactions/presentation/widgets/edit_transaction_bottom_sheet.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Bottom sheet con el detalle completo de una transacción
class TransactionDetailBottomSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Helpers.getCategoryColor(transaction.category);
    final categoryIcon = Helpers.getCategoryIcon(transaction.category);
    final amountColor = transaction.isIncome ? AppColors.green : AppColors.red;
    final amountPrefix = transaction.isIncome ? '+' : '-';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            AppSpacing.verticalMd,

            // Header con ícono
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 32,
              ),
            ),

            AppSpacing.verticalSm,

            // Tipo de transacción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: amountColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.isIncome ? 'Ingreso' : 'Gasto',
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalMd,

            // Monto principal
            Text(
              '$amountPrefix${Formatters.currency(transaction.amount)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: amountColor,
                height: 1.2,
              ),
            ),

            // Moneda original si aplica
            if (transaction.originalCurrency != null &&
                transaction.originalCurrency != 'GTQ' &&
                transaction.originalAmount != null) ...[
              const SizedBox(height: 4),
              Text(
                Formatters.currencyWithCode(
                  transaction.originalCurrency!,
                  transaction.originalAmount!,
                ),
                style: AppTextStyles.bodyMedium(color: AppColors.gray600),
              ),
            ],

            AppSpacing.verticalLg,

            // Detalles
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'Descripción',
                    value: transaction.description,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Categoría',
                    value: transaction.category,
                    valueColor: categoryColor,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha',
                    value: Formatters.date(transaction.date),
                  ),
                  if (transaction.merchantDisplayName != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.store_outlined,
                      label: 'Comercio',
                      value: transaction.merchantDisplayName!,
                    ),
                  ],
                  if (transaction.incomeSourceName != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Fuente de ingreso',
                      value: transaction.incomeSourceName!,
                    ),
                  ],
                  if (transaction.exchangeRate != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.currency_exchange_outlined,
                      label: 'Tipo de cambio',
                      value: Formatters.decimal(transaction.exchangeRate!),
                    ),
                  ],
                ],
              ),
            ),

            AppSpacing.verticalMd,

            // Botones de acción
            Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Abrir modal de edición
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => EditTransactionBottomSheet(
                            transaction: transaction,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        side: const BorderSide(color: AppColors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Implementar eliminación
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSm,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.gray600,
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption(color: AppColors.gray600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

