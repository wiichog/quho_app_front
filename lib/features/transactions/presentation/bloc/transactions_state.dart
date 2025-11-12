import 'package:equatable/equatable.dart';
import 'package:quho_app/features/dashboard/domain/entities/transaction.dart';

/// Estados del BLoC de transacciones
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

/// Cargando transacciones
class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

/// Transacciones cargadas
class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final int totalCount;
  final bool hasMore;
  final int currentPage;
  final String? currentType;
  final String? currentCategory; // ID de la categoría para el filtro
  final String? currentCategoryName; // Nombre de la categoría para mostrar
  final DateTime? currentStartDate;
  final DateTime? currentEndDate;
  final String? currentSearch;
  final bool isLoadingMore;

  const TransactionsLoaded({
    required this.transactions,
    required this.totalCount,
    required this.hasMore,
    required this.currentPage,
    this.currentType,
    this.currentCategory,
    this.currentCategoryName,
    this.currentStartDate,
    this.currentEndDate,
    this.currentSearch,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        transactions,
        totalCount,
        hasMore,
        currentPage,
        currentType,
        currentCategory,
        currentCategoryName,
        currentStartDate,
        currentEndDate,
        currentSearch,
        isLoadingMore,
      ];

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    int? totalCount,
    bool? hasMore,
    int? currentPage,
    String? currentType,
    String? currentCategory,
    String? currentCategoryName,
    DateTime? currentStartDate,
    DateTime? currentEndDate,
    String? currentSearch,
    bool? isLoadingMore,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      currentType: currentType ?? this.currentType,
      currentCategory: currentCategory ?? this.currentCategory,
      currentCategoryName: currentCategoryName ?? this.currentCategoryName,
      currentStartDate: currentStartDate ?? this.currentStartDate,
      currentEndDate: currentEndDate ?? this.currentEndDate,
      currentSearch: currentSearch ?? this.currentSearch,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Indica si hay filtros activos
  bool get hasActiveFilters =>
      currentType != null ||
      currentCategory != null ||
      currentStartDate != null ||
      currentEndDate != null ||
      (currentSearch != null && currentSearch!.isNotEmpty);
}

/// Error al cargar transacciones
class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

