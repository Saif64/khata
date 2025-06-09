import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color =
        transaction.type == TransactionType.sale ? Colors.green : Colors.red;
    final icon = transaction.type == TransactionType.sale
        ? FontAwesomeIcons.arrowUp
        : FontAwesomeIcons.arrowDown;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: FaIcon(icon, color: color),
        title: Text(transaction.description),
        trailing: Text(
          "${transaction.type == TransactionType.sale ? '+' : '-'} \$${transaction.amount.toStringAsFixed(2)}",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
