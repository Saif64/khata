import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TransactionEntity> transactions;
  final String syncStatus;

  const HomeLoaded(this.transactions, this.syncStatus);
  @override
  List<Object> get props => [transactions, syncStatus];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
