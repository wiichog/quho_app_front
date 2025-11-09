import 'package:flutter/material.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

class BudgetStatusIndicator extends StatefulWidget {
  final BudgetStatus status;
  final int daysRemaining;

  const BudgetStatusIndicator({
    super.key,
    required this.status,
    required this.daysRemaining,
  });

  @override
  State<BudgetStatusIndicator> createState() => _BudgetStatusIndicatorState();
}

class _BudgetStatusIndicatorState extends State<BudgetStatusIndicator> {

  Color _getStatusColor() {
    switch (widget.status) {
      case BudgetStatus.good:
        return AppColors.green;
      case BudgetStatus.warning:
        return AppColors.orange;
      case BudgetStatus.danger:
        return AppColors.red;
      case BudgetStatus.neutral:
        return AppColors.gray500;
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case BudgetStatus.good:
        return '¡Excelente!';
      case BudgetStatus.warning:
        return 'Atención';
      case BudgetStatus.danger:
        return 'Presupuesto excedido';
      case BudgetStatus.neutral:
        return 'Configura tu presupuesto';
    }
  }

  String _getStatusDescription() {
    switch (widget.status) {
      case BudgetStatus.good:
        return 'Ritmo de gastos saludable';
      case BudgetStatus.warning:
        return 'Cerca del límite de presupuesto';
      case BudgetStatus.danger:
        return 'Has excedido el presupuesto';
      case BudgetStatus.neutral:
        return 'Configura tu presupuesto';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case BudgetStatus.good:
        return Icons.check_circle;
      case BudgetStatus.warning:
        return Icons.warning;
      case BudgetStatus.danger:
        return Icons.error;
      case BudgetStatus.neutral:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Días restantes (número)
          SizedBox(
            width: 32,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.daysRemaining.clamp(0, 99).toString(),
                  style: AppTextStyles.caption(color: AppColors.white).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          AppSpacing.horizontalSm,
          // Etiquetas compactas (se adaptan al ancho disponible)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(color: statusColor).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'días restantes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




