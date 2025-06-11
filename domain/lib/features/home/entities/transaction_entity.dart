import 'package:equatable/equatable.dart';

enum TransactionType { sale, expense }

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String description;
  final TransactionType type;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, description, type, date];
}
