import 'package:domain/domain.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyNetWorthChart extends StatefulWidget {
  final List<TransactionEntity> transactions;

  const WeeklyNetWorthChart({super.key, required this.transactions});

  @override
  State<WeeklyNetWorthChart> createState() => _WeeklyNetWorthChartState();
}

class _WeeklyNetWorthChartState extends State<WeeklyNetWorthChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailySummaries = _calculateDailySummaries(widget.transactions);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      colorScheme.surface.withOpacity(0.8),
                      colorScheme.surface.withOpacity(0.4),
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.6),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme, dailySummaries),
              const SizedBox(height: 24),
              AspectRatio(
                aspectRatio: 1.8,
                child: LineChart(
                  _buildLineChartData(colorScheme, dailySummaries, isDark),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, List<_ChartData> summaries) {
    final currentNetWorth =
        summaries.isNotEmpty ? summaries.last.dailyNetWorth : 0.0;
    final weeklyChange = summaries.isNotEmpty
        ? summaries.last.dailyNetWorth - summaries.first.dailyNetWorth
        : 0.0;
    final isPositive = weeklyChange >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Worth Trend',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${summaries.fold(0.0, (sum, s) => sum + s.dailyNetWorth)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}\$${weeklyChange.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(
      ColorScheme colorScheme, List<_ChartData> summaries, bool isDark) {
    final spots = summaries.asMap().entries.map((entry) {
      return FlSpot(
          entry.key.toDouble(), entry.value.dailyNetWorth * _animation.value);
    }).toList();

    final minY = summaries.isNotEmpty
        ? summaries.map((s) => s.dailyNetWorth).reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxY = summaries.isNotEmpty
        ? summaries.map((s) => s.dailyNetWorth).reduce((a, b) => a > b ? a : b)
        : 100.0;
    final range = maxY - minY;
    final padding = range > 0 ? range * 0.1 : 10.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: range > 0 ? range / 4 : 100,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withOpacity(0.1),
            strokeWidth: 1,
            dashArray: [4, 4],
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final index = value.toInt();
              if (index >= 0 && index < days.length) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: minY - padding,
      maxY: maxY + padding,
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse?.lineBarSpots?.isNotEmpty == true) {
              touchedIndex = touchResponse!.lineBarSpots!.first.spotIndex;
            } else {
              touchedIndex = null;
            }
          });
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              const days = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ];
              final dayIndex = spot.x.toInt();

              // Add bounds checking
              if (dayIndex < 0 ||
                  dayIndex >= days.length ||
                  dayIndex >= summaries.length) {
                return LineTooltipItem('', const TextStyle());
              }

              final dayName = days[dayIndex];
              final data = summaries[dayIndex];

              return LineTooltipItem(
                '',
                const TextStyle(),
                children: [
                  TextSpan(
                    text: '$dayName\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Net Worth: \$${data.dailyNetWorth.toStringAsFixed(0)}\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: 'Sales: \$${data.sales.toStringAsFixed(0)}\n',
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: 'Expenses: \$${data.expenses.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          getTooltipColor: (touchedSpot) =>
              colorScheme.inverseSurface.withOpacity(0.9),
          tooltipBorderRadius: BorderRadius.circular(12),
          tooltipPadding: const EdgeInsets.all(12),
          tooltipMargin: 8,
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: colorScheme.primary.withOpacity(0.8),
                strokeWidth: 2,
                dashArray: [4, 4],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 8,
                  color: colorScheme.primary,
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                ),
              ),
            );
          }).toList();
        },
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSelected = touchedIndex == index;
              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: isSelected ? colorScheme.primary : Colors.white,
                strokeWidth: 2,
                strokeColor: colorScheme.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withOpacity(0.3),
                colorScheme.primary.withOpacity(0.1),
                colorScheme.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_ChartData> _calculateDailySummaries(
      List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final last7Days =
        List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    final summaries = List.generate(
        7,
        (index) => _ChartData(
              dayOfWeek: index,
              sales: 0,
              expenses: 0,
              dailyNetWorth: 0,
            ));

    // Calculate daily sales and expenses
    for (final transaction in transactions) {
      for (int i = 0; i < last7Days.length; i++) {
        final day = last7Days[i];
        if (transaction.date.year == day.year &&
            transaction.date.month == day.month &&
            transaction.date.day == day.day) {
          if (transaction.type == TransactionType.sale) {
            summaries[i].sales += transaction.amount;
          } else {
            summaries[i].expenses += transaction.amount;
          }
        }
      }
    }

    // Calculate cumulative net worth
    double runningTotal = 0;
    for (int i = 0; i < summaries.length; i++) {
      final dailyNet = summaries[i].sales - summaries[i].expenses;
      summaries[i].dailyNetWorth = dailyNet;
    }

    return summaries;
  }
}

class _ChartData {
  final int dayOfWeek;
  double sales;
  double expenses;
  double dailyNetWorth;

  _ChartData({
    required this.dayOfWeek,
    required this.sales,
    required this.expenses,
    required this.dailyNetWorth,
  });
}
