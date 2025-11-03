import 'package:equatable/equatable.dart';
import 'package:quho_app/features/finances/domain/entities/finances_overview.dart';

/// Base class for finances states
abstract class FinancesState extends Equatable {
  const FinancesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FinancesInitial extends FinancesState {}

/// Loading state
class FinancesLoading extends FinancesState {}

/// Loaded state
class FinancesLoaded extends FinancesState {
  final FinancesOverview overview;

  const FinancesLoaded({required this.overview});

  @override
  List<Object?> get props => [overview];
}

/// Error state
class FinancesError extends FinancesState {
  final String message;

  const FinancesError({required this.message});

  @override
  List<Object?> get props => [message];
}

