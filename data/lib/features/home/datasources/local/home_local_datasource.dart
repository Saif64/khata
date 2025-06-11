import 'package:domain/domain.dart';
import 'package:hive/hive.dart';

abstract class HomeLocalDataSource {
  Future<void> addTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getTransactions();
  Future<void> clearAllTransactions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final Box<TransactionEntity> transactionBox;

  HomeLocalDataSourceImpl(this.transactionBox);

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    return transactionBox.values.toList();
  }

  @override
  Future<void> clearAllTransactions() async {
    await transactionBox.clear();
  }
}
