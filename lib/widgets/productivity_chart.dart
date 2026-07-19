import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Line chart of honey yield (ml) over the selected range, with rounded
/// segmented toggle for switching between Day/Week/Month/Year.
class ProductivityChart extends StatelessWidget {
  const ProductivityChart({super.key, required this.series});

  final List<MapEntry<String, double>> series;

  @override
  Widget build(BuildContext context) {
    if (series.every((e) => e.value == 0)) {
      return SizedBox(
        height: 190,
        child: Center(
          child: Text(
            'No honey yield yet for this range',
            style: TextStyle(color: HiveColors.wilted),
          ),
        ),
      );
    }

    final maxY = series.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 190,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 10 : maxY * 1.25,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY <= 0 ? 10 : maxY * 1.25) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: HiveColors.combCreamDark.withOpacity(0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= series.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      series[i].key,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: HiveColors.wilted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => HiveColors.waxBrown,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(0)} ml',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < series.length; i++)
                  FlSpot(i.toDouble(), series[i].value),
              ],
              isCurved: true,
              curveSmoothness: 0.25,
              color: HiveColors.honeyAmber,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    HiveColors.honeyGold.withOpacity(0.35),
                    HiveColors.honeyGold.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded segmented control for switching analytics range.
class RangeToggle<T> extends StatelessWidget {
  const RangeToggle({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HiveColors.combCream.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onChanged(options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected == options[i] ? HiveColors.honeyGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected == options[i] ? Colors.white : HiveColors.waxBrown,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
