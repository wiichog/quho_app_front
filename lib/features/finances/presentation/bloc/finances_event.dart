import 'package:equatable/equatable.dart';

/// Base class for finances events
abstract class FinancesEvent extends Equatable {
  const FinancesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load finances overview
class LoadFinancesOverviewEvent extends FinancesEvent {
  final String month;

  const LoadFinancesOverviewEvent({required this.month});

  @override
  List<Object?> get props => [month];
}

/// Event to refresh finances overview
class RefreshFinancesOverviewEvent extends FinancesEvent {
  final String month;

  const RefreshFinancesOverviewEvent({required this.month});

  @override
  List<Object?> get props => [month];
}

