import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../view_models/spending_activity_provider.dart';
import '../utils/finance_format.dart';
import 'finance_widgets.dart';

class SpendingActivityCard extends StatelessWidget {
  const SpendingActivityCard({
    super.key,
    required this.days,
    required this.isCurrentMonth,
  });
  final List<SpendingDay> days;
  final bool isCurrentMonth;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final maximum = days.fold(
      0,
      (maximum, day) => day.cents > maximum ? day.cents : maximum,
    );
    final chartMaximum = maximum == 0 ? 100.0 : maximum * 1.3;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF694B3C)
            : TrackerPalette.peach,
        borderRadius: BorderRadius.circular(30),
      ),
      child: FinanceCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'DAILY SPENDING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 112,
              child: BarChart(
                BarChartData(
                  maxY: chartMaximum,
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, index, rod, rodIndex) =>
                          BarTooltipItem(
                            expenseMoney(days[index].cents),
                            TextStyle(color: Colors.white, fontSize: 12),
                          ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${days[value.toInt().clamp(0, 6)].date.day}',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < days.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: days[i].cents.toDouble(),
                            width: 6,
                            borderRadius: BorderRadius.circular(6),
                            color: i == 6
                                ? TrackerPalette.coral
                                : colors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                          ),
                        ],
                      ),
                  ],
                ),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DayTotal(
                    label: isCurrentMonth
                        ? 'TODAY'
                        : financeDateLabel(days.last.date),
                    cents: days.last.cents,
                    accent: true,
                  ),
                ),
                Expanded(
                  child: _DayTotal(
                    label: isCurrentMonth
                        ? 'YESTERDAY'
                        : financeDateLabel(days[5].date),
                    cents: days[5].cents,
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

class _DayTotal extends StatelessWidget {
  const _DayTotal({
    required this.label,
    required this.cents,
    this.accent = false,
  });
  final String label;
  final int cents;
  final bool accent;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 9,
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          expenseMoney(cents),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: accent ? TrackerPalette.coral : null,
          ),
        ),
      ),
    ],
  );
}
