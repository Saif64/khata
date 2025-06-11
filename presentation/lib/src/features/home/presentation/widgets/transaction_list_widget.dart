import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'empty_home_widget.dart';
import 'transaction_items_widget.dart';

class TransactionListWidget extends StatelessWidget {
  const TransactionListWidget({
    super.key,
    required String selectedFilter,
    required this.transactions,
    required this.theme,
    required this.colorScheme,
  }) : _selectedFilter = selectedFilter;

  final String _selectedFilter;
  final List<TransactionEntity> transactions;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return EmptyHomeScreen(theme: theme, colorScheme: colorScheme);
    }

    List<TransactionEntity> filteredTransactions = transactions;
    if (_selectedFilter == 'Sales') {
      filteredTransactions =
          transactions.where((t) => t.type == TransactionType.sale).toList();
    } else if (_selectedFilter == 'Expenses') {
      filteredTransactions =
          transactions.where((t) => t.type == TransactionType.expense).toList();
    }

    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    final recentTransactions = filteredTransactions.take(10).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: recentTransactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionItemsWidget(
                  transaction: transaction,
                  theme: theme,
                  colorScheme: colorScheme),
            ),
          );
        }).toList(),
      ),
    );
  }
}
