import 'package:equatable/equatable.dart';

/// Eventos del BLoC de transacciones
abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar transacciones con filtros
class LoadTransactionsEvent extends TransactionsEvent {
  final int page;
  final String? type; // 'income', 'expense', o null para todos
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;
  final bool isRefresh; // Si es true, limpia la lista actual

  const LoadTransactionsEvent({
    this.page = 1,
    this.type,
    this.category,
    this.startDate,
    this.endDate,
    this.search,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, type, category, startDate, endDate, search, isRefresh];
}

/// Aplicar filtros
class ApplyFiltersEvent extends TransactionsEvent {
  final String? type;
  final String? category; // ID de la categoría
  final String? categoryName; // Nombre de la categoría para mostrar
  final DateTime? startDate;
  final DateTime? endDate;

  const ApplyFiltersEvent({
    this.type,
    this.category,
    this.categoryName,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, category, categoryName, startDate, endDate];
}

/// Buscar transacciones
class SearchTransactionsEvent extends TransactionsEvent {
  final String query;

  const SearchTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Limpiar filtros
class ClearFiltersEvent extends TransactionsEvent {
  const ClearFiltersEvent();
}

/// Cargar más transacciones (paginación)
class LoadMoreTransactionsEvent extends TransactionsEvent {
  const LoadMoreTransactionsEvent();
}

