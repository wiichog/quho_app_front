import 'package:flutter/material.dart';
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

class BudgetStatusIndicator extends StatelessWidget {
  final BudgetStatus status;
  final double monthProgress;

  const BudgetStatusIndicator({
    super.key,
    required this.status,
    required this.monthProgress,
  });

  Color _getStatusColor() {
    switch (status) {
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
    switch (status) {
      case BudgetStatus.good:
        return '¡Vas muy bien!';
      case BudgetStatus.warning:
        return 'Ten cuidado';
      case BudgetStatus.danger:
        return '¡Alerta!';
      case BudgetStatus.neutral:
        return 'Sin datos';
    }
  }

  String _getStatusDescription() {
    switch (status) {
      case BudgetStatus.good:
        return 'Estás gastando menos de lo esperado';
      case BudgetStatus.warning:
        return 'Estás en el límite del presupuesto';
      case BudgetStatus.danger:
        return 'Has excedido tu presupuesto';
      case BudgetStatus.neutral:
        return 'Agrega datos para ver tu estado';
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
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
      padding: AppSpacing.paddingLg,
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              color: AppColors.white,
              size: 28,
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: AppTextStyles.h5(color: statusColor).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  _getStatusDescription(),
                  style: AppTextStyles.bodySmall(color: AppColors.gray700),
                ),
                AppSpacing.verticalXs,
                LinearProgressIndicator(
                  value: monthProgress,
                  backgroundColor: statusColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                AppSpacing.verticalXxs,
                Text(
                  '${(monthProgress * 100).toInt()}% del mes transcurrido',
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


