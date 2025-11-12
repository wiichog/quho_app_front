import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/core/utils/formatters.dart';

class RemainingBalanceCard extends StatefulWidget {
  final double remainingForMonth;
  final int daysRemaining;
  final double balance;
  final double theoreticalIncome;
  final double theoreticalExpenses;
  final double actualIncome;
  final double actualExpenses;
  final double totalSavings;
  final int daysInMonth;

  const RemainingBalanceCard({
    super.key,
    required this.remainingForMonth,
    required this.daysRemaining,
    required this.balance,
    required this.theoreticalIncome,
    required this.theoreticalExpenses,
    required this.actualIncome,
    required this.actualExpenses,
    required this.totalSavings,
    required this.daysInMonth,
  });

  @override
  State<RemainingBalanceCard> createState() => _RemainingBalanceCardState();
}

class _RemainingBalanceCardState extends State<RemainingBalanceCard> {
  void _showBreakdownModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DailyBudgetBreakdownModal(
        remainingForMonth: widget.remainingForMonth,
        daysRemaining: widget.daysRemaining,
        balance: widget.balance,
        theoreticalIncome: widget.theoreticalIncome,
        theoreticalExpenses: widget.theoreticalExpenses,
        actualIncome: widget.actualIncome,
        actualExpenses: widget.actualExpenses,
        totalSavings: widget.totalSavings,
        daysInMonth: widget.daysInMonth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcular gasto diario, si es negativo mostrar cero
    final rawDailyBudget = widget.daysRemaining > 0 ? widget.remainingForMonth / widget.daysRemaining : 0.0;
    final dailyBudget = rawDailyBudget > 0 ? rawDailyBudget : 0.0; // lo mostrado
    
    // DEBUG: Imprimir valores para diagnóstico
    print('[RemainingBalanceCard] balance: ${widget.balance}');
    print('[RemainingBalanceCard] dailyBudget (mostrado): $dailyBudget');
    
    // Lógica: El color se basa en el BALANCE DISPONIBLE
    const epsilon = 0.01;
    final bool isNegativeBalance = widget.balance < -epsilon; // Balance negativo → ROJO
    final bool isNeutral = widget.balance >= -epsilon && widget.balance <= epsilon; // Balance cero → GRIS
    final bool isPositive = widget.balance > epsilon; // Balance positivo → VERDE
    final bool hasRealDeficit = rawDailyBudget < -epsilon; // Para el mensaje explicativo
    final remainingAbs = widget.remainingForMonth.abs();
    
    print('[RemainingBalanceCard] isNegativeBalance: $isNegativeBalance, isNeutral: $isNeutral, isPositive: $isPositive');

    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: isNegativeBalance
            ? AppColors.redLight
            : (isNeutral ? AppColors.gray100 : AppColors.tealPale),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isNegativeBalance
              ? AppColors.red.withOpacity(0.3)
              : (isNeutral ? AppColors.gray300 : AppColors.teal.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isNegativeBalance
                      ? AppColors.red.withOpacity(0.2)
                      : (isNeutral ? AppColors.gray300 : AppColors.teal.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isNegativeBalance
                      ? Icons.trending_down
                      : (isNeutral ? Icons.trending_flat : Icons.trending_up),
                  color: isNegativeBalance
                      ? AppColors.red
                      : (isNeutral ? AppColors.gray600 : AppColors.teal),
                  size: 16,
                ),
              ),
              AppSpacing.horizontalSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Ritmo de gasto sugerido',
                    style: AppTextStyles.caption(
                      color: AppColors.gray700,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Para los próximos ${widget.daysRemaining} días',
                    style: AppTextStyles.caption(
                      color: AppColors.gray600,
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalXs,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Puedes gastar ${Formatters.currency(dailyBudget)} / día',
              style: AppTextStyles.h2(
                color: isNegativeBalance
                    ? AppColors.red
                    : (isNeutral ? AppColors.gray700 : AppColors.teal),
              ).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          AppSpacing.verticalXxs,
          // Explicación clara en lenguaje natural
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                hasRealDeficit ? Icons.warning : Icons.info_outline, 
                size: 12, 
                color: hasRealDeficit ? AppColors.red : AppColors.gray600
              ),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  hasRealDeficit
                      ? 'Según tus gastos presupuestados, te faltarían ${Formatters.currency(remainingAbs)}. Considera reducir gastos.'
                      : (isNeutral
                          ? 'Ya has alcanzado tu presupuesto del mes. Evita nuevos gastos.'
                          : 'Si respetas tu presupuesto, te sobrarán ${Formatters.currency(widget.remainingForMonth)} al final del mes.'),
                  style: AppTextStyles.caption(
                    color: hasRealDeficit
                        ? AppColors.red
                        : AppColors.gray700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.verticalXs,
          // Botón "¿Quieres saber por qué?"
          TextButton.icon(
            onPressed: () => _showBreakdownModal(context),
            icon: Icon(
              Icons.help_outline,
              size: 14,
              color: AppColors.teal,
            ),
            label: Text(
              '¿Quieres saber por qué?',
              style: AppTextStyles.caption(
                color: AppColors.teal,
              ).copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal que muestra el desglose del presupuesto diario
class _DailyBudgetBreakdownModal extends StatelessWidget {
  final double remainingForMonth;
  final int daysRemaining;
  final double balance;
  final double theoreticalIncome;
  final double theoreticalExpenses;
  final double actualIncome;
  final double actualExpenses;
  final double totalSavings;
  final int daysInMonth;

  const _DailyBudgetBreakdownModal({
    required this.remainingForMonth,
    required this.daysRemaining,
    required this.balance,
    required this.theoreticalIncome,
    required this.theoreticalExpenses,
    required this.actualIncome,
    required this.actualExpenses,
    required this.totalSavings,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculos del desglose
    final rawDailyBudget = daysRemaining > 0 ? remainingForMonth / daysRemaining : 0.0;
    final dailyBudget = rawDailyBudget > 0 ? rawDailyBudget : 0.0;
    
    // Cálculo del gasto diario teórico
    final dailyTheoreticalExpense = daysInMonth > 0 ? theoreticalExpenses / daysInMonth : 0.0;
    final projectedExpenseRemaining = dailyTheoreticalExpense * daysRemaining;
    
    // Balance calculado
    final calculatedBalance = actualIncome - actualExpenses - totalSavings;
    
    // Diferencia entre teórico y real
    final incomeDifference = actualIncome - theoreticalIncome;
    final expenseDifference = actualExpenses - theoreticalExpenses;
    
    // Explicación del cálculo
    final hasDeficit = remainingForMonth < 0;
    final deficitAmount = remainingForMonth.abs();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Desglose del Presupuesto Diario',
                    style: AppTextStyles.h4(),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray600,
                  ),
                ],
              ),
              AppSpacing.verticalMd,
              
              // Resumen principal
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.tealPale,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puedes gastar ${Formatters.currency(dailyBudget)} / día',
                      style: AppTextStyles.h3(
                        color: AppColors.teal,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'Para los próximos $daysRemaining días',
                      style: AppTextStyles.bodySmall(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.verticalLg,
              
              // Explicación del cálculo
              Text(
                '¿Cómo se calcula?',
                style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
              ),
              AppSpacing.verticalSm,
              
              // Paso 1: Balance disponible
              _BreakdownRow(
                label: 'Balance disponible',
                value: Formatters.currency(balance),
                explanation: 'Ingresos reales - Gastos reales - Ahorros',
                isPositive: balance >= 0,
              ),
              AppSpacing.verticalXs,
              _BreakdownRow(
                label: '  • Ingresos reales',
                value: Formatters.currency(actualIncome),
                explanation: null,
                isPositive: true,
                isSubItem: true,
              ),
              AppSpacing.verticalXxs,
              _BreakdownRow(
                label: '  • Gastos reales',
                value: '-${Formatters.currency(actualExpenses)}',
                explanation: null,
                isPositive: false,
                isSubItem: true,
              ),
              AppSpacing.verticalXxs,
              _BreakdownRow(
                label: '  • Ahorros',
                value: '-${Formatters.currency(totalSavings)}',
                explanation: null,
                isPositive: false,
                isSubItem: true,
              ),
              
              AppSpacing.verticalSm,
              
              // Paso 2: Gasto proyectado restante
              _BreakdownRow(
                label: 'Gasto proyectado restante',
                value: Formatters.currency(projectedExpenseRemaining),
                explanation: 'Gasto diario teórico × Días restantes',
                isPositive: false,
              ),
              AppSpacing.verticalXs,
              _BreakdownRow(
                label: '  • Gasto diario teórico',
                value: Formatters.currency(dailyTheoreticalExpense),
                explanation: 'Presupuesto mensual ÷ $daysInMonth días',
                isPositive: false,
                isSubItem: true,
              ),
              AppSpacing.verticalXxs,
              _BreakdownRow(
                label: '  • Días restantes',
                value: '$daysRemaining días',
                explanation: null,
                isPositive: true,
                isSubItem: true,
              ),
              
              AppSpacing.verticalSm,
              
              // Paso 3: Resultado
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: hasDeficit ? AppColors.redLight : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasDeficit ? 'Te faltan' : 'Te sobran',
                            style: AppTextStyles.bodySmall(
                              color: hasDeficit ? AppColors.red : AppColors.green,
                            ),
                          ),
                          Text(
                            Formatters.currency(hasDeficit ? deficitAmount : remainingForMonth),
                            style: AppTextStyles.h5(
                              color: hasDeficit ? AppColors.red : AppColors.green,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      hasDeficit ? Icons.warning : Icons.check_circle,
                      color: hasDeficit ? AppColors.red : AppColors.green,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.verticalLg,
              
              // Información adicional
              if (incomeDifference.abs() > 0.01 || expenseDifference.abs() > 0.01) ...[
                Text(
                  'Diferencias vs. Presupuesto',
                  style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.verticalSm,
                if (incomeDifference.abs() > 0.01)
                  _BreakdownRow(
                    label: 'Diferencia en ingresos',
                    value: Formatters.currency(incomeDifference.abs()),
                    explanation: incomeDifference > 0 
                        ? 'Has recibido más de lo presupuestado'
                        : 'Has recibido menos de lo presupuestado',
                    isPositive: incomeDifference > 0,
                  ),
                if (expenseDifference.abs() > 0.01) ...[
                  AppSpacing.verticalXs,
                  _BreakdownRow(
                    label: 'Diferencia en gastos',
                    value: Formatters.currency(expenseDifference.abs()),
                    explanation: expenseDifference > 0 
                        ? 'Has gastado más de lo presupuestado'
                        : 'Has gastado menos de lo presupuestado',
                    isPositive: expenseDifference < 0,
                  ),
                ],
                AppSpacing.verticalLg,
              ],
              
              // Botón de cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Entendido'),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final String? explanation;
  final bool isPositive;
  final bool isSubItem;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.explanation,
    required this.isPositive,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: isSubItem
                    ? AppTextStyles.bodySmall(color: AppColors.gray600)
                    : AppTextStyles.bodyMedium(color: AppColors.gray900),
              ),
            ),
            Text(
              value,
              style: (isSubItem
                      ? AppTextStyles.bodySmall(color: AppColors.gray700)
                      : AppTextStyles.bodyMedium(color: AppColors.gray900))
                  .copyWith(
                fontWeight: isSubItem ? FontWeight.normal : FontWeight.w600,
                color: isSubItem
                    ? AppColors.gray700
                    : (isPositive ? AppColors.green : AppColors.red),
              ),
            ),
          ],
        ),
        if (explanation != null) ...[
          AppSpacing.verticalXxs,
          Padding(
            padding: EdgeInsets.only(left: isSubItem ? 16 : 0),
            child: Text(
              explanation!,
              style: AppTextStyles.caption(color: AppColors.gray600),
            ),
          ),
        ],
      ],
    );
  }
}

