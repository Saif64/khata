import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/routes.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';
import 'package:presentation/src/features/home/presentation/widgets/summary_card.dart';
import 'package:presentation/src/features/home/presentation/widgets/sync_status_icon.dart';
import 'package:presentation/src/features/home/presentation/widgets/transaction_list_item.dart';

import '../bloc/home_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when the screen is initialized
    context.read<HomeBloc>().add(LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          const SyncStatusIcon(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
          ),
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeData());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummarySection(state.transactions),
                    const SizedBox(height: 24),
                    Text("Recent Transactions",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    _buildRecentTransactions(state.transactions),
                  ],
                ),
              );
            }
            if (state is HomeError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const Center(child: Text("Welcome!"));
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_sale',
            onPressed: () {
              Navigator.pushNamed(context, Routes.ADD_TRANSACTION,
                  arguments: TransactionType.sale);
            },
            label: const Text("Add Sale"),
            icon: const FaIcon(FontAwesomeIcons.plus),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add_expense',
            onPressed: () {
              Navigator.pushNamed(context, Routes.ADD_TRANSACTION,
                  arguments: TransactionType.expense);
            },
            label: const Text("Add Expense"),
            icon: const FaIcon(FontAwesomeIcons.minus),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(List<TransactionEntity> transactions) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: const [
        SummaryCard(title: "Today's Sales", amount: "1500"),
        SummaryCard(title: "Today's Spending", amount: "500"),
        SummaryCard(title: "Yesterday's Sales", amount: "1200"),
        SummaryCard(title: "Yesterday's Spending", amount: "300"),
      ],
    );
  }

  Widget _buildRecentTransactions(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No transactions yet. Add one!"),
        ),
      );
    }
    // Sort transactions by date, most recent first
    final recent = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length > 10 ? 10 : recent.length,
      itemBuilder: (context, index) {
        return TransactionListItem(transaction: recent[index]);
      },
    );
  }
}
