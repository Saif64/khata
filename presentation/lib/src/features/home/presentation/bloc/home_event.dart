import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

class AddTransaction extends HomeEvent {
  final TransactionEntity transaction;
  const AddTransaction(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class EditTransaction extends HomeEvent {
  final TransactionEntity transaction;
  const EditTransaction(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends HomeEvent {
  final String transactionId;
  const DeleteTransaction(this.transactionId);
  @override
  List<Object> get props => [transactionId];
}

class FilterTransactions extends HomeEvent {
  final String filter;
  const FilterTransactions(this.filter);
  @override
  List<Object> get props => [filter];
}
