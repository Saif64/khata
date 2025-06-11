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
      // Attempt to sync after adding. If offline, this will fail gracefully
      // and the transaction will be synced on the next successful sync.
      await syncTransactions();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, List<TransactionEntity>>> getTransactions() async {
    try {
      // First, try to sync with the remote to get the latest data.
      await syncTransactions();
      // Then, fetch the consolidated data from local storage.
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
    } catch (e) {
      // If sync fails (e.g., offline), still return local data.
      final transactions = await localDataSource.getTransactions();
      return Right(transactions);
    }
  }

  @override
  Future<Either<AuthFailure, void>> syncTransactions() async {
    _syncStatusController.add('Syncing');
    try {
      // 1. Get all transactions currently stored locally.
      final localTransactions = await localDataSource.getTransactions();

      // 2. If there are local transactions, push them to the remote first.
      // This ensures offline additions are saved before we refresh our local cache.
      if (localTransactions.isNotEmpty) {
        await remoteDataSource.syncTransactions(localTransactions);
      }

      // 3. Now, fetch the complete and updated list from the remote.
      final remoteTransactions = await remoteDataSource.getTransactions();

      // 4. Clear the local cache completely.
      await localDataSource.clearAllTransactions();

      // 5. Store the fresh, consolidated list from the remote into the local cache.
      for (final transaction in remoteTransactions) {
        await localDataSource.addTransaction(transaction);
      }

      _syncStatusController.add('Synced');
      return const Right(null);
    } catch (e) {
      _syncStatusController.add('Error');
      // Even if sync fails, this is not a fatal error for the app's operation.
      // We can return a success state for the Either, but the sync status will show an error.
      return Left(
          NetworkFailure("Failed to sync transactions: ${e.toString()}"));
    }
  }

  @override
  Stream<String> get syncStatus => _syncStatusController.stream;
}
