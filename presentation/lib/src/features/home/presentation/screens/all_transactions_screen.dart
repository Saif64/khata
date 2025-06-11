import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/theme/app_theme.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_item.dart';

import '../../../../../core/widgets/back_button.dart';

class AllTransactionsScreen extends StatefulWidget {
  final List<TransactionEntity> transactions;

  const AllTransactionsScreen({super.key, required this.transactions});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  late List<TransactionEntity> _filteredTransactions;
  String _selectedFilter = 'This month';
  final List<String> _dateFilters = [
    'This week',
    'Last week',
    'This month',
    'Last month'
  ];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = widget.transactions;
    _filterTransactions(_selectedFilter);
  }

  void _filterTransactions(String filter) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (filter) {
      case 'This week':
        final weekDay = now.weekday;
        startDate = DateTime(now.year, now.month, now.day - (weekDay - 1));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Last week':
        final weekDay = now.weekday;
        startDate = DateTime(now.year, now.month, now.day - (weekDay - 1) - 7);
        endDate = DateTime(
            now.year, now.month, now.day - (weekDay - 1) - 1, 23, 59, 59);
        break;
      case 'This month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'Last month':
        startDate = DateTime(now.year, now.month - 1, 1);
        endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
      default:
        setState(() {
          _filteredTransactions = widget.transactions;
        });
        return;
    }

    setState(() {
      _filteredTransactions = widget.transactions.where((t) {
        final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);

        return (transactionDate.isAtSameMomentAs(start) ||
                transactionDate.isAfter(start)) &&
            (transactionDate.isAtSameMomentAs(end) ||
                transactionDate.isBefore(end));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, colorScheme),
          SliverToBoxAdapter(
            child: _buildFilterSection(theme, colorScheme),
          ),
          _buildTransactionsList(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      leading: const ThemedIconButton.back(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'All Transactions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.filter,
                color: colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Period',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateFilterDropdown(theme, colorScheme),
          const SizedBox(height: 12),
          Text(
            '${_filteredTransactions.length} transactions found',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          icon: Icon(
            FontAwesomeIcons.chevronDown,
            color: colorScheme.onSurfaceVariant,
            size: 14,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          borderRadius: BorderRadius.circular(12),
          items: _dateFilters.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
              });
              _filterTransactions(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme, ColorScheme colorScheme) {
    if (_filteredTransactions.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(theme, colorScheme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final transaction = _filteredTransactions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: colorScheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TransactionListItem(
                transaction: transaction,
              ),
            );
          },
          childCount: _filteredTransactions.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.receipt,
              color: colorScheme.onSurfaceVariant,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different time period',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
