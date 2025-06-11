import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_item.dart';

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
        return t.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(endDate);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeftLong,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildDateFilterDropdown(theme, colorScheme),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  return TransactionListItem(
                    transaction: transaction,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
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
}
