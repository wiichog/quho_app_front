import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quho_app/features/finances/domain/usecases/get_finances_overview_usecase.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_event.dart';
import 'package:quho_app/features/finances/presentation/bloc/finances_state.dart';

/// Bloc for finances overview
class FinancesBloc extends Bloc<FinancesEvent, FinancesState> {
  final GetFinancesOverviewUseCase getFinancesOverviewUseCase;

  FinancesBloc({
    required this.getFinancesOverviewUseCase,
  }) : super(FinancesInitial()) {
    on<LoadFinancesOverviewEvent>(_onLoadFinancesOverview);
    on<RefreshFinancesOverviewEvent>(_onRefreshFinancesOverview);
  }

  Future<void> _onLoadFinancesOverview(
    LoadFinancesOverviewEvent event,
    Emitter<FinancesState> emit,
  ) async {
    emit(FinancesLoading());

    final result = await getFinancesOverviewUseCase(month: event.month);

    result.fold(
      (failure) => emit(FinancesError(message: failure.message)),
      (overview) => emit(FinancesLoaded(overview: overview)),
    );
  }

  Future<void> _onRefreshFinancesOverview(
    RefreshFinancesOverviewEvent event,
    Emitter<FinancesState> emit,
  ) async {
    // Don't emit loading state on refresh to avoid UI flicker
    final result = await getFinancesOverviewUseCase(month: event.month);

    result.fold(
      (failure) => emit(FinancesError(message: failure.message)),
      (overview) => emit(FinancesLoaded(overview: overview)),
    );
  }
}

