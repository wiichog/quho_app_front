import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_bloc.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_event.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_state.dart';
import 'package:quho_app/features/finances/presentation/widgets/financial_kpi_card.dart';
import 'package:quho_app/features/finances/presentation/widgets/comparison_metric_card.dart';
import 'package:quho_app/features/finances/presentation/widgets/financial_health_score.dart';
import 'package:quho_app/features/finances/presentation/widgets/ideal_budget_pie_chart.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';
import 'package:quho_app/shared/design_system/spacing/app_spacing.dart';

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final now = DateTime.now();
        final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        return getIt<FinancesBloc>()..add(LoadFinancesOverviewEvent(month: month));
      },
      child: const _FinancesPageContent(),
    );
  }
}

class _FinancesPageContent extends StatefulWidget {
  const _FinancesPageContent();

  @override
  State<_FinancesPageContent> createState() => _FinancesPageContentState();
}

class _FinancesPageContentState extends State<_FinancesPageContent> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _currentMonth => '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';

  String get _monthLabel {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
    context.read<FinancesBloc>().add(LoadFinancesOverviewEvent(month: _currentMonth));
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
    context.read<FinancesBloc>().add(LoadFinancesOverviewEvent(month: _currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: BlocBuilder<FinancesBloc, FinancesState>(
        builder: (context, state) {
          if (state is FinancesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FinancesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar finanzas',
                    style: AppTextStyles.h4(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium().copyWith(color: AppColors.gray600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is FinancesLoaded) {
            return _FinancesLoadedContent(
              overview: state.overview,
              monthLabel: _monthLabel,
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // Finanzas está seleccionado
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Finanzas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 2) {
          context.push(RouteNames.profile);
        }
      },
    );
  }
}

class _FinancesLoadedContent extends StatelessWidget {
  final FinancesOverview overview;
  final String monthLabel;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _FinancesLoadedContent({
    required this.overview,
    required this.monthLabel,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// Calculate financial health score (0-100)
  double _calculateHealthScore() {
    double score = 100.0;
    
    // Penalize if expenses exceed income
    final incomeVsExpenses = overview.summary.execution.income > 0
        ? (overview.summary.execution.expenses / overview.summary.execution.income)
        : 1.0;
    if (incomeVsExpenses > 0.9) score -= 20; // Spending > 90% of income
    if (incomeVsExpenses > 1.0) score -= 30; // Spending more than income
    
    // Reward if savings target is met
    final savingsTarget = overview.summary.ideal.savingsTarget ?? 0;
    final actualNet = overview.summary.execution.net ?? 0;
    if (savingsTarget > 0 && actualNet >= savingsTarget) {
      score += 10;
    } else if (savingsTarget > 0) {
      final savingsRate = actualNet / savingsTarget;
      if (savingsRate < 0.5) score -= 20;
    }
    
    // Penalize overspending in categories
    int overBudgetCount = overview.categoryBreakdown.where((c) => c.isOverBudget).length;
    score -= (overBudgetCount * 10.0);
    
    return score.clamp(0, 100);
  }

  String _getHealthDescription() {
    final score = _calculateHealthScore();
    if (score >= 80) return 'Tu situación financiera es excelente. Sigue así!';
    if (score >= 60) return 'Tienes una buena gestión financiera. Pequeños ajustes la mejorarán.';
    if (score >= 40) return 'Tu situación es estable pero hay áreas de mejora.';
    return 'Tu situación financiera necesita atención inmediata.';
  }

  /// Calculate burn rate (days until money runs out)
  int _calculateDaysOfSolvency() {
    final balance = overview.summary.execution.net ?? 0;
    if (balance <= 0) return 0;
    
    final avgDailyExpense = overview.summary.execution.expenses / DateTime.now().day;
    if (avgDailyExpense <= 0) return 999; // Infinite
    
    return (balance / avgDailyExpense).floor();
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = _calculateHealthScore();
    final daysOfSolvency = _calculateDaysOfSolvency();
    
    // Calculate execution rate
    final budgetExecutionRate = overview.summary.ideal.totalBudgeted != null && overview.summary.ideal.totalBudgeted! > 0
        ? (overview.summary.execution.expenses / overview.summary.ideal.totalBudgeted! * 100)
        : 0.0;
    
    // Calculate savings rate
    final actualNet = overview.summary.execution.net ?? 0;
    final savingsTarget = overview.summary.ideal.savingsTarget ?? 0;
    final savingsRate = savingsTarget > 0 ? (actualNet / savingsTarget * 100) : 0.0;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 140,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Profile menu
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  final user = authState.user;
                  final initials = '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
                  
                  return PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.teal,
                        child: Text(
                          initials,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.white,
                          ).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: AppColors.red),
                            const SizedBox(width: 8),
                            const Text('Cerrar sesión'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') {
                        _showLogoutDialog(context);
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 56, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Análisis Financiero', style: AppTextStyles.h3()),
                  const SizedBox(height: 8),
                  // Month selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: AppColors.gray700),
                        onPressed: onPreviousMonth,
                        splashRadius: 24,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          monthLabel,
                          style: AppTextStyles.bodyLarge().copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: AppColors.gray700),
                        onPressed: onNextMonth,
                        splashRadius: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ============ SECTION 1: Financial Health Score ============
              FinancialHealthScore(
                score: healthScore,
                description: _getHealthDescription(),
              ),
              AppSpacing.verticalMd,

              // ============ SECTION 2: Key Metrics ============
              Text(
                'Métricas Clave',
                style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              
              // KPI Row 1
              Row(
                children: [
                  Expanded(
                    child: FinancialKpiCard(
                      title: 'Ejecución Presup.',
                      value: '${budgetExecutionRate.toStringAsFixed(0)}%',
                      subtitle: 'del presupuesto',
                      icon: Icons.pie_chart,
                      iconColor: budgetExecutionRate > 100 ? AppColors.red : AppColors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FinancialKpiCard(
                      title: 'Tasa de Ahorro',
                      value: '${savingsRate.toStringAsFixed(0)}%',
                      subtitle: 'de la meta',
                      icon: Icons.savings,
                      iconColor: savingsRate >= 100 ? AppColors.green : AppColors.orange,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSm,
              
              // KPI Row 2
              Row(
                children: [
                  Expanded(
                    child: FinancialKpiCard(
                      title: 'Balance Neto',
                      value: Formatters.currency(actualNet),
                      subtitle: actualNet >= 0 ? 'Superávit' : 'Déficit',
                      icon: actualNet >= 0 ? Icons.trending_up : Icons.trending_down,
                      iconColor: actualNet >= 0 ? AppColors.green : AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FinancialKpiCard(
                      title: 'Días de Solvencia',
                      value: daysOfSolvency >= 999 ? '∞' : '$daysOfSolvency',
                      subtitle: 'días cubiertos',
                      icon: Icons.calendar_today,
                      iconColor: daysOfSolvency > 30 
                          ? AppColors.green 
                          : (daysOfSolvency > 15 ? AppColors.orange : AppColors.red),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,

              // ============ SECTION 3: Comparison Teórico vs Real ============
              Text(
                'Presupuesto vs Ejecución',
                style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              
              // Income comparison
              ComparisonMetricCard(
                title: 'Ingresos',
                theoretical: overview.summary.ideal.income,
                actual: overview.summary.execution.income,
                icon: Icons.arrow_upward,
                higherIsBetter: true,
              ),
              AppSpacing.verticalSm,
              
              // Expenses comparison
              ComparisonMetricCard(
                title: 'Gastos',
                theoretical: overview.summary.ideal.expenses,
                actual: overview.summary.execution.expenses,
                icon: Icons.arrow_downward,
                higherIsBetter: false,
              ),
              AppSpacing.verticalSm,
              
              // Savings comparison
              ComparisonMetricCard(
                title: 'Ahorro',
                theoretical: savingsTarget,
                actual: actualNet,
                icon: Icons.account_balance_wallet,
                higherIsBetter: true,
              ),
              AppSpacing.verticalMd,

              // ============ SECTION 4: Budget Distribution ============
              Text(
                'Distribución del Presupuesto',
                style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,
              IdealBudgetPieChart(categories: overview.idealBudgetBreakdown),
              AppSpacing.verticalMd,

              // ============ SECTION 5: Category Breakdown ============
              Text(
                'Desglose por Categoría',
                style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSm,

              // Sort categories: not at 100%, then at 100%, then negative
              ...(_sortCategories(overview.categoryBreakdown).map(
                (category) => _CategoryCard(category: category),
              )),
            ]),
          ),
        ),
      ],
    );
  }

  List<CategoryComparison> _sortCategories(List<CategoryComparison> categories) {
    final notAtLimit = categories.where((c) => !c.hasNoBudget && c.percentageUsed < 100).toList();
    final atLimit = categories.where((c) => !c.hasNoBudget && c.percentageUsed >= 100 && c.percentageUsed <= 100).toList();
    final overBudget = categories.where((c) => !c.hasNoBudget && c.percentageUsed > 100).toList();
    final noBudget = categories.where((c) => c.hasNoBudget).toList();
    
    // Sort each group by percentage
    notAtLimit.sort((a, b) => b.percentageUsed.compareTo(a.percentageUsed));
    overBudget.sort((a, b) => b.percentageUsed.compareTo(a.percentageUsed));
    
    return [...notAtLimit, ...atLimit, ...overBudget, ...noBudget];
  }
}

/// Category card with progress
class _CategoryCard extends StatelessWidget {
  final CategoryComparison category;

  const _CategoryCard({required this.category});

  IconData _getIconFromString(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'local_grocery_store': Icons.local_grocery_store,
      'shopping_cart': Icons.shopping_cart,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'sports_esports': Icons.sports_esports,
      'movie': Icons.movie,
      'flight': Icons.flight,
      'phone': Icons.phone,
      'bolt': Icons.bolt,
      'water_drop': Icons.water_drop,
      'wifi': Icons.wifi,
      'local_gas_station': Icons.local_gas_station,
      'credit_card': Icons.credit_card,
      'savings': Icons.savings,
      'more_horiz': Icons.more_horiz,
      'fastfood': Icons.fastfood,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _getStatusColor() {
    if (category.isOverBudget) return AppColors.red;
    if (category.isNearLimit) return AppColors.orange;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = category.percentageUsed.clamp(0, 150);

    return InkWell(
      onTap: () {
        // Navegar a transacciones con filtro de categoría usando el ID
        // El nombre se buscará cuando se cargue la página
        if (category.categoryId != null) {
          context.push('/home/transactions?category=${category.categoryId}&categoryName=${Uri.encodeComponent(category.category)}');
        } else {
          // Fallback a slug si no hay ID disponible
          context.push('/home/transactions?category=${category.slug}&categoryName=${Uri.encodeComponent(category.category)}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse('FF${category.color.substring(1)}', radix: 16)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconFromString(category.icon),
                  color: Color(int.parse('FF${category.color.substring(1)}', radix: 16)),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Category name and transactions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.category,
                      style: AppTextStyles.bodyLarge().copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (category.transactionCount > 0)
                      Text(
                        '${category.transactionCount} transacción${category.transactionCount > 1 ? 'es' : ''}',
                        style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
                      ),
                  ],
                ),
              ),

              // Status indicator
              if (!category.hasNoBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Indicador de que es clickeable
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          if (!category.hasNoBudget) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (category.percentageUsed / 100).clamp(0, 1),
                backgroundColor: AppColors.gray200,
                valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Amounts row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gastado',
                    style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
                  ),
                  Text(
                    Formatters.currency(category.spent),
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                      color: category.isOverBudget ? AppColors.red : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              if (!category.hasNoBudget) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Presupuestado',
                      style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
                    ),
                    Text(
                      Formatters.currency(category.budgeted),
                      style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Warning for over budget
          if (category.isOverBudget) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, size: 16, color: AppColors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Excediste tu presupuesto por ${Formatters.currency(category.spent - category.budgeted)}',
                      style: AppTextStyles.bodySmall().copyWith(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

/// Show logout confirmation dialog
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        '¿Cerrar sesión?',
        style: AppTextStyles.h4(),
      ),
      content: Text(
        '¿Estás seguro que deseas cerrar sesión?',
        style: AppTextStyles.bodyMedium(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.gray600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.read<AuthBloc>().add(LogoutEvent());
            context.go(RouteNames.login);
          },
          child: Text(
            'Cerrar sesión',
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
