import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation/core/widgets/loader.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_error_view.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_transaction_header.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_welcome_header.dart';
import 'package:presentation/src/features/home/presentation/widgets/summary_card.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_widget.dart';

import '../bloc/home_event.dart';
import '../widgets/home_floating_action_buttons.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/weekly_net_worth_chart.dart';

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
              return HomeErrorView(message: state.message, theme: theme);
            }
            return HomeWelcomeHeader(theme: theme);
          },
        ),
      ),
      floatingActionButton:
          HomeFloatingActionButtons(context: context, colorScheme: colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                      SummaryCard(transactions: state.transactions),
                      const SizedBox(height: 32),
                      HomeTransactionHeader(context: context, theme: theme),
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
}
