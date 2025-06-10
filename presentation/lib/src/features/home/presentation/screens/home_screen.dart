import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/routes.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';
import 'package:presentation/src/features/home/presentation/widgets/sync_status_icon.dart';

import '../bloc/home_event.dart';
import '../widgets/summary_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    context.read<HomeBloc>().add(LoadHomeData());
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Track your finances',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          const SyncStatusIcon(),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.error),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/signIn', (route) => false);
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return _buildLoadingState();
            }
            if (state is HomeLoaded) {
              return _buildLoadedState(state, theme, colorScheme);
            }
            if (state is HomeError) {
              return _buildErrorState(state.message, theme);
            }
            return _buildWelcomeState(theme);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Loading your data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.chartLine,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to your Dashboard!',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your finances',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
      HomeLoaded state, ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(LoadHomeData());
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildModernSummary(state.transactions),
                      const SizedBox(height: 32),
                      _buildTransactionsHeader(theme),
                      const SizedBox(height: 16),
                      _buildFilterChips(theme, colorScheme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                _buildTransactionsList(state.transactions, theme, colorScheme),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Space for FAB
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummary(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todaysSales = transactions
        .where((t) => t.type == TransactionType.sale && _isToday(t.date, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final todaysExpenses = transactions
        .where(
            (t) => t.type == TransactionType.expense && _isToday(t.date, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final yesterdaysSales = transactions
        .where((t) =>
            t.type == TransactionType.sale &&
            _isYesterday(t.date, yesterday, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final yesterdaysExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            _isYesterday(t.date, yesterday, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    return ModernSummaryWidget(
      todaysSales: todaysSales,
      todaysSpending: todaysExpenses,
      yesterdaysSales: yesterdaysSales,
      yesterdaysSpending: yesterdaysExpenses,
    );
  }

  Widget _buildTransactionsHeader(ThemeData theme) {
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
            // Navigate to full transactions list
          },
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme) {
    final filters = ['All', 'Sales', 'Expenses'];

    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: isSelected,
            label: Text(filter),
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            backgroundColor: colorScheme.surface,
            selectedColor: colorScheme.primary.withOpacity(0.2),
            checkmarkColor: colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.2),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionsList(List<TransactionEntity> transactions,
      ThemeData theme, ColorScheme colorScheme) {
    if (transactions.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    // Filter transactions based on selected filter
    List<TransactionEntity> filteredTransactions = transactions;
    if (_selectedFilter == 'Sales') {
      filteredTransactions =
          transactions.where((t) => t.type == TransactionType.sale).toList();
    } else if (_selectedFilter == 'Expenses') {
      filteredTransactions =
          transactions.where((t) => t.type == TransactionType.expense).toList();
    }

    // Sort by date, most recent first
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Take only recent transactions for display
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
              child: _buildTransactionItem(transaction, theme, colorScheme),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(
      TransactionEntity transaction, ThemeData theme, ColorScheme colorScheme) {
    final isSale = transaction.type == TransactionType.sale;
    final color = isSale ? colorScheme.primary : colorScheme.error;
    final icon = isSale
        ? FontAwesomeIcons.arrowTrendUp
        : FontAwesomeIcons.arrowTrendDown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isSale ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSale ? 'Sale' : 'Expense',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              FontAwesomeIcons.receipt,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first sale or expense using the buttons below',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(ColorScheme colorScheme) {
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

  bool _isToday(DateTime date, DateTime today) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isYesterday(DateTime date, DateTime yesterday, DateTime today) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly == yesterday;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}
