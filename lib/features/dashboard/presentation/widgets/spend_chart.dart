import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendChart extends StatelessWidget {
  final List<MapEntry<String, double>> monthlySpend;

  const SpendChart({
    super.key,
    required this.monthlySpend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (monthlySpend.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No transaction data available yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final barGroups = List.generate(monthlySpend.length, (index) {
      final entry = monthlySpend[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: monthlySpend.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < monthlySpend.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        monthlySpend[idx].key,
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
          barGroups: barGroups,
        ),
      ),
    );
  }
}
