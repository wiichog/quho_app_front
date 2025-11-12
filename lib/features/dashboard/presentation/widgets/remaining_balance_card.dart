import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_event.dart';
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
      builder: (modalContext) => _DailyBudgetBreakdownModal(
        remainingForMonth: widget.remainingForMonth,
        daysRemaining: widget.daysRemaining,
        balance: widget.balance,
        theoreticalIncome: widget.theoreticalIncome,
        theoreticalExpenses: widget.theoreticalExpenses,
        actualIncome: widget.actualIncome,
        actualExpenses: widget.actualExpenses,
        totalSavings: widget.totalSavings,
        daysInMonth: widget.daysInMonth,
        parentContext: context, // Pasar el context del dashboard para recargar
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
class _DailyBudgetBreakdownModal extends StatefulWidget {
  final double remainingForMonth;
  final int daysRemaining;
  final double balance;
  final double theoreticalIncome;
  final double theoreticalExpenses;
  final double actualIncome;
  final double actualExpenses;
  final double totalSavings;
  final int daysInMonth;
  final BuildContext parentContext;

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
    required this.parentContext,
  });

  @override
  State<_DailyBudgetBreakdownModal> createState() => _DailyBudgetBreakdownModalState();
}

class _DailyBudgetBreakdownModalState extends State<_DailyBudgetBreakdownModal> {
  List<FixedExpenseModel>? _fixedExpenses;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFixedExpenses();
  }

  Future<void> _loadFixedExpenses() async {
    try {
      final datasource = getIt<DashboardRemoteDataSource>();
      final expenses = await datasource.getFixedExpenses();
      setState(() {
        _fixedExpenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar gastos fijos: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleExpenseStatus(FixedExpenseModel expense, String action) async {
    try {
      final datasource = getIt<DashboardRemoteDataSource>();
      await datasource.toggleFixedExpenseStatus(
        fixedExpenseId: expense.id,
        action: action,
      );
      
      // Recargar gastos fijos para actualizar el estado
      await _loadFixedExpenses();
      
      // Recargar el dashboard del parent context
      if (widget.parentContext.mounted) {
        widget.parentContext.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar estado: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Widget _buildFixedExpenseItem(FixedExpenseModel expense) {
    final tracking = expense.tracking;
    final isIgnored = tracking?.isIgnored ?? false;
    final isClosed = tracking?.isClosed ?? false;
    final remaining = tracking?.remainingAmount ?? expense.amount;
    final spent = tracking?.spentAmount ?? 0.0;
    
    Color statusColor = AppColors.gray600;
    String statusText = 'Pendiente';
    IconData statusIcon = Icons.pending_outlined;
    
    if (isIgnored) {
      statusColor = AppColors.gray500;
      statusText = 'Ignorado';
      statusIcon = Icons.visibility_off;
    } else if (isClosed) {
      statusColor = AppColors.green;
      statusText = 'Completado';
      statusIcon = Icons.check_circle;
    } else if (remaining <= 0) {
      statusColor = AppColors.green;
      statusText = 'Pagado';
      statusIcon = Icons.check_circle_outline;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: isIgnored || isClosed ? AppColors.gray50 : AppColors.white,
        border: Border.all(
          color: isIgnored || isClosed ? AppColors.gray300 : AppColors.teal.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              AppSpacing.horizontalXs,
              Expanded(
                child: Text(
                  expense.name,
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isIgnored || isClosed ? TextDecoration.lineThrough : null,
                    color: isIgnored || isClosed ? AppColors.gray600 : AppColors.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.caption(color: statusColor).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalXxs,
          Row(
            children: [
              Expanded(
                child: Text(
                  'Presupuestado: ${Formatters.currency(expense.amount)}',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                ),
              ),
              if (!isIgnored && !isClosed) ...[
                Text(
                  'Pendiente: ${Formatters.currency(remaining)}',
                  style: AppTextStyles.caption(color: AppColors.red).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (spent > 0) ...[
            AppSpacing.verticalXxs,
            Text(
              'Gastado: ${Formatters.currency(spent)}',
              style: AppTextStyles.caption(color: AppColors.gray600),
            ),
          ],
          AppSpacing.verticalXs,
          Row(
            children: [
              if (!isIgnored)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleExpenseStatus(expense, 'ignore'),
                    icon: Icon(Icons.visibility_off, size: 14),
                    label: Text('Ignorar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray700,
                      side: BorderSide(color: AppColors.gray300),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
              if (isIgnored) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleExpenseStatus(expense, 'reset'),
                    icon: Icon(Icons.refresh, size: 14),
                    label: Text('Restaurar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: BorderSide(color: AppColors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
              ],
              if (!isIgnored) ...[
                AppSpacing.horizontalSm,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleExpenseStatus(expense, 'complete'),
                    icon: Icon(isClosed ? Icons.undo : Icons.check, size: 14),
                    label: Text(isClosed ? 'Desmarcar' : 'Completar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClosed ? AppColors.gray600 : AppColors.green,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcular gastos fijos pendientes (no ignorados ni completados)
    double pendingFixedExpenses = 0.0;
    final pendingExpensesList = <FixedExpenseModel>[];
    
    if (_fixedExpenses != null) {
      for (final expense in _fixedExpenses!) {
        final tracking = expense.tracking;
        // Solo contar gastos que NO estén ignorados NI completados
        if (tracking != null && !tracking.isIgnored && !tracking.isClosed) {
          final remaining = tracking.remainingAmount;
          if (remaining > 0) {
            pendingFixedExpenses += remaining;
            pendingExpensesList.add(expense);
          }
        } else if (tracking == null) {
          // Si no hay tracking, contar el monto completo
          pendingFixedExpenses += expense.amount;
          pendingExpensesList.add(expense);
        }
      }
    }
    
    // CÁLCULO CORRECTO: Balance - Gastos fijos pendientes / Días restantes
    final availableAfterFixedExpenses = widget.balance - pendingFixedExpenses;
    final dailyBudget = widget.daysRemaining > 0 
        ? (availableAfterFixedExpenses / widget.daysRemaining).clamp(0.0, double.infinity)
        : 0.0;
    
    final hasDeficit = availableAfterFixedExpenses < 0;

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
              
              // Mostrar loading o error si aplica
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.teal),
                  ),
                )
              else if (_error != null)
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: AppColors.red),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodySmall(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Resumen principal
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: hasDeficit ? AppColors.redLight : AppColors.tealPale,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: (hasDeficit ? AppColors.red : AppColors.teal).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puedes gastar ${Formatters.currency(dailyBudget)} / día',
                        style: AppTextStyles.h3(
                          color: hasDeficit ? AppColors.red : AppColors.teal,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        'Para los próximos ${widget.daysRemaining} días',
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
                  label: '1. Balance disponible',
                  value: Formatters.currency(widget.balance),
                  explanation: 'Tu dinero actual en cuenta',
                  isPositive: widget.balance >= 0,
                ),
                
                AppSpacing.verticalMd,
                
                // Paso 2: Gastos fijos pendientes
                Text(
                  '2. Gastos fijos pendientes',
                  style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Gastos que aún no has completado este mes',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                ),
                AppSpacing.verticalSm,
                
                // Lista de gastos fijos
                if (_fixedExpenses != null && _fixedExpenses!.isNotEmpty) ...[
                  ...(_fixedExpenses!.map((expense) => _buildFixedExpenseItem(expense))),
                  AppSpacing.verticalXs,
                  Divider(color: AppColors.gray300),
                  AppSpacing.verticalXs,
                  _BreakdownRow(
                    label: 'Total gastos fijos pendientes',
                    value: Formatters.currency(pendingFixedExpenses),
                    explanation: null,
                    isPositive: false,
                  ),
                ] else
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      'No tienes gastos fijos configurados',
                      style: AppTextStyles.bodySmall(color: AppColors.gray600),
                    ),
                  ),
                
                AppSpacing.verticalMd,
                
                // Paso 3: Resultado
                Text(
                  '3. Presupuesto diario disponible',
                  style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Balance - Gastos fijos pendientes ÷ ${widget.daysRemaining} días',
                  style: AppTextStyles.caption(color: AppColors.gray600),
                ),
                AppSpacing.verticalSm,
                
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: hasDeficit ? AppColors.redLight : AppColors.greenLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: (hasDeficit ? AppColors.red : AppColors.green).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasDeficit 
                                      ? 'Déficit: Te faltan' 
                                      : 'Disponible después de gastos fijos',
                                  style: AppTextStyles.bodySmall(
                                    color: hasDeficit ? AppColors.red : AppColors.green,
                                  ),
                                ),
                                Text(
                                  Formatters.currency(availableAfterFixedExpenses.abs()),
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
                            size: 32,
                          ),
                        ],
                      ),
                      if (hasDeficit) ...[
                        AppSpacing.verticalSm,
                        Text(
                          'Considera ignorar o ajustar algunos gastos fijos para mejorar tu presupuesto diario',
                          style: AppTextStyles.caption(color: AppColors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                
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

