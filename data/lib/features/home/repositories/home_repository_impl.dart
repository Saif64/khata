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
      syncTransactions();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, List<TransactionEntity>>> getTransactions() async {
    try {
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
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
      _syncStatusController.add('Synced');
      return const Right(null);
    } catch (e) {
      _syncStatusController.add('Error');
      return Left(NetworkFailure("Failed to sync transactions"));
    }
  }

  @override
  Stream<String> get syncStatus => _syncStatusController.stream;
}
