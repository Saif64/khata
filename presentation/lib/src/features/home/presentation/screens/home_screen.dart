import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/utils/time_utils.dart';
import 'package:presentation/core/widgets/loader.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_widget.dart';

import '../bloc/home_event.dart';
import '../widgets/home_floating_action_buttons.dart';
import '../widgets/summary_table.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/weekly_net_worth_chart.dart';
import 'all_transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'This month';
  final List<String> _dateFilters = [
    'This week',
    'Last week',
    'This month',
    'Last month'
  ];
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
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Track your finances',
              style: theme.textTheme.bodyMedium?.copyWith(
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
              return Loader();
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
      floatingActionButton:
          HomeFloatingActionButtons(context: context, colorScheme: colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                      WeeklyNetWorthChart(transactions: state.transactions),
                      const SizedBox(height: 16),
                      _buildDateFilterDropdown(theme, colorScheme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TransactionListWidget(
            transactions: state.transactions,
            theme: theme,
            colorScheme: colorScheme,
            selectedFilter: _selectedFilter,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
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
              context.read<HomeBloc>().add(FilterTransactions(newValue));
            }
          },
        ),
      ),
    );
  }

  Widget _buildModernSummary(List<TransactionEntity> transactions) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllTransactionsScreen(
                  transactions: (context.read<HomeBloc>().state as HomeLoaded)
                      .transactions,
                ),
              ),
            );
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
}
