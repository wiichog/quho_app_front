import 'package:equatable/equatable.dart';

/// Eventos del Dashboard
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar datos del dashboard
class LoadDashboardDataEvent extends DashboardEvent {
  const LoadDashboardDataEvent();
}

/// Refrescar dashboard
class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}

/// Evento para actualizar el balance disponible
class UpdateBalanceEvent extends DashboardEvent {
  final double newBalance;

  const UpdateBalanceEvent(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

/// Evento para cambiar el ordenamiento de las transacciones pendientes
class ChangePendingTransactionsOrderingEvent extends DashboardEvent {
  final String ordering; // 'asc' o 'desc'

  const ChangePendingTransactionsOrderingEvent(this.ordering);

  @override
  List<Object?> get props => [ordering];
}

