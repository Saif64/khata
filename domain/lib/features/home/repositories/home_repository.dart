import 'package:domain/features/auth/failures/auth_failure.dart';
import 'package:domain/features/home/entities/transaction_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class HomeRepository {
  Future<Either<AuthFailure, void>> addTransaction(
      TransactionEntity transaction);
  Future<Either<AuthFailure, List<TransactionEntity>>> getTransactions();
  Future<Either<AuthFailure, void>> syncTransactions();
  Stream<String> get syncStatus;
}
