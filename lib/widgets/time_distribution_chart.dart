import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

/// Bar chart showing how many completed sessions happened in each
/// time-of-day bucket (Morning / Afternoon / Evening / Night).
class TimeDistributionChart extends StatelessWidget {
  const TimeDistributionChart({super.key, required this.distribution});

  final Map<TimeOfDayBucket, int> distribution;

  @override
  Widget build(BuildContext context) {
    final buckets = TimeOfDayBucket.values;
    final maxVal = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return SizedBox(
      height: 190,
      child: BarChart(
        BarChartData(
          maxY: (maxVal + 1).toDouble(),
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      bucketLabel(buckets[i]).substring(0, 3),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: HiveColors.wilted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (distribution[buckets[i]] ?? 0).toDouble(),
                    width: 26,
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [HiveColors.honeyDeep, HiveColors.honeyGold],
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
