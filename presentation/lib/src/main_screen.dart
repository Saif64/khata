import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/core/enums/tab_enum.dart';
import 'package:presentation/src/features/home/presentation/screens/all_transactions_screen.dart';
import 'package:presentation/src/features/home/presentation/screens/home_screen.dart';

class MainLandingScreen extends StatefulWidget {
  final MainScreen tab;
  const MainLandingScreen({super.key, this.tab = MainScreen.home});

  @override
  State<MainLandingScreen> createState() => _MainLandingScreenState();
}

class _MainLandingScreenState extends State<MainLandingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  static const _tabData = [
    (FontAwesomeIcons.houseUser, 'Home'),
    (FontAwesomeIcons.moneyBillTransfer, 'Transactions'),
    (FontAwesomeIcons.bookOpen, 'Due Book'),
    (FontAwesomeIcons.signalMessenger, 'Messaging'),
    (FontAwesomeIcons.peopleGroup, 'Community'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tab.value;
    _tabController = TabController(
        length: _tabData.length, vsync: this, initialIndex: widget.tab.value);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(MainLandingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _tabController.animateTo(widget.tab.value);
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() => _currentIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BottomBar(
        barColor: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(50),
        width: MediaQuery.of(context).size.width * 0.9,
        barAlignment: Alignment.bottomCenter,
        offset: 16,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        hideOnScroll: true,
        body: (context, controller) => TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            PrimaryScrollController(
              controller: controller,
              child: const HomeScreen(),
            ),
            PrimaryScrollController(
              controller: controller,
              child: const AllTransactionsScreen(),
            ),
            const _ComingSoonWidget(),
            const _ComingSoonWidget(),
            const _ComingSoonWidget(),
          ],
        ),
        child: _buildTabBar(theme),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      indicatorColor: theme.colorScheme.primary,
      indicatorWeight: 1,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      tabs: _tabData.asMap().entries.map((entry) {
        final index = entry.key;
        final (icon, label) = entry.value;
        final isSelected = index == _currentIndex;

        return Tab(
          height: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.primary,
                size: 22,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ComingSoonWidget extends StatelessWidget {
  const _ComingSoonWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
