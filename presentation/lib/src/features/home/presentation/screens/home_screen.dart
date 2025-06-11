import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/routes.dart';
import 'package:presentation/core/widgets/loader.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_action_buttons.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_error_view.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_transaction_header.dart';
import 'package:presentation/src/features/home/presentation/widgets/home_welcome_header.dart';
import 'package:presentation/src/features/home/presentation/widgets/summary_card.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_widget.dart';

import '../bloc/home_event.dart';
import '../widgets/sync_status_icon.dart';
import '../widgets/weekly_net_worth_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _quickActionsController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _quickActionsAnimation;

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
    _quickActionsController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _quickActionsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _quickActionsController,
        curve: Curves.elasticOut,
      ),
    );

    context.read<HomeBloc>().add(LoadHomeData());
    _animationController.forward();

    // Delay quick actions animation
    Future.delayed(const Duration(milliseconds: 400), () {
      _quickActionsController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quickActionsController.dispose();
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
      // Remove floating action buttons to avoid conflict with bottom nav
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
                      // Quick Actions Section
                      HomeActionButtonCard(
                          quickActionsAnimation: _quickActionsAnimation,
                          context: context,
                          colorScheme: colorScheme,
                          theme: theme),
                      const SizedBox(height: 24),

                      SummaryCard(transactions: state.transactions),
                      const SizedBox(height: 32),
                      HomeTransactionHeader(context: context, theme: theme),
                      const SizedBox(height: 16),
                      WeeklyNetWorthChart(transactions: state.transactions),
                      const SizedBox(height: 16),
                      _buildDateFilterChips(theme, colorScheme),
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
            child: SizedBox(height: 120), // Extra space for floating bottom nav
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterChips(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _dateFilters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter),
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
                context.read<HomeBloc>().add(FilterTransactions(filter));
              },
              backgroundColor: colorScheme.secondary,
              selectedColor: colorScheme.primary,
              checkmarkColor: theme.canvasColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}

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
