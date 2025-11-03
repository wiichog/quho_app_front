import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/core/utils/helpers.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quho_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:quho_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/cards/transaction_card.dart';
import 'package:quho_app/shared/widgets/feedback/empty_state.dart';
import 'package:quho_app/shared/widgets/feedback/loading_indicator.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/editable_balance_card.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/remaining_balance_card.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/budget_status_indicator.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/category_breakdown_list.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/categorization_modal.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/new_income_source_modal.dart';
import 'package:quho_app/features/dashboard/presentation/widgets/category_selector_modal.dart';
import 'package:quho_app/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔵 [DASHBOARD_PAGE] Inicializando DashboardPage');
    return BlocProvider(
      create: (context) {
        print('🔵 [DASHBOARD_PAGE] Creando DashboardBloc y disparando LoadDashboardDataEvent');
        return getIt<DashboardBloc>()
          ..add(const LoadDashboardDataEvent());
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(const RefreshDashboardEvent());
            await Future.delayed(const Duration(seconds: 1));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const LoadingIndicator(
                  message: 'Cargando tu información financiera...',
                );
              }

              if (state is DashboardError) {
                print('❌ [DASHBOARD_PAGE] Mostrando error en UI: ${state.message}');
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Oops!',
                  message: state.message,
                  actionText: 'Reintentar',
                  onActionPressed: () {
                    print('🔵 [DASHBOARD_PAGE] Usuario presionó Reintentar');
                    context.read<DashboardBloc>().add(
                          const LoadDashboardDataEvent(),
                        );
                  },
                );
              }

              if (state is DashboardLoaded) {
                print('✅ [DASHBOARD_PAGE] Dashboard cargado, mostrando contenido');
                return _DashboardContent(state: state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
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
        if (index == 1) {
          // Navegar a Finanzas
          context.push(RouteNames.finances);
        } else if (index == 2) {
          context.push(RouteNames.gamification);
        } else if (index == 3) {
          context.push(RouteNames.profile);
        }
      },
    );
  }
}

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
            style: AppTextStyles.bodyMedium(color: AppColors.gray600),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.read<AuthBloc>().add(const LogoutEvent());
            context.go(RouteNames.login);
          },
          child: Text(
            'Cerrar sesión',
            style: AppTextStyles.bodyMedium(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  List<Transaction> _getPendingCategorizationTransactions() {
    // Usar las transacciones pendientes que vienen directamente del backend
    return state.pendingCategorizationTransactions;
  }

  void _showCategorizationModal(BuildContext context, Transaction transaction) async {
    // Si es un INGRESO, mostrar fuentes de ingreso en lugar de categorías
    if (transaction.isIncome) {
      await _showIncomeSourceSelector(context, transaction);
      return;
    }
    
    // Si es un GASTO, primero preguntar si corresponde a un gasto fijo presupuestado
    await _showFixedExpenseSelector(context, transaction);
  }

  Future<void> _showCategorySelector(BuildContext context, Transaction transaction) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    // Mostrar un loading dialog mientras cargamos las categorías
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      print('🔵 Obteniendo categorías...');
      
      // Obtener categorías
      final categories = await datasource.getCategories();
      print('✅ Categorías obtenidas: ${categories.length}');
      
      final categoryItems = categories.map((cat) {
        print('  - ${cat.displayName} (${cat.icon})');
        return CategoryItem(
          id: cat.id,
          name: cat.displayName,
          icon: cat.icon,
          color: cat.color,
        );
      }).toList();

      if (!context.mounted) {
        print('⚠️ Context no montado después de cargar categorías');
        return;
      }

      // Cerrar el loading dialog
      Navigator.of(context).pop();
      
      print('🔵 Mostrando modal con ${categoryItems.length} categorías');
      
      // Mostrar el modal de categorías
      await showDialog(
        context: context,
        builder: (context) => CategorySelectorModal(
          categories: categoryItems,
          onCategorySelected: (category, updateMerchant) async {
            print('✅ Categoría seleccionada: ${category.name} (ID: ${category.id})');
            await _categorizeTransaction(context, transaction.id, category.id, updateMerchant);
          },
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error al cargar categorías: $e');
      print('📚 StackTrace: $stackTrace');
      
      if (!context.mounted) return;
      
      // Cerrar el loading dialog si está abierto
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar categorías: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _categorizeTransaction(BuildContext context, String transactionId, int categoryId, bool updateMerchant) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    try {
      // Mostrar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categorizando transacción...')),
        );
      }

      // Categorizar
      await datasource.categorizeTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        updateMerchant: updateMerchant,
      );

      if (!context.mounted) return;

      // Recargar dashboard y esperar un momento para que se procese
      print('🔄 Recargando dashboard...');
      context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      
      // Pequeña pausa para dar tiempo al backend a procesar y al Bloc a recargar
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Dashboard recargado');
      
      if (!context.mounted) return;
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Transacción categorizada correctamente'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al categorizar: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _showIncomeSourceSelector(BuildContext context, Transaction transaction) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    // Mostrar un loading dialog mientras cargamos las fuentes de ingreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      print('🔵 Obteniendo fuentes de ingreso...');
      
      // Obtener fuentes de ingreso
      final incomeSources = await datasource.getIncomeSources();
      print('✅ Fuentes de ingreso obtenidas: ${incomeSources.length}');
      
      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (!context.mounted) {
        print('⚠️ Context no montado');
        return;
      }
      
      if (incomeSources.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes fuentes de ingreso configuradas'),
            backgroundColor: AppColors.orange,
          ),
        );
        return;
      }
      
      // Mostrar selector de fuentes de ingreso con opción "Otros"
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Selecciona el origen del ingreso',
            style: AppTextStyles.h4(),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: incomeSources.length + 1, // +1 para la opción "Otros"
              itemBuilder: (context, index) {
                // Última opción: "Otros"
                if (index == incomeSources.length) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: AppColors.green, size: 20),
                    ),
                    title: Text(
                      'Otros (Nueva fuente)',
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                    subtitle: Text(
                      'Crear nueva fuente de ingreso',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _showNewIncomeSourceForm(context, transaction);
                    },
                  );
                }
                
                // Fuentes existentes
                final source = incomeSources[index];
                return ListTile(
                  leading: Icon(Icons.work, color: AppColors.green),
                  title: Text(
                    source.name,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${Formatters.currency(source.amount)} - ${source.frequency}',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  trailing: Icon(Icons.check_circle_outline, color: AppColors.gray500),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _categorizeIncomeTransaction(context, transaction.id, source.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.bodyMedium().copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('❌ Error obteniendo fuentes de ingreso: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener fuentes de ingreso: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _showFixedExpenseSelector(BuildContext context, Transaction transaction) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    // Mostrar un loading dialog mientras cargamos los gastos fijos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      print('🔵 Obteniendo gastos fijos...');
      
      // Obtener gastos fijos
      final fixedExpenses = await datasource.getFixedExpenses();
      print('✅ Gastos fijos obtenidos: ${fixedExpenses.length}');
      
      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (!context.mounted) {
        print('⚠️ Context no montado');
        return;
      }
      
      // Si NO hay gastos fijos, mostrar directamente el modal de categorías genéricas
      if (fixedExpenses.isEmpty) {
        await _showStandardCategorizationModal(context, transaction);
        return;
      }
      
      // Mostrar selector de gastos fijos con opción "Otros"
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            '¿Este gasto corresponde a un presupuesto fijo?',
            style: AppTextStyles.h4(),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: fixedExpenses.length + 1, // +1 para la opción "Otros"
              itemBuilder: (context, index) {
                // Última opción: "Otros" (no corresponde a gasto fijo)
                if (index == fixedExpenses.length) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.more_horiz, color: AppColors.gray600, size: 20),
                    ),
                    title: Text(
                      'No corresponde a ningún gasto fijo',
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                    subtitle: Text(
                      'Categorizar de forma libre',
                      style: AppTextStyles.bodySmall().copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _showStandardCategorizationModal(context, transaction);
                    },
                  );
                }
                
                // Gastos fijos existentes
                final expense = fixedExpenses[index];
                return ListTile(
                  leading: Icon(Icons.receipt_long, color: AppColors.red),
                  title: Text(
                    expense.name,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${expense.categoryName} • ${Formatters.currency(expense.amount)} - ${expense.frequency}',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  trailing: Icon(Icons.check_circle_outline, color: AppColors.gray500),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _categorizeExpenseTransaction(
                      context, 
                      transaction.id, 
                      expense.categoryId, 
                      expense.id,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.bodyMedium().copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
      );
      
    } catch (e) {
      print('❌ Error obteniendo gastos fijos: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener gastos fijos: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStandardCategorizationModal(BuildContext context, Transaction transaction) async {
    await showDialog(
      context: context,
      builder: (context) => CategorizationModal(
        transaction: transaction,
        onAcceptSuggestion: () async {
          Navigator.of(context).pop();
          if (transaction.suggestedCategory != null) {
            await _categorizeTransaction(context, transaction.id, transaction.suggestedCategory!.id, false);
          }
        },
        onBrowseCategories: () async {
          // NO cerramos el modal aún, primero cargamos las categorías
          await _showCategorySelector(context, transaction);
          // Ahora sí cerramos el modal de categorización
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Future<void> _showNewIncomeSourceForm(BuildContext context, Transaction transaction) async {
    await showDialog(
      context: context,
      builder: (context) => NewIncomeSourceModal(
        onSubmit: (name, amount, frequency, isNetAmount, taxContext) async {
          await _categorizeIncomeWithNewSource(
            context,
            transaction.id,
            name,
            amount,
            frequency,
            isNetAmount,
            taxContext,
          );
        },
      ),
    );
  }

  Future<void> _categorizeIncomeWithNewSource(
    BuildContext context,
    String transactionId,
    String name,
    double amount,
    String frequency,
    bool isNetAmount,
    String taxContext,
  ) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    try {
      // Mostrar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creando fuente de ingreso...')),
        );
      }

      // Crear fuente y categorizar
      await datasource.categorizeIncomeWithNewSource(
        transactionId: transactionId,
        name: name,
        amount: amount,
        frequency: frequency,
        isNetAmount: isNetAmount,
        taxContext: taxContext,
      );

      if (!context.mounted) return;

      // Recargar dashboard y esperar un momento para que se procese
      print('🔄 Recargando dashboard...');
      context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      
      // Pequeña pausa para dar tiempo al backend a procesar y al Bloc a recargar
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Dashboard recargado');
      
      if (!context.mounted) return;
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Nueva fuente "$name" creada y ingreso categorizado'),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear fuente de ingreso: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _categorizeIncomeTransaction(BuildContext context, String transactionId, int incomeSourceId) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    try {
      // Mostrar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categorizando ingreso...')),
        );
      }

      // Categorizar ingreso
      await datasource.categorizeIncomeTransaction(
        transactionId: transactionId,
        incomeSourceId: incomeSourceId,
      );

      if (!context.mounted) return;

      // Recargar dashboard y esperar un momento para que se procese
      print('🔄 Recargando dashboard...');
      context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      
      // Pequeña pausa para dar tiempo al backend a procesar y al Bloc a recargar
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Dashboard recargado');
      
      if (!context.mounted) return;
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ingreso categorizado correctamente'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al categorizar ingreso: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _categorizeExpenseTransaction(
    BuildContext context, 
    String transactionId, 
    int categoryId, 
    int fixedExpenseId,
  ) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    try {
      // Mostrar loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categorizando gasto...')),
        );
      }

      // Categorizar gasto vinculado a FixedExpense
      await datasource.categorizeTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        fixedExpenseId: fixedExpenseId,
        updateMerchant: false,
      );

      if (!context.mounted) return;

      // Recargar dashboard y esperar un momento para que se procese
      print('🔄 Recargando dashboard...');
      context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      
      // Pequeña pausa para dar tiempo al backend a procesar y al Bloc a recargar
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('✅ Dashboard recargado');
      
      if (!context.mounted) return;
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Gasto categorizado y vinculado al presupuesto'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al categorizar gasto: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = state.budgetSummary;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          floating: true,
          snap: true,
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Helpers.getGreeting(),
                      style: AppTextStyles.caption(),
                    ),
                    Text(
                      authState.user.firstName,
                      style: AppTextStyles.h4(),
                    ),
                  ],
                );
              }
              return const Text('Dashboard');
            },
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  final user = authState.user;
                  final initials = '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
                  
                  return PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: AppTextStyles.bodyMedium().copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: AppTextStyles.caption(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout, size: 20, color: AppColors.red),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Cerrar sesión',
                                style: AppTextStyles.bodyMedium(color: AppColors.red),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
        ),

        SliverPadding(
          padding: AppSpacing.screenPaddingHorizontalOnly,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AppSpacing.verticalLg,

              // Primera Fila: Balance Disponible, Ten Cuidado, Para Sobrevivir (3 columnas)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Disponible
                  Expanded(
                    child: EditableBalanceCard(
                      balance: budget.balance,
                      onEdit: () {
                        // TODO: Implementar edición
                      },
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Ten Cuidado (Estado del Presupuesto)
                  Expanded(
                    child: BudgetStatusIndicator(
                      status: budget.budgetStatus,
                      monthProgress: budget.monthProgress,
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Para Sobrevivir al Mes
                  Expanded(
                    child: RemainingBalanceCard(
                      remainingForMonth: budget.remainingForMonth,
                      daysRemaining: daysRemaining,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalXl,

              // Segunda Fila: Resumen y Últimas 3 Transacciones (2 columnas)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen
                  Expanded(
                    child: _QuickStatsCard(
                      actualIncome: budget.actualIncome,
                      actualExpenses: budget.actualExpenses,
                      theoreticalExpenses: budget.theoreticalExpenses,
                      monthProgress: budget.monthProgress,
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Últimas 3 Transacciones
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long, color: AppColors.teal, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Recientes', 
                                      style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(RouteNames.transactions);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ver Todas', 
                                    style: AppTextStyles.caption(color: AppColors.teal).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.teal),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        if (state.recentTransactions.isEmpty)
                          Container(
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 32,
                                  color: AppColors.gray400,
                                ),
                                AppSpacing.verticalSm,
                                Text(
                                  'Sin transacciones',
                                  style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Agrega tu primera transacción',
                                  style: AppTextStyles.caption(color: AppColors.gray500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ...state.recentTransactions.take(3).map((transaction) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TransactionCard(
                                title: transaction.description,
                                category: transaction.category,
                                amount: transaction.amount,
                                date: transaction.date,
                                isIncome: transaction.isIncome,
                                onTap: () {
                                  // TODO: Navegar a detalle
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalXl,

              // Tercera Fila: Gastos por Categoría y Transacciones por Categorizar (2 columnas)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gastos por Categoría
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, color: AppColors.teal, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Por Categoría', 
                                style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        CategoryBreakdownList(categories: budget.categoriesBreakdown),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Transacciones por Categorizar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined, 
                              color: _getPendingCategorizationTransactions().isEmpty 
                                ? AppColors.green 
                                : AppColors.orange, 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Por Categorizar', 
                                style: AppTextStyles.h5().copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_getPendingCategorizationTransactions().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_getPendingCategorizationTransactions().length}',
                                  style: AppTextStyles.caption(color: AppColors.orange).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: _getPendingCategorizationTransactions().isEmpty 
                    ? AppColors.greenLight 
                    : AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _getPendingCategorizationTransactions().isEmpty 
                      ? AppColors.green.withOpacity(0.3) 
                      : AppColors.orange.withOpacity(0.3)
                  ),
                ),
                child: _getPendingCategorizationTransactions().isEmpty
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline, color: AppColors.green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¡Todo categorizado!',
                                style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No tienes transacciones pendientes de clasificar',
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.orange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getPendingCategorizationTransactions().length} transacciones sin categorizar',
                                    style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Categorízalas para un mejor seguimiento',
                                    style: AppTextStyles.caption(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                        ..._getPendingCategorizationTransactions().take(3).map((transaction) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: InkWell(
                              onTap: () => _showCategorizationModal(context, transaction),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              child: Container(
                                padding: AppSpacing.paddingSm,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.orange.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.orangeLight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.category, color: AppColors.orange, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.description,
                                            style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                Formatters.date(transaction.date),
                                                style: AppTextStyles.caption().copyWith(color: AppColors.gray600),
                                              ),
                                              if (transaction.hasSuggestedCategory) ...[
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.tealPale,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          _getIconFromString(transaction.suggestedCategory!.icon ?? 'more_horiz'),
                                                          size: 12,
                                                          color: AppColors.teal,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            transaction.suggestedCategory!.displayName,
                                                            style: AppTextStyles.caption().copyWith(
                                                              color: AppColors.teal,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          Formatters.currency(transaction.amount),
                                          style: AppTextStyles.bodyMedium().copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: transaction.isIncome ? AppColors.green : AppColors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.gray500),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalXxl,
            ]),
          ),
        ),
      ],
    );
  }
  
  /// Mapea un string de icono a un IconData de Material Icons
  IconData _getIconFromString(String iconName) {
    final iconMap = {
      // Alimentación
      'restaurant': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'delivery_dining': Icons.delivery_dining,
      'local_cafe': Icons.local_cafe,
      
      // Transporte
      'directions_car': Icons.directions_car,
      'local_gas_station': Icons.local_gas_station,
      'directions_bus': Icons.directions_bus,
      'local_taxi': Icons.local_taxi,
      'build': Icons.build,
      
      // Vivienda
      'home': Icons.home,
      'home_work': Icons.home_work,
      'electrical_services': Icons.electrical_services,
      'handyman': Icons.handyman,
      'wifi': Icons.wifi,
      
      // Deudas
      'credit_card': Icons.credit_card,
      'account_balance': Icons.account_balance,
      'house': Icons.house,
      
      // Salud
      'local_hospital': Icons.local_hospital,
      'medical_services': Icons.medical_services,
      'medication': Icons.medication,
      'health_and_safety': Icons.health_and_safety,
      'dentistry': Icons.health_and_safety,
      
      // Educación
      'school': Icons.school,
      'menu_book': Icons.menu_book,
      'book': Icons.book,
      
      // Entretenimiento
      'theaters': Icons.theaters,
      'tv': Icons.tv,
      'local_movies': Icons.local_movies,
      'celebration': Icons.celebration,
      'sports_esports': Icons.sports_esports,
      
      // Mascotas
      'pets': Icons.pets,
      'pet_supplies': Icons.pets,
      'cut': Icons.content_cut,
      
      // Compras
      'shopping_bag': Icons.shopping_bag,
      'checkroom': Icons.checkroom,
      'devices': Icons.devices,
      'face': Icons.face,
      
      // Suscripciones
      'subscriptions': Icons.subscriptions,
      'library_music': Icons.library_music,
      'fitness_center': Icons.fitness_center,
      
      // Impuestos
      'receipt': Icons.receipt,
      'location_city': Icons.location_city,
      
      // Otros
      'more_horiz': Icons.more_horiz,
      'receipt_long': Icons.receipt_long,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }
}

/// Widget de Estadísticas Rápidas
class _QuickStatsCard extends StatelessWidget {
  final double actualIncome;
  final double actualExpenses;
  final double theoreticalExpenses;
  final double monthProgress;

  const _QuickStatsCard({
    required this.actualIncome,
    required this.actualExpenses,
    required this.theoreticalExpenses,
    required this.monthProgress,
  });

  @override
  Widget build(BuildContext context) {
    final percentSpent = theoreticalExpenses > 0
        ? (actualExpenses / theoreticalExpenses * 100).clamp(0, 100)
        : 0.0;
    final percentMonth = (monthProgress * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 20, color: AppColors.teal),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Resumen',
                  style: AppTextStyles.h5().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          
          // Ingresos
          _StatRow(
            icon: Icons.arrow_downward,
            iconColor: AppColors.green,
            label: 'Ingresos',
            value: Formatters.currency(actualIncome),
            valueColor: AppColors.green,
          ),
          AppSpacing.verticalSm,
          
          // Gastos
          _StatRow(
            icon: Icons.arrow_upward,
            iconColor: AppColors.red,
            label: 'Gastos',
            value: Formatters.currency(actualExpenses),
            valueColor: AppColors.red,
          ),
          AppSpacing.verticalMd,
          
          // Progreso vs Tiempo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: percentSpent > percentMonth 
                  ? AppColors.redLight 
                  : AppColors.greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Gastado',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentSpent.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.w600,
                        color: percentSpent > percentMonth 
                            ? AppColors.red 
                            : AppColors.green,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Mes transcurrido',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentMonth.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget auxiliar para una fila de estadística
class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall().copyWith(
                    color: AppColors.gray600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.bodyMedium().copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
