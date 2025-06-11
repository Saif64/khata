import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/routes.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_action_buttons.dart';

class HomeActionButtonCard extends StatelessWidget {
  const HomeActionButtonCard({
    super.key,
    required Animation<double> quickActionsAnimation,
    required this.context,
    required this.colorScheme,
    required this.theme,
  }) : _quickActionsAnimation = quickActionsAnimation;

  final Animation<double> _quickActionsAnimation;
  final BuildContext context;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _quickActionsAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.8),
              colorScheme.primaryContainer.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: HomeActionButton(
                    icon: FontAwesomeIcons.arrowTrendUp,
                    label: 'Add Sale',
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.ADD_TRANSACTION,
                        arguments: TransactionType.sale,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeActionButton(
                    icon: FontAwesomeIcons.arrowTrendDown,
                    label: 'Add Expense',
                    color: colorScheme.error,
                    backgroundColor: colorScheme.error.withOpacity(0.1),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.ADD_TRANSACTION,
                        arguments: TransactionType.expense,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
