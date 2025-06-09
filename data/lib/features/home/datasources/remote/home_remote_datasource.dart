import 'package:domain/domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  Future<void> syncTransactions(List<TransactionEntity> transactions);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<void> syncTransactions(List<TransactionEntity> transactions) async {
    final List<Map<String, dynamic>> data = transactions
        .map((t) => {
              'id': t.id,
              'amount': t.amount,
              'description': t.description,
              'type': t.type.toString(),
              'date': t.date.toIso8601String(),
              'user_id': supabaseClient.auth.currentUser!.id,
            })
        .toList();
    await supabaseClient.from('transactions').upsert(data);
  }
}
