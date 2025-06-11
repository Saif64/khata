import 'dart:async';

import 'package:data/features/home/datasources/local/home_local_datasource.dart';
import 'package:data/features/home/datasources/remote/home_remote_datasource.dart';
import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final _syncStatusController = StreamController<String>.broadcast();

  HomeRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<AuthFailure, void>> addTransaction(
      TransactionEntity transaction) async {
    try {
      await localDataSource.addTransaction(transaction);

      await syncTransactions();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, List<TransactionEntity>>> getTransactions() async {
    try {
      await syncTransactions();
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
    } catch (e) {
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
    }
  }

  @override
  Future<Either<AuthFailure, void>> deleteTransaction(
      String transactionId) async {
    try {
      await localDataSource.deleteTransaction(transactionId);

      await remoteDataSource
          .deleteTransaction(transactionId)
          .catchError((_) {});
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> editTransaction(
      TransactionEntity transaction) async {
    try {
      await localDataSource.editTransaction(transaction);

      await syncTransactions();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> syncTransactions() async {
    _syncStatusController.add('Syncing');
    try {
      final localTransactions = await localDataSource.getTransactions();

      if (localTransactions.isNotEmpty) {
        await remoteDataSource.syncTransactions(localTransactions);
      }

      final remoteTransactions = await remoteDataSource.getTransactions();

      await localDataSource.clearAllTransactions();

      for (final transaction in remoteTransactions) {
        await localDataSource.addTransaction(transaction);
      }

      _syncStatusController.add('Synced');
      return const Right(null);
    } catch (e) {
      _syncStatusController.add('Error');
      return Left(
          NetworkFailure("Failed to sync transactions: ${e.toString()}"));
    }
  }

  @override
  Stream<String> get syncStatus => _syncStatusController.stream;
}
