import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_item.dart';

import 'empty_home_widget.dart';

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
      return SliverFillRemaining(
        child: EmptyHomeScreen(theme: theme, colorScheme: colorScheme),
      );
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final transaction = recentTransactions[index];
            return TransactionListItem(
              transaction: transaction,
            );
          },
          childCount: recentTransactions.length,
        ),
      ),
    );
  }
}
