import 'package:domain/domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDataSource {
  Future<void> syncTransactions(List<TransactionEntity> transactions);
  Future<List<TransactionEntity>> getTransactions();

  Future<void> deleteTransaction(String transactionId);
  Future<void> editTransaction(TransactionEntity transaction);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final response = await supabaseClient
        .from('transactions')
        .select()
        .eq('user_id', supabaseClient.auth.currentUser!.id);

    final transactions = (response as List)
        .map((item) => TransactionEntity(
              id: item['id'],
              amount: (item['amount'] as num).toDouble(),
              description: item['description'],
              type: (item['type'] as String) == 'TransactionType.sale'
                  ? TransactionType.sale
                  : TransactionType.expense,
              date: DateTime.parse(item['date']),
            ))
        .toList();
    return transactions;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await supabaseClient.from('transactions').delete().eq('id', transactionId);
  }

  @override
  Future<void> editTransaction(TransactionEntity transaction) async {
    await supabaseClient.from('transactions').update({
      'amount': transaction.amount,
      'description': transaction.description,
      'type': transaction.type.toString(),
      'date': transaction.date.toIso8601String(),
    }).eq('id', transaction.id);
  }

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
