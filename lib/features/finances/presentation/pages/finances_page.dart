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
import 'package:quho_app/features/finances/presentation/widgets/ideal_budget_pie_chart.dart';
import 'package:quho_app/features/finances/presentation/widgets/comparison_bar_chart.dart';
import 'package:quho_app/shared/design_system/colors/app_colors.dart';
import 'package:quho_app/shared/design_system/typography/app_text_styles.dart';

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
          icon: Icon(Icons.emoji_events_outlined),
          activeIcon: Icon(Icons.emoji_events),
          label: 'Desafíos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // Navegar a Dashboard
          Navigator.pop(context);
        } else if (index == 2) {
          context.push(RouteNames.gamification);
        } else if (index == 3) {
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

  @override
  Widget build(BuildContext context) {
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
                            Text('Cerrar sesión'),
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
                  Text('Finanzas', style: AppTextStyles.h3()),
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
              // Summary Cards
              _SummarySection(summary: overview.summary),
              const SizedBox(height: 24),

              // Pie Chart - Ideal Budget Breakdown
              IdealBudgetPieChart(categories: overview.idealBudgetBreakdown),
              const SizedBox(height: 24),

              // Bar Chart - Comparison
              ComparisonBarChart(categories: overview.categoryBreakdown),
              const SizedBox(height: 24),

              // Category Breakdown Title
              Text(
                'Desglose Detallado por Categoría',
                style: AppTextStyles.h4(),
              ),
              const SizedBox(height: 16),

              // Category Breakdown List
              ...overview.categoryBreakdown.map((category) => _CategoryCard(category: category)),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Summary section with ideal vs execution
class _SummarySection extends StatelessWidget {
  final FinancesSummary summary;

  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Income & Expenses Row
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Ingresos',
                ideal: summary.ideal.income,
                actual: summary.execution.income,
                delta: summary.delta.income,
                icon: Icons.trending_up,
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Gastos',
                ideal: summary.ideal.expenses,
                actual: summary.execution.expenses,
                delta: summary.delta.expenses,
                icon: Icons.trending_down,
                isPositive: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Savings Card
        _SavingsCard(
          savingsTarget: summary.ideal.savingsTarget ?? 0,
          actualSavings: summary.execution.net ?? 0,
          delta: summary.delta.savings,
        ),
      ],
    );
  }
}

/// Individual summary card
class _SummaryCard extends StatelessWidget {
  final String title;
  final double ideal;
  final double actual;
  final double delta;
  final IconData icon;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.ideal,
    required this.actual,
    required this.delta,
    required this.icon,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ideal > 0 ? ((actual / ideal) * 100) : 0;
    final isGood = isPositive ? (delta >= 0) : (delta <= 0);

    return Container(
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
              Icon(icon, size: 20, color: AppColors.gray600),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.currency(actual),
            style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'de ${Formatters.currency(ideal)}',
            style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isGood ? Icons.check_circle : Icons.warning,
                size: 14,
                color: isGood ? AppColors.green : AppColors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall().copyWith(
                  color: isGood ? AppColors.green : AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Savings card
class _SavingsCard extends StatelessWidget {
  final double savingsTarget;
  final double actualSavings;
  final double delta;

  const _SavingsCard({
    required this.savingsTarget,
    required this.actualSavings,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = savingsTarget > 0 ? ((actualSavings / savingsTarget) * 100) : 0;
    final isGood = delta >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.savings, color: AppColors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahorro',
                  style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray600),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(actualSavings),
                  style: AppTextStyles.h4().copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Meta: ${Formatters.currency(savingsTarget)}',
                  style: AppTextStyles.bodySmall().copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isGood ? Icons.trending_up : Icons.trending_down,
                size: 20,
                color: isGood ? AppColors.green : AppColors.red,
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.h5().copyWith(
                  color: isGood ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
    final percentage = category.percentageUsed.clamp(0, 100);

    return Container(
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
                    style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
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

          // No budget warning
          if (category.hasNoBudget) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sin presupuesto asignado',
                      style: AppTextStyles.bodySmall().copyWith(color: AppColors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
