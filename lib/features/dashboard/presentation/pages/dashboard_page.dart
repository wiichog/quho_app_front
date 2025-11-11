import 'dart:async';

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
import 'package:quho_app/features/dashboard/domain/entities/budget_summary.dart';
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
import 'package:quho_app/features/dashboard/data/models/category_budget_tracking_model.dart';

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

  Future<void> _confirmAndResetCategorizations(BuildContext context) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Resetear categorizaciones', style: AppTextStyles.h4()),
        content: Text(
          'Esto pondrá todas tus transacciones como "Sin categorizar" y recalculará tus métricas. ¿Deseas continuar?',
          style: AppTextStyles.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancelar', style: AppTextStyles.bodyMedium(color: AppColors.gray600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: AppColors.white),
            child: Text('Sí, resetear', style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await datasource.resetCategorizations();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader

      // Reload dashboard
      context.read<DashboardBloc>().add(const LoadDashboardDataEvent());
      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('✅ Categorizaciones reseteadas'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Error al resetear: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _showCategorySelector(BuildContext context, Transaction transaction) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    final rootContext = context;
    
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
        context: rootContext,
        builder: (dialogContext) => CategorySelectorModal(
          categories: categoryItems,
          onCategorySelected: (category, updateMerchant) async {
            print('✅ Categoría seleccionada: ${category.name} (ID: ${category.id})');
            // Cerrar el modal de selección antes de categorizar
            Navigator.of(dialogContext).pop();
            await _categorizeTransaction(rootContext, transaction.id, category.id, updateMerchant);
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
    
    var loaderShown = false;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    // Mostrar loading dialog
      if (context.mounted) {
      loaderShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Categorizando...',
                    style: AppTextStyles.bodyMedium(),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      }

    try {
      print('🔵 [CATEGORIZATION] Iniciando categorización de transacción $transactionId con categoría $categoryId');
      // Categorizar
      await datasource.categorizeTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        updateMerchant: updateMerchant,
      );

      print('✅ [CATEGORIZATION] Transacción categorizada en el backend');

      // IMPORTANTE: Cerrar loader INMEDIATAMENTE después de categorizar exitosamente
      if (loaderShown && context.mounted) {
        print('🔵 [CATEGORIZATION] Cerrando loader después de categorizar');
        try {
          rootNavigator.pop();
          loaderShown = false;
          print('✅ [CATEGORIZATION] Loader cerrado');
        } catch (e) {
          print('❌ [CATEGORIZATION] Error cerrando loader: $e');
          loaderShown = false; // Marcar como cerrado de todas formas
        }
      }

      if (!context.mounted) {
        print('⚠️ [CATEGORIZATION] Context no montado después de categorizar');
        return;
      }

      // Recargar dashboard en background (sin esperar)
      print('🔄 [CATEGORIZATION] Recargando dashboard en background...');
      final bloc = context.read<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());
      
      // Mostrar éxito inmediatamente
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('✅ Transacción categorizada correctamente'),
            backgroundColor: AppColors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [CATEGORIZATION] Error al categorizar: $e');
      print('❌ [CATEGORIZATION] Stack trace: $stackTrace');
      
      // Cerrar loading dialog en caso de error
      if (loaderShown) {
        print('🔵 [CATEGORIZATION] Cerrando loader en catch');
        try {
          if (context.mounted) {
            rootNavigator.pop();
          }
        } catch (popError) {
          print('❌ [CATEGORIZATION] Error cerrando loader en catch: $popError');
        } finally {
          loaderShown = false;
        }
      }
      
      if (!context.mounted) {
        print('⚠️ [CATEGORIZATION] Context no montado en catch');
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Error al categorizar: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      print('🔵 [CATEGORIZATION] En finally, loaderShown: $loaderShown');
      // Salvaguarda por si el loader quedó abierto
      if (loaderShown) {
        print('⚠️ [CATEGORIZATION] Loader todavía abierto en finally, intentando cerrar');
        try { 
          rootNavigator.pop(); 
          print('✅ [CATEGORIZATION] Loader cerrado en finally');
        } catch (e) {
          print('❌ [CATEGORIZATION] Error cerrando loader en finally: $e');
        }
      }
    }
  }

  Future<void> _showIncomeSourceSelector(BuildContext context, Transaction transaction) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    final rootContext = context;
    
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
        context: rootContext,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'Selecciona el origen del ingreso',
            style: AppTextStyles.h4(),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: incomeSources.length + 1, // +1 para la opción "Otros"
              itemBuilder: (listContext, index) {
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
                      Navigator.of(dialogContext).pop();
                      await _showNewIncomeSourceForm(rootContext, transaction);
                    },
                  );
                }
                
                // Fuentes existentes
                final source = incomeSources[index];
                final tracking = source.tracking;
                final isFullyReceived = tracking?.isFullyReceived ?? false;
                final remainingAmount = tracking?.remainingAmount ?? 0;
                final statusColor = isFullyReceived 
                    ? AppColors.gray400 
                    : (remainingAmount > 0 ? AppColors.green : AppColors.orange);
                
                return Opacity(
                  opacity: isFullyReceived ? 0.5 : 1.0,
                  child: ListTile(
                    enabled: !isFullyReceived,
                    leading: Icon(
                      isFullyReceived ? Icons.check_circle : Icons.work, 
                      color: statusColor,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            source.name,
                            style: AppTextStyles.bodyMedium().copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isFullyReceived ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (tracking != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              Formatters.currency(remainingAmount),
                              style: AppTextStyles.bodySmall().copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.currency(source.amount)} - ${source.frequency}',
                          style: AppTextStyles.bodySmall().copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        if (tracking != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Recibido: ${Formatters.currency(tracking.receivedAmount)} de ${Formatters.currency(tracking.expectedAmount)}',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.gray500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (isFullyReceived) ...[
                          const SizedBox(height: 4),
                          Text(
                            '✓ Completado - ingreso recibido',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.green,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      isFullyReceived ? Icons.check_circle : Icons.check_circle_outline, 
                      color: statusColor,
                    ),
                    onTap: isFullyReceived ? null : () async {
                      Navigator.of(dialogContext).pop();
                      await _categorizeIncomeTransaction(rootContext, transaction.id, source.id);
                    },
                  ),
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
    final rootContext = context;
    
    // Mostrar un loading dialog mientras cargamos los gastos fijos
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      print('🔵 Obteniendo gastos fijos y trackings...');
      
      // Obtener gastos fijos y trackings en paralelo
      final results = await Future.wait([
        datasource.getFixedExpenses(),
        datasource.getCategoryBudgetTrackings(),
      ]);
      
      final fixedExpenses = results[0] as List<FixedExpenseModel>;
      final trackings = results[1] as List<CategoryBudgetTrackingModel>;
      
      print('✅ Gastos fijos obtenidos: ${fixedExpenses.length}');
      print('✅ Trackings obtenidos: ${trackings.length}');
      
      // Crear un mapa de tracking por fixed expense ID
      final trackingMap = <int, CategoryBudgetTrackingModel>{};
      for (final tracking in trackings) {
        if (tracking.fixedExpenseId != null) {
          trackingMap[tracking.fixedExpenseId!] = tracking;
        }
      }
      
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
        context: rootContext,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            '¿Este gasto corresponde a un presupuesto fijo?',
            style: AppTextStyles.h4(),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fixedExpenses.length + 1, // +1 para la opción "Otros"
                    itemBuilder: (listContext, index) {
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
                      Navigator.of(dialogContext).pop();
                      await _showStandardCategorizationModal(rootContext, transaction);
                    },
                  );
                }
                
                // Gastos fijos existentes
                final expense = fixedExpenses[index];
                final tracking = trackingMap[expense.id];
                final isClosed = tracking?.isClosed ?? false;
                final remainingAmount = tracking?.remainingAmount ?? expense.amount;
                final isOverBudget = tracking?.isOverBudget ?? false;
                
                // Color basado en el estado
                final leadingColor = isClosed ? AppColors.gray400 : AppColors.red;
                final statusColor = isOverBudget ? AppColors.red : (remainingAmount <= 0 ? AppColors.orange : AppColors.green);
                
                return Opacity(
                  opacity: isClosed ? 0.5 : 1.0,
                  child: ListTile(
                    enabled: !isClosed,
                    leading: Icon(
                      isClosed ? Icons.lock : Icons.receipt_long, 
                      color: leadingColor,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                    expense.name,
                    style: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w600,
                              decoration: isClosed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                        ),
                        if (tracking != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              Formatters.currency(remainingAmount),
                              style: AppTextStyles.bodySmall().copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                    '${expense.categoryName} • ${Formatters.currency(expense.amount)} - ${expense.frequency}',
                    style: AppTextStyles.bodySmall().copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                        if (tracking != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gastado: ${Formatters.currency(tracking.spentAmount)} de ${Formatters.currency(tracking.budgetedAmount)}',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.gray500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (isClosed) ...[
                          const SizedBox(height: 4),
                          Text(
                            '🔒 Cerrado - no esperas más gastos',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.gray500,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Icon(
                      isClosed ? Icons.lock : Icons.check_circle_outline, 
                      color: isClosed ? AppColors.gray400 : AppColors.gray500,
                    ),
                    onTap: isClosed ? null : () async {
                      Navigator.of(dialogContext).pop();
                    await _categorizeExpenseTransaction(
                        rootContext, 
                      transaction.id, 
                      expense.categoryId, 
                      expense.id,
                        tracking: tracking,
                    );
                  },
                  ),
                );
              },
                  ),
                ),
                // Nota informativa sobre categorías cerradas
                if (trackingMap.values.any((t) => t.isClosed))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '💡 Las categorías cerradas se reabrirán automáticamente el próximo mes',
                              style: AppTextStyles.caption(color: AppColors.blue).copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
        transactionAmount: transaction.amount,
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
    final isOneTime = frequency == 'one_time';
    final frequencyForApi = isOneTime ? 'monthly' : frequency;
    
    var loaderShownNew = false;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    // Mostrar loading dialog
      if (context.mounted) {
      loaderShownNew = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Creando fuente de ingreso...',
                    style: AppTextStyles.bodyMedium(),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      }

    try {
      // Crear fuente y categorizar
      final tx = await datasource.categorizeIncomeWithNewSource(
        transactionId: transactionId,
        name: name,
        amount: amount,
        frequency: frequencyForApi,
        isNetAmount: isNetAmount,
        taxContext: taxContext,
      );

      // Si es pago único, desactivar la fuente creada (soft delete)
      if (isOneTime && tx.incomeSourceId != null) {
        await datasource.deactivateIncomeSource(incomeSourceId: tx.incomeSourceId!);
      }

      if (!context.mounted) return;

      // Recargar dashboard y esperar a que el BLoC emita DashboardLoaded
      print('🔄 Recargando dashboard...');
      final bloc = context.read<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());
      await bloc.stream.firstWhere((s) => s is DashboardLoaded).timeout(const Duration(seconds: 5));
      print('✅ Dashboard recargado (DashboardLoaded recibido)');
      
      // Esperar un frame para que Flutter procese el cambio de estado
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!context.mounted) return;
      
      // Cerrar loading dialog
      if (loaderShownNew) {
        rootNavigator.pop();
        loaderShownNew = false;
      }
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('✅ Nueva fuente "$name" creada y ingreso categorizado'),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Cerrar loading dialog
      if (loaderShownNew) {
        rootNavigator.pop();
        loaderShownNew = false;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Error al crear fuente de ingreso: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (loaderShownNew) {
        try { rootNavigator.pop(); } catch (_) {}
      }
    }
  }

  Future<void> _categorizeIncomeTransaction(BuildContext context, String transactionId, int incomeSourceId) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    var loaderShownInc = false;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    // Mostrar loading dialog
    if (context.mounted) {
      loaderShownInc = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Categorizando ingreso...',
                    style: AppTextStyles.bodyMedium(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      print('🔵 Categorizando ingreso...');
      
      // Categorizar ingreso
      await datasource.categorizeIncomeTransaction(
        transactionId: transactionId,
        incomeSourceId: incomeSourceId,
      );
      
      print('✅ Ingreso categorizado en el servidor');

      // IMPORTANTE: Cerrar loader INMEDIATAMENTE después de categorizar exitosamente
      if (loaderShownInc && context.mounted) {
        print('🔵 [INCOME] Cerrando loader después de categorizar');
        try {
          rootNavigator.pop();
          loaderShownInc = false;
          print('✅ [INCOME] Loader cerrado');
        } catch (e) {
          print('❌ [INCOME] Error cerrando loader: $e');
          loaderShownInc = false; // Marcar como cerrado de todas formas
        }
      }

      if (!context.mounted) return;

      // Recargar dashboard en background (sin esperar)
      print('🔄 Recargando dashboard en background...');
      final bloc = context.read<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());
      
      // Mostrar éxito inmediatamente
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('✅ Ingreso categorizado - presupuesto actualizado'),
            backgroundColor: AppColors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error al categorizar ingreso: $e');
      print('📚 StackTrace: $stackTrace');
      
      // Cerrar loading dialog en caso de error
      if (loaderShownInc) {
        print('🔵 [INCOME] Cerrando loader en catch');
        try {
          if (context.mounted) {
            rootNavigator.pop();
          }
        } catch (popError) {
          print('❌ [INCOME] Error cerrando loader en catch: $popError');
        } finally {
          loaderShownInc = false;
        }
      }
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Error al categorizar ingreso: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (loaderShownInc) {
        try { 
          rootNavigator.pop(); 
        } catch (_) {
          print('⚠️ Error cerrando loader (ya cerrado)');
        }
      }
    }
  }

  Future<void> _categorizeExpenseTransaction(
    BuildContext context, 
    String transactionId, 
    int categoryId, 
    int fixedExpenseId, {
    CategoryBudgetTrackingModel? tracking,
  }) async {
    final datasource = getIt<DashboardRemoteDataSource>();
    
    var loaderShownExp = false;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    // Mostrar loading dialog
      if (context.mounted) {
      loaderShownExp = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Categorizando gasto...',
                    style: AppTextStyles.bodyMedium(),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      }

    try {
      // Categorizar gasto vinculado a FixedExpense
      await datasource.categorizeTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        fixedExpenseId: fixedExpenseId,
        updateMerchant: false,
      );

      if (!context.mounted) return;

      // Recargar dashboard y esperar a que el BLoC emita DashboardLoaded
      print('🔄 Recargando dashboard...');
      final bloc = context.read<DashboardBloc>();
      bloc.add(const LoadDashboardDataEvent());
      await bloc.stream.firstWhere((s) => s is DashboardLoaded).timeout(const Duration(seconds: 5));
      print('✅ Dashboard recargado (DashboardLoaded recibido)');
      
      // Esperar un frame para que Flutter procese el cambio de estado
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!context.mounted) return;
      
      // Cerrar loading dialog
      if (loaderShownExp) {
        rootNavigator.pop();
        loaderShownExp = false;
      }
      
      // Ya no preguntamos si volverá a gastar - las categorías permanecen abiertas
      
      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('✅ Gasto categorizado y vinculado al presupuesto'),
          backgroundColor: AppColors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Cerrar loading dialog
      if (loaderShownExp) {
        rootNavigator.pop();
        loaderShownExp = false;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Error al categorizar gasto: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (loaderShownExp) {
        try { rootNavigator.pop(); } catch (_) {}
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final budget = state.budgetSummary;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;
    final double firstRowCardHeight = 140; // altura uniforme para la primera fila
    // Estado visual: basado en el BALANCE DISPONIBLE
    const epsilon = 0.01;
    final BudgetStatus statusForChip;
    if (budget.balance < -epsilon) {
      // Balance negativo → ROJO
      statusForChip = BudgetStatus.danger;
    } else if (budget.balance >= -epsilon && budget.balance <= epsilon) {
      // Balance cero → GRIS
      statusForChip = BudgetStatus.neutral;
    } else {
      // Balance positivo → estado normal del presupuesto
      statusForChip = state.budgetSummary.budgetStatus;
    }
    
    // DEBUG
    print('🔵 [DASHBOARD] balance: ${budget.balance}');
    print('🔵 [DASHBOARD] statusForChip: $statusForChip');

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
                        value: 'reset_categorizations',
                        child: Row(
                          children: [
                            const Icon(Icons.refresh, size: 20, color: AppColors.orange),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Resetear categorizaciones',
                                style: AppTextStyles.bodyMedium(color: AppColors.orange),
                                overflow: TextOverflow.ellipsis,
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
                      } else if (value == 'reset_categorizations') {
                        _confirmAndResetCategorizations(context);
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
                    child: SizedBox(
                      height: firstRowCardHeight,
                    child: EditableBalanceCard(
                      balance: budget.balance,
                      onEdit: () {
                        // TODO: Implementar edición
                      },
                      ),
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Estado del Presupuesto (compacto)
                  SizedBox(
                    width: 180,
                    height: firstRowCardHeight,
                    child: BudgetStatusIndicator(
                      key: ValueKey('budget_status_${budget.balance}_$daysRemaining'),
                      status: statusForChip,
                      daysRemaining: daysRemaining,
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  // Para Sobrevivir al Mes
                  Expanded(
                    child: SizedBox(
                      height: firstRowCardHeight,
                    child: RemainingBalanceCard(
                        key: ValueKey('remaining_balance_${budget.balance}_${budget.remainingForMonth}_$daysRemaining'),
                      remainingForMonth: budget.remainingForMonth,
                      daysRemaining: daysRemaining,
                        balance: budget.balance,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalXl,

              // Segunda Fila: Transacciones por Categorizar y Gastos por Categoría (2 columnas)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transacciones por Categorizar
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
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                            // Botón de ordenamiento más visible
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.orange.withOpacity(0.3)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    final currentOrdering = state.pendingTransactionsOrdering;
                                    final newOrdering = currentOrdering == 'asc' ? 'desc' : 'asc';
                                    context.read<DashboardBloc>().add(
                                      ChangePendingTransactionsOrderingEvent(newOrdering),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          state.pendingTransactionsOrdering == 'asc'
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 18,
                                          color: AppColors.orange,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.pendingTransactionsOrdering == 'asc'
                                              ? 'Antiguas'
                                              : 'Recientes',
                                          style: AppTextStyles.caption(color: AppColors.orange).copyWith(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalSm,
                                  // Lista con scroll para mostrar todas las transacciones
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 300),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _getPendingCategorizationTransactions().length,
                                      itemBuilder: (context, index) {
                                        final transaction = _getPendingCategorizationTransactions()[index];
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                                            if (transaction.originalCurrency != null && transaction.originalCurrency != 'GTQ' && transaction.originalAmount != null)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 2),
                                                child: Text(
                                                  Formatters.currencyWithCode(transaction.originalCurrency!, transaction.originalAmount!),
                                                  style: AppTextStyles.caption(color: AppColors.gray600),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        // Botón de check rápido si hay categoría sugerida
                                        if (transaction.hasSuggestedCategory)
                                          Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                // Aceptar la categoría sugerida directamente
                                                await _categorizeTransaction(
                                                  context,
                                                  transaction.id,
                                                  transaction.suggestedCategory!.id,
                                                  false,
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.teal.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.teal.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: AppColors.teal,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.gray500),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                                      },
                                    ),
                                  ),
                      ],
                    ),
                        ),
                        ],
                      ),
                    ),
                  AppSpacing.horizontalMd,
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
