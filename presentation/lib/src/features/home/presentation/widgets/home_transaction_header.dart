import 'package:flutter/material.dart';
import 'package:presentation/core/routes.dart';

class HomeTransactionHeader extends StatelessWidget {
  const HomeTransactionHeader({
    super.key,
    required this.context,
    required this.theme,
  });

  final BuildContext context;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, Routes.ALL_TRANSACTION);
          },
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('View All'),
        ),
      ],
    );
  }
}
