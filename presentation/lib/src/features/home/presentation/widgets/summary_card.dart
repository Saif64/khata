import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:presentation/core/utils/time_utils.dart';

import 'summary_table.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todaysSales = transactions
        .where((t) =>
            t.type == TransactionType.sale && TimeUtils.isToday(t.date, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final todaysExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            TimeUtils.isToday(t.date, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final yesterdaysSales = transactions
        .where((t) =>
            t.type == TransactionType.sale &&
            TimeUtils.isYesterday(t.date, yesterday, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final yesterdaysExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            TimeUtils.isYesterday(t.date, yesterday, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    return SummaryWidget(
      todaysSales: todaysSales,
      todaysSpending: todaysExpenses,
      yesterdaysSales: yesterdaysSales,
      yesterdaysSpending: yesterdaysExpenses,
    );
  }
}
