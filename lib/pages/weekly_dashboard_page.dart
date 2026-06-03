import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/app_state.dart';

class WeeklyDashboardPage extends StatefulWidget {
  const WeeklyDashboardPage({Key? key}) : super(key: key);

  @override
  State<WeeklyDashboardPage> createState() => _WeeklyDashboardPageState();
}

class _WeeklyDashboardPageState extends State<WeeklyDashboardPage> {
  String _selectedChart = 'calories';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wochen-Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          state.calculateWeeklySummary(),
          state.calculateWeeklyDayBreakdown(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Fehler beim Laden des Dashboards: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final summary = snapshot.data![0] as WeeklyNutritionSummary;
          final breakdown = snapshot.data![1] as List<WeeklyDaySummary>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Overview Summary Cards
                Text(
                  'Wochenübersicht',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildSummaryCard(
                      context,
                      title: 'Durchschnitt',
                      value: '${summary.averageCalories.toStringAsFixed(0)} kcal',
                      subtitle: 'pro Tag (Ø)',
                      icon: Icons.flash_on,
                      color: Colors.orange,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'Verbleibend',
                      value: '${summary.remainingCalories.toStringAsFixed(0)} kcal',
                      subtitle: 'in dieser Woche',
                      icon: Icons.hourglass_empty,
                      color: Colors.blue,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'Makros',
                      value: '${summary.macroAdherence.toStringAsFixed(0)}%',
                      subtitle: 'Ziel-Adhärenz',
                      icon: Icons.track_changes,
                      color: Colors.purple,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'Gewichtstrend',
                      value: '${summary.weightTrend >= 0 ? '+' : ''}${summary.weightTrend.toStringAsFixed(1)} kg',
                      subtitle: 'letzte 7 Tage',
                      icon: Icons.trending_up,
                      color: summary.weightTrend <= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section: Visual Chart Analysis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diagramm-Analyse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'calories',
                          label: Text('Kalorien', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.flash_on, size: 14),
                        ),
                        ButtonSegment<String>(
                          value: 'macros',
                          label: Text('Makros', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.track_changes, size: 14),
                        ),
                      ],
                      selected: {_selectedChart},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedChart = selection.first;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _selectedChart == 'calories'
                                ? KeyedSubtree(
                                    key: const ValueKey('calorie_chart'),
                                    child: _buildCalorieChart(state, breakdown),
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey('macro_chart'),
                                    child: _buildMacroChart(breakdown),
                                  ),
                          ),
                        ),
                        if (_selectedChart == 'macros') ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem('KH', Colors.purple),
                              const SizedBox(width: 16),
                              _buildLegendItem('Prot', Colors.green),
                              const SizedBox(width: 16),
                              _buildLegendItem('Fett', Colors.blue),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Detailed Day-by-Day Breakdown
                Text(
                  'Tagesübersicht',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdown.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final day = breakdown[index];
                    final double percent = state.dailyCalorieGoal > 0
                        ? (day.calories / state.dailyCalorieGoal).clamp(0.0, 1.0)
                        : 0.0;
                    
                    final isToday = DateFormat('yyyy-MM-dd').format(day.date) ==
                        DateFormat('yyyy-MM-dd').format(DateTime.now());

                    return Card(
                      elevation: isToday ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isToday
                            ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      day.dayName,
                                      style: TextStyle(
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isToday) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Heute',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '${day.calories.toStringAsFixed(0)} / ${state.dailyCalorieGoal} kcal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: percent,
                              progressColor: _getProgressColor(percent),
                              backgroundColor: Colors.grey[300]!,
                              barRadius: const Radius.circular(4),
                              animation: true,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'K: ${day.carbs.toStringAsFixed(0)}g',
                                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                                ),
                                Text(
                                  'P: ${day.protein.toStringAsFixed(0)}g',
                                  style: const TextStyle(fontSize: 12, color: Colors.green),
                                ),
                                Text(
                                  'F: ${day.fat.toStringAsFixed(0)}g',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieChart(AppState state, List<WeeklyDaySummary> breakdown) {
    final double maxCalories = breakdown.map((e) => e.calories).reduce((a, b) => a > b ? a : b);
    final double limitY = (maxCalories > state.dailyCalorieGoal ? maxCalories : state.dailyCalorieGoal.toDouble()) * 1.15;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: limitY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(0)} kcal',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      days[index],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: breakdown.asMap().entries.map((e) {
          final index = e.key;
          final day = e.value;
          final isOverGoal = day.calories > state.dailyCalorieGoal;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: day.calories,
                color: isOverGoal ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: state.dailyCalorieGoal.toDouble(),
                  color: Colors.grey[200],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMacroChart(List<WeeklyDaySummary> breakdown) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final label = spot.barIndex == 0
                    ? 'K'
                    : spot.barIndex == 1
                        ? 'P'
                        : 'F';
                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(0)}g',
                  TextStyle(
                    color: spot.barIndex == 0
                        ? Colors.purpleAccent
                        : spot.barIndex == 1
                            ? Colors.greenAccent
                            : Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      days[index],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // Carbs (purple)
          LineChartBarData(
            spots: breakdown.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.carbs)).toList(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          // Protein (green)
          LineChartBarData(
            spots: breakdown.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.protein)).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          // Fat (blue)
          LineChartBarData(
            spots: breakdown.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.fat)).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getProgressColor(double percent) {
    if (percent < 0.5) return Colors.blue;
    if (percent <= 1.0) return Colors.green;
    return Colors.red;
  }
}
