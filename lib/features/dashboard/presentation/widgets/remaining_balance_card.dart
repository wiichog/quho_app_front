import 'package:flutter/material.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/core/utils/formatters.dart';

class RemainingBalanceCard extends StatefulWidget {
  final double remainingForMonth;
  final int daysRemaining;
  final double balance;

  const RemainingBalanceCard({
    super.key,
    required this.remainingForMonth,
    required this.daysRemaining,
    required this.balance,
  });

  @override
  State<RemainingBalanceCard> createState() => _RemainingBalanceCardState();
}

class _RemainingBalanceCardState extends State<RemainingBalanceCard> {

  @override
  Widget build(BuildContext context) {
    // Calcular gasto diario, si es negativo mostrar cero
    final rawDailyBudget = widget.daysRemaining > 0 ? widget.remainingForMonth / widget.daysRemaining : 0.0;
    final dailyBudget = rawDailyBudget > 0 ? rawDailyBudget : 0.0; // lo mostrado
    
    // DEBUG: Imprimir valores para diagnóstico
    print('🔵 [RemainingBalanceCard] balance: ${widget.balance}');
    print('🔵 [RemainingBalanceCard] dailyBudget (mostrado): $dailyBudget');
    
    // Lógica: El color se basa en el BALANCE DISPONIBLE
    const epsilon = 0.01;
    final bool isNegativeBalance = widget.balance < -epsilon; // Balance negativo → ROJO
    final bool isNeutral = widget.balance >= -epsilon && widget.balance <= epsilon; // Balance cero → GRIS
    final bool isPositive = widget.balance > epsilon; // Balance positivo → VERDE
    final bool hasRealDeficit = rawDailyBudget < -epsilon; // Para el mensaje explicativo
    final remainingAbs = widget.remainingForMonth.abs();
    
    print('🔵 [RemainingBalanceCard] isNegativeBalance: $isNegativeBalance, isNeutral: $isNeutral, isPositive: $isPositive');

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
                      'Para sobrevivir el mes',
                      style: AppTextStyles.caption(
                        color: AppColors.gray700,
                      ),
                    ),
                    Text(
                      '${widget.daysRemaining} días restantes',
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
              const Icon(Icons.speed, size: 12, color: AppColors.gray600),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  hasRealDeficit
                      ? 'Con tu ritmo de gasto planificado, te faltan ${Formatters.currency(remainingAbs)} este mes.'
                      : (isNeutral
                          ? 'Con tu ritmo de gasto planificado, hoy no hay margen diario.'
                          : 'Si mantienes tu ritmo de gasto planificado, te sobrarán ${Formatters.currency(widget.remainingForMonth)} este mes.'),
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
        ],
      ),
    );
  }
}

