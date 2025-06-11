import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<AddTransaction>(_onAddTransaction);

    homeRepository.syncStatus.listen((status) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(HomeLoaded(currentState.transactions, status));
      }
    });
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final failureOrTransactions = await homeRepository.getTransactions();
    failureOrTransactions.fold(
      (failure) => emit(HomeError(failure.message)),
      (transactions) => emit(HomeLoaded(transactions, 'Synced')),
    );
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    final failureOrVoid =
        await homeRepository.addTransaction(event.transaction);

    failureOrVoid.fold(
      (failure) => emit(HomeError(failure.message)),
      (_) => add(LoadHomeData()),
    );
  }
}
