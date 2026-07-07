import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/constants.dart';
import '../../../core/widgets/end_scroll_view.dart';

class StreakChart extends StatelessWidget {
  final List<int> streakHistory;
  final List<String> labels;

  const StreakChart({
    super.key,
    required this.streakHistory,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (streakHistory.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: Colors.grey)),
      );
    }

    final maxStreak = streakHistory.reduce((a, b) => a > b ? a : b);
    final ceilMax = maxStreak < 5 ? 5 : ((maxStreak + 2) ~/ 5) * 5;
    final interval = (ceilMax / 4).ceilToDouble();
    final labelTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppConstants.warning,
        ) ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber);
    final yLabels = [0.0, interval, interval * 2, interval * 3, ceilMax.toDouble()]
        .map((v) => Text('${v.toInt()}', style: labelTextStyle))
        .toList()
        .reversed
        .toList();
    final gridColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Streak per Session',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        EndScrollView(
          height: 200,
          width: streakHistory.length * 80.0,
          yLabels: yLabels,
          labelWidth: 30,
          topPadding: 48,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: ceilMax.toDouble(),
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      'Streak: ${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(1, (streakHistory.length / 7).ceil()).toDouble(),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: labelTextStyle,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 48,
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                horizontalInterval: ceilMax > 0 ? (ceilMax / 4).ceilToDouble() : 1,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: gridColor,
                  strokeWidth: 1,
                ),
              ),
              barGroups: streakHistory.asMap().entries.map((entry) {
                final idx = entry.key;
                final value = entry.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: value.toDouble(),
                      color: AppConstants.warning,
                      width: 18,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
