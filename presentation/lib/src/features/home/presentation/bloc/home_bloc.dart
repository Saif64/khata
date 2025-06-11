import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  final List<TransactionEntity> _allTransactions = [];

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<AddTransaction>(_onAddTransaction);
    on<FilterTransactions>(_onFilterTransactions);

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
      (transactions) {
        _allTransactions.clear();
        _allTransactions.addAll(transactions);
        emit(HomeLoaded(transactions, 'Synced'));
      },
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

  void _onFilterTransactions(
      FilterTransactions event, Emitter<HomeState> emit) {
    final now = DateTime.now();
    List<TransactionEntity> filteredTransactions;

    DateTime startDate;
    DateTime endDate;

    switch (event.filter) {
      case 'This week':
        final weekDay = now.weekday;
        startDate = DateTime(now.year, now.month, now.day - (weekDay - 1));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last week':
        final weekDay = now.weekday;
        startDate = DateTime(now.year, now.month, now.day - (weekDay - 1) - 7);
        endDate = DateTime(
            now.year, now.month, now.day - (weekDay - 1) - 1, 23, 59, 59);
        break;
      case 'This month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'Last month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      default:
        filteredTransactions = List.from(_allTransactions);
        emit(
            HomeLoaded(filteredTransactions, (state as HomeLoaded).syncStatus));
        return;
    }

    filteredTransactions = _allTransactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(endDate);
    }).toList();

    if (state is HomeLoaded) {
      emit(HomeLoaded(filteredTransactions, (state as HomeLoaded).syncStatus));
    }
  }
}
