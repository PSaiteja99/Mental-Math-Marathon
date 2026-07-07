import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../app/constants.dart';
import '../../../core/widgets/end_scroll_view.dart';

class CphChart extends StatelessWidget {
  final List<int> cphHistory;
  final List<String> labels;

  const CphChart({
    super.key,
    required this.cphHistory,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (cphHistory.isEmpty) {
      return const Center(
        child: Text('No data yet', style: TextStyle(color: Colors.grey)),
      );
    }

    final maxCph = cphHistory.reduce((a, b) => a > b ? a : b);
    final ceilMax = ((maxCph + 100) ~/ 100) * 100;
    final interval = (ceilMax / 4).ceilToDouble();
    final labelTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppConstants.primaryBlue,
        ) ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue);
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
          'CPH (Calculations Per Hour) Progression',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        EndScrollView(
          height: 200,
          width: cphHistory.length * 80.0,
          yLabels: yLabels,
          labelWidth: 40,
          topPadding: 48,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: ceilMax.toDouble(),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipMargin: 4,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: max(1, (cphHistory.length / 7).ceil()).toDouble(),
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
                horizontalInterval: (ceilMax / 4).ceilToDouble(),
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: gridColor,
                  strokeWidth: 1,
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: cphHistory.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: AppConstants.primaryBlue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: AppConstants.primaryBlue,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppConstants.primaryBlue.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

