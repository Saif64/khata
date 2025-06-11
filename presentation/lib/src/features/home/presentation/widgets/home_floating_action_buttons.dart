import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/routes.dart';

class HomeFloatingActionButtons extends StatelessWidget {
  const HomeFloatingActionButtons({
    super.key,
    required this.context,
    required this.colorScheme,
  });

  final BuildContext context;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'add_sale',
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.ADD_TRANSACTION,
              arguments: TransactionType.sale,
            );
          },
          label: const Text('Add Sale'),
          icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'add_expense',
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.ADD_TRANSACTION,
              arguments: TransactionType.expense,
            );
          },
          label: const Text('Add Expense'),
          icon: const FaIcon(FontAwesomeIcons.minus, size: 16),
          backgroundColor: colorScheme.error,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
      ],
    );
  }
}
