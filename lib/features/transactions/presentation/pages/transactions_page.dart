import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/config/app_config.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/core/utils/formatters.dart';
import 'package:quho_app/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:quho_app/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:quho_app/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:quho_app/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:quho_app/features/transactions/presentation/widgets/transaction_grid_card.dart';
import 'package:quho_app/features/transactions/presentation/widgets/transaction_detail_bottom_sheet.dart';
import 'package:quho_app/shared/design_system/design_system.dart';

/// Página de transacciones con filtros y búsqueda
class TransactionsPage extends StatefulWidget {
  final String? initialCategoryFilter;
  
  const TransactionsPage({
    super.key,
    this.initialCategoryFilter,
  });

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  TransactionsBloc? _bloc; // Referencia al bloc

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (!mounted) return; // Verificar que el widget esté montado
    
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      // Cuando el usuario está al 80% del scroll, cargar más
      final bloc = _bloc;
      if (bloc != null && mounted) {
        try {
          final state = bloc.state;
          if (state is TransactionsLoaded && state.hasMore && !state.isLoadingMore) {
            bloc.add(const LoadMoreTransactionsEvent());
          }
        } catch (e) {
          print('[TransactionsPage] Error en _onScroll: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _bloc = null; // Limpiar referencia
    super.dispose();
  }

  void _showFilterSheet(BuildContext blocContext) {
    final currentState = blocContext.read<TransactionsBloc>().state;
    String? currentType;
    String? currentCategory;
    DateTime? currentStartDate;
    DateTime? currentEndDate;

    if (currentState is TransactionsLoaded) {
      currentType = currentState.currentType;
      currentCategory = currentState.currentCategory;
      currentStartDate = currentState.currentStartDate;
      currentEndDate = currentState.currentEndDate;
    }

    showModalBottomSheet(
      context: blocContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialType: currentType,
        initialCategory: currentCategory,
        initialStartDate: currentStartDate,
        initialEndDate: currentEndDate,
        onApply: (type, category, startDate, endDate) {
          blocContext.read<TransactionsBloc>().add(
                ApplyFiltersEvent(
                  type: type,
                  category: category,
                  startDate: startDate,
                  endDate: endDate,
                ),
              );
        },
      ),
    );
  }

  void _clearFilters(BuildContext blocContext) {
    blocContext.read<TransactionsBloc>().add(const ClearFiltersEvent());
    _searchController.clear();
  }

  void _onSearchChanged(String query, BuildContext blocContext) {
    blocContext.read<TransactionsBloc>().add(SearchTransactionsEvent(query));
  }

  void _showTransactionDetail(BuildContext context, transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheet(
        transaction: transaction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<TransactionsBloc>();
        
        // Guardar referencia al bloc para usar en el scroll listener
        _bloc = bloc;
        
        // Si hay un filtro inicial, cargar directamente con ese filtro
        if (widget.initialCategoryFilter != null) {
          print('[TransactionsPage] Cargando con filtro inicial: ${widget.initialCategoryFilter}');
          bloc.add(LoadTransactionsEvent(
            page: 1,
            isRefresh: true,
            category: widget.initialCategoryFilter,
          ));
        } else {
          // Cargar todas las transacciones sin filtro
          bloc.add(const LoadTransactionsEvent(page: 1, isRefresh: true));
        }
        
        return bloc;
      },
      child: Builder(
        builder: (blocContext) => Scaffold(
        backgroundColor: AppColors.gray50,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
            onPressed: () => blocContext.pop(),
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar transacciones...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) => _onSearchChanged(query, blocContext),
                )
              : BlocBuilder<TransactionsBloc, TransactionsState>(
                  builder: (context, state) {
                    String title = 'Transacciones';
                    if (state is TransactionsLoaded && state.currentCategory != null) {
                      // Mostrar nombre de categoría si está filtrado
                      title = 'Transacciones';
                      // Agregar subtítulo con el filtro activo
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h4().copyWith(color: AppColors.gray900),
                        ),
                        if (state is TransactionsLoaded && state.currentCategory != null)
                          Text(
                            'Filtrado por categoría',
                            style: AppTextStyles.caption(color: AppColors.gray600),
                          ),
                      ],
                    );
                  },
                ),
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.gray900),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                  blocContext.read<TransactionsBloc>().add(const SearchTransactionsEvent(''));
                },
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.gray900),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.gray900),
                onPressed: () => _showFilterSheet(blocContext),
              ),
            ],
          ],
        ),
        body: BlocBuilder<TransactionsBloc, TransactionsState>(
          buildWhen: (previous, current) {
            // Reconstruir siempre que cambie el estado
            return previous != current;
          },
          builder: (blocBuilderContext, state) {
            if (state is TransactionsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            if (state is TransactionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.red,
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      'Error al cargar transacciones',
                      style: AppTextStyles.h5(),
                    ),
                    AppSpacing.verticalSm,
                    Text(
                      state.message,
                      style: AppTextStyles.bodySmall(color: AppColors.gray600),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalMd,
                    ElevatedButton.icon(
                      onPressed: () {
                        blocBuilderContext.read<TransactionsBloc>().add(
                              const LoadTransactionsEvent(page: 1, isRefresh: true),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is TransactionsLoaded) {
              return Column(
                children: [
                  // Filtros activos
                  if (state.hasActiveFilters)
                    Container(
                      width: double.infinity,
                      padding: AppSpacing.paddingMd,
                      color: AppColors.white,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (state.currentType != null)
                            _FilterChip(
                              label: state.currentType == 'income' ? 'Ingresos' : 'Gastos',
                              onDeleted: () {
                                blocBuilderContext.read<TransactionsBloc>().add(
                                      ApplyFiltersEvent(
                                        category: state.currentCategory,
                                        startDate: state.currentStartDate,
                                        endDate: state.currentEndDate,
                                      ),
                                    );
                              },
                            ),
                          if (state.currentCategory != null)
                            _FilterChip(
                              label: state.currentCategory!,
                              onDeleted: () {
                                blocBuilderContext.read<TransactionsBloc>().add(
                                      ApplyFiltersEvent(
                                        type: state.currentType,
                                        startDate: state.currentStartDate,
                                        endDate: state.currentEndDate,
                                      ),
                                    );
                              },
                            ),
                          if (state.currentStartDate != null || state.currentEndDate != null)
                            _FilterChip(
                              label: _getDateRangeLabel(
                                state.currentStartDate,
                                state.currentEndDate,
                              ),
                              onDeleted: () {
                                blocBuilderContext.read<TransactionsBloc>().add(
                                      ApplyFiltersEvent(
                                        type: state.currentType,
                                        category: state.currentCategory,
                                      ),
                                    );
                              },
                            ),
                          TextButton.icon(
                            onPressed: () => _clearFilters(blocBuilderContext),
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Limpiar'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cuadrícula de transacciones
                  Expanded(
                    child: state.transactions.isEmpty
                        ? _buildEmptyState(state.hasActiveFilters, blocBuilderContext)
                        : RefreshIndicator(
                            onRefresh: () async {
                              blocBuilderContext.read<TransactionsBloc>().add(
                                    LoadTransactionsEvent(
                                      page: 1,
                                      type: state.currentType,
                                      category: state.currentCategory,
                                      startDate: state.currentStartDate,
                                      endDate: state.currentEndDate,
                                      search: state.currentSearch,
                                      isRefresh: true,
                                    ),
                                  );
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Grid adaptativo según el ancho de pantalla
                                int crossAxisCount;
                                if (constraints.maxWidth > 1200) {
                                  crossAxisCount = 5; // Desktop grande
                                } else if (constraints.maxWidth > 900) {
                                  crossAxisCount = 4; // Desktop mediano
                                } else if (constraints.maxWidth > 600) {
                                  crossAxisCount = 3; // Tablet
                                } else {
                                  crossAxisCount = 2; // Móvil
                                }

                                return CustomScrollView(
                                  controller: _scrollController,
                                  slivers: [
                                    SliverPadding(
                                      padding: AppSpacing.paddingMd,
                                      sliver: SliverGrid(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: 1.0,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final transaction = state.transactions[index];
                                        return TransactionGridCard(
                                          title: transaction.description,
                                          category: transaction.category,
                                          amount: transaction.amount,
                                          date: transaction.date,
                                          isIncome: transaction.isIncome,
                                          originalCurrency: transaction.originalCurrency,
                                          originalAmount: transaction.originalAmount,
                                          onTap: () => _showTransactionDetail(
                                            blocBuilderContext,
                                            transaction,
                                          ),
                                        );
                                      },
                                      childCount: state.transactions.length,
                                    ),
                                  ),
                                ),
                                // Indicador de carga al final
                                if (state.hasMore || state.isLoadingMore)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: state.isLoadingMore
                                            ? const CircularProgressIndicator(color: AppColors.teal)
                                            : TextButton.icon(
                                                onPressed: () {
                                                  blocBuilderContext.read<TransactionsBloc>().add(
                                                    const LoadMoreTransactionsEvent(),
                                                  );
                                                },
                                                icon: const Icon(Icons.refresh),
                                                label: const Text('Cargar más'),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: AppColors.teal,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  ],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            blocContext.push(RouteNames.addTransaction);
          },
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
        bottomNavigationBar: _buildBottomNav(blocContext),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0, // Inicio está seleccionado por defecto
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
          // Navegar a Dashboard
          context.pop();
        } else if (index == 1) {
          // Navegar a Finanzas
          context.push(RouteNames.finances);
        } else if (index == 2) {
          context.push(RouteNames.profile);
        }
      },
    );
  }

  Widget _buildEmptyState(bool hasFilters, BuildContext blocBuilderContext) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.gray400,
            ),
            AppSpacing.verticalMd,
            Text(
              hasFilters ? 'No se encontraron transacciones' : 'Sin transacciones',
              style: AppTextStyles.h5(),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            Text(
              hasFilters
                  ? 'Intenta ajustar los filtros o busca algo diferente'
                  : 'Agrega tu primera transacción para comenzar',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              AppSpacing.verticalMd,
              TextButton.icon(
                onPressed: () => _clearFilters(blocBuilderContext),
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar filtros'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      return '${Formatters.shortDate(startDate)} - ${Formatters.shortDate(endDate)}';
    } else if (startDate != null) {
      return 'Desde ${Formatters.shortDate(startDate)}';
    } else if (endDate != null) {
      return 'Hasta ${Formatters.shortDate(endDate)}';
    }
    return '';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: AppColors.teal.withOpacity(0.1),
      labelStyle: AppTextStyles.caption(color: AppColors.teal),
      deleteIconColor: AppColors.teal,
      side: BorderSide.none,
    );
  }
}


