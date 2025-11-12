import 'package:flutter/material.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/core/utils/helpers.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/transactions/presentation/widgets/edit_transaction_bottom_sheet.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Bottom sheet con el detalle completo de una transacción
class TransactionDetailBottomSheet extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onUpdated; // Callback para recargar después de actualizar

  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
    this.onUpdated,
  });

  Future<void> _uncategorizeTransaction(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar categoría'),
        content: const Text(
          '¿Deseas quitar la categoría de esta transacción? '
          'Volverá al módulo de recategorización en el inicio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
            ),
            child: const Text('Quitar categoría'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final datasource = getIt<DashboardRemoteDataSource>();
      await datasource.uncategorizeTransaction(
        transactionId: transaction.id,
      );

      // Cerrar loading
      navigator.pop();
      
      // Cerrar el bottom sheet
      navigator.pop();

      // Mostrar mensaje de éxito
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Categoría eliminada. La transacción volverá al módulo de recategorización.'),
          backgroundColor: AppColors.green,
        ),
      );

      // Llamar callback para recargar
      onUpdated?.call();
    } catch (e) {
      // Cerrar loading si está abierto
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      // Mostrar error
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al quitar categoría: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = Helpers.getCategoryColor(transaction.category);
    final categoryIcon = Helpers.getCategoryIcon(transaction.category);
    final amountColor = transaction.isIncome ? AppColors.green : AppColors.red;
    final amountPrefix = transaction.isIncome ? '+' : '-';
    final isCategorized = transaction.category != 'Sin categoría';

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
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),

            AppSpacing.verticalMd,

            // Detalles
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Categoría',
                    value: transaction.category,
                    valueColor: categoryColor,
                  ),
                  AppSpacing.verticalMd,
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'Descripción',
                    value: transaction.description,
                  ),
                  if (transaction.merchantDisplayName != null) ...[
                    AppSpacing.verticalMd,
                    _DetailRow(
                      icon: Icons.store_outlined,
                      label: 'Comercio',
                      value: transaction.merchantDisplayName!,
                    ),
                  ],
                  AppSpacing.verticalMd,
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha',
                    value: Formatters.date(transaction.date),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalMd,

            // Botones de acción
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: AppColors.white,
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
                  
                  // Botón de quitar categoría (solo si está categorizada)
                  if (isCategorized) ...[
                    AppSpacing.verticalSm,
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _uncategorizeTransaction(context),
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        label: const Text('Quitar categoría'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.orange,
                          side: const BorderSide(color: AppColors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
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

