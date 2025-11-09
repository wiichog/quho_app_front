import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';
import 'package:quho_app/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:quho_app/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:quho_app/features/transactions/presentation/bloc/transactions_state.dart';

/// BLoC para manejar el estado de transacciones
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionsBloc({
    required this.getTransactionsUseCase,
  }) : super(const TransactionsInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<ClearFiltersEvent>(_onClearFilters);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    print('🔵 [BLOC] Cargando transacciones');

    // Si es refresh, mostrar loading
    if (event.isRefresh) {
      emit(const TransactionsLoading());
    } else if (state is TransactionsLoaded) {
      // Si estamos cargando más páginas, mantener el estado pero con isLoadingMore
      final currentState = state as TransactionsLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const TransactionsLoading());
    }

    final params = GetTransactionsParams(
      page: event.page,
      type: event.type,
      category: event.category,
      startDate: event.startDate,
      endDate: event.endDate,
      search: event.search,
    );

    final result = await getTransactionsUseCase(params);

    result.fold(
      (failure) {
        print('❌ [BLOC] Error al cargar transacciones: ${failure.message}');
        emit(TransactionsError(message: failure.message));
      },
      (paginatedTransactions) {
        print('✅ [BLOC] Transacciones cargadas: ${paginatedTransactions.transactions.length}');

        // Si es la primera página o refresh, reemplazar toda la lista
        // Si es paginación, agregar a la lista existente
        final List<Transaction> transactions = event.isRefresh || event.page == 1
            ? paginatedTransactions.transactions
            : [
                ...(state is TransactionsLoaded ? (state as TransactionsLoaded).transactions : <Transaction>[]),
                ...paginatedTransactions.transactions
              ];

        // Eliminar duplicados preservando el orden (según id)
        final uniqueTransactions = <String>{};
        final dedupedTransactions = <Transaction>[];
        for (final transaction in transactions) {
          if (uniqueTransactions.add(transaction.id)) {
            dedupedTransactions.add(transaction);
          }
        }

        final totalLoaded = dedupedTransactions.length;
        final hasMore = totalLoaded < paginatedTransactions.count;

        emit(TransactionsLoaded(
          transactions: dedupedTransactions,
          totalCount: paginatedTransactions.count,
          hasMore: hasMore,
          currentPage: event.page,
          currentType: event.type,
          currentCategory: event.category,
          currentStartDate: event.startDate,
          currentEndDate: event.endDate,
          currentSearch: event.search,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    print('🔵 [BLOC] Aplicando filtros');
    add(LoadTransactionsEvent(
      page: 1,
      type: event.type,
      category: event.category,
      startDate: event.startDate,
      endDate: event.endDate,
      isRefresh: true,
    ));
  }

  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    print('🔵 [BLOC] Buscando transacciones: ${event.query}');

    // Mantener filtros actuales si existen
    String? currentType;
    String? currentCategory;
    DateTime? currentStartDate;
    DateTime? currentEndDate;

    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      currentType = currentState.currentType;
      currentCategory = currentState.currentCategory;
      currentStartDate = currentState.currentStartDate;
      currentEndDate = currentState.currentEndDate;
    }

    add(LoadTransactionsEvent(
      page: 1,
      type: currentType,
      category: currentCategory,
      startDate: currentStartDate,
      endDate: currentEndDate,
      search: event.query.isEmpty ? null : event.query,
      isRefresh: true,
    ));
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    print('🔵 [BLOC] Limpiando filtros');
    add(const LoadTransactionsEvent(
      page: 1,
      isRefresh: true,
    ));
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is! TransactionsLoaded) return;

    final currentState = state as TransactionsLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    print('🔵 [BLOC] Cargando más transacciones (página ${currentState.currentPage + 1})');

    add(LoadTransactionsEvent(
      page: currentState.currentPage + 1,
      type: currentState.currentType,
      category: currentState.currentCategory,
      startDate: currentState.currentStartDate,
      endDate: currentState.currentEndDate,
      search: currentState.currentSearch,
      isRefresh: false,
    ));
  }
}

