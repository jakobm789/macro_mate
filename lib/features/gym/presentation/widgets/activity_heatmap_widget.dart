import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({
    super.key,
    required this.activityStartTimes,
    this.weeksToShow = 20,
    this.now,
  });

  final Iterable<String> activityStartTimes;
  final int weeksToShow;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTime = this.now ?? DateTime.now();
    final now = DateTime(currentTime.year, currentTime.month, currentTime.day);

    // Map workouts by ISO Date string YYYY-MM-DD
    final workoutCountsByDay = <String, int>{};
    for (final startTime in activityStartTimes) {
      final date = DateTime.tryParse(startTime)?.toLocal();
      if (date == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      workoutCountsByDay[dateKey] = (workoutCountsByDay[dateKey] ?? 0) + 1;
    }

    final totalWorkouts =
        workoutCountsByDay.values.fold<int>(0, (sum, value) => sum + value);

    // Calculate start date aligned to Monday
    final currentWeekday = now.weekday; // 1 (Mon) .. 7 (Sun)
    final thisSunday = now.add(Duration(days: 7 - currentWeekday));
    final startDate =
        thisSunday.subtract(Duration(days: (weeksToShow * 7) - 1));

    // Calculate current streak
    var currentStreak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(checkDate);
      if ((workoutCountsByDay[key] ?? 0) > 0) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Allow today to not yet be completed if yesterday was
        if (checkDate.year == now.year &&
            checkDate.month == now.month &&
            checkDate.day == now.day) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trainingsaktivität',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Serie: $currentStreak Tage',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$totalWorkouts Workouts in der Historie erfasst',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 16),
            // Heatmap Grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // Scroll to newest by default
              child: Row(
                children: [
                  for (var week = 0; week < weeksToShow; week++) ...[
                    Column(
                      children: [
                        for (var day = 0; day < 7; day++) ...[
                          _buildHeatmapCell(
                            context,
                            date:
                                startDate.add(Duration(days: (week * 7) + day)),
                            workoutCounts: workoutCountsByDay,
                            now: now,
                          ),
                          const SizedBox(height: 3),
                        ],
                      ],
                    ),
                    const SizedBox(width: 3),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Weniger',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: 10, color: theme.hintColor)),
                const SizedBox(width: 4),
                _legendSquare(context, 0),
                const SizedBox(width: 2),
                _legendSquare(context, 1),
                const SizedBox(width: 2),
                _legendSquare(context, 2),
                const SizedBox(width: 4),
                Text('Mehr',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: 10, color: theme.hintColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCell(
    BuildContext context, {
    required DateTime date,
    required Map<String, int> workoutCounts,
    required DateTime now,
  }) {
    final theme = Theme.of(context);
    final key = DateFormat('yyyy-MM-dd').format(date);
    final isFuture = date.isAfter(now);
    final count = isFuture ? 0 : (workoutCounts[key] ?? 0);

    Color cellColor;
    if (isFuture) {
      cellColor = Colors.transparent;
    } else if (count == 0) {
      cellColor = theme.brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade200;
    } else if (count == 1) {
      cellColor = Colors.deepOrangeAccent.shade200;
    } else {
      cellColor = Colors.deepOrangeAccent.shade700;
    }

    return Tooltip(
      message: isFuture ? '' : '$key: $count Aktivität(en)',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _legendSquare(BuildContext context, int level) {
    final theme = Theme.of(context);
    final color = switch (level) {
      0 => theme.brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade200,
      1 => Colors.deepOrangeAccent.shade200,
      _ => Colors.deepOrangeAccent.shade700,
    };
    return Container(
      width: 10,
      height: 10,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
