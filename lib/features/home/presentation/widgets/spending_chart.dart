import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../utils/finance_format.dart';
import 'finance_widgets.dart';

class SpendingChart extends StatefulWidget {
  const SpendingChart({super.key, required this.categories});
  final Map<String, int> categories;
  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  String? _selected;
  @override
  void didUpdateWidget(covariant SpendingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.categories.containsKey(_selected)) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories.entries.toList();
    final total = categories.fold(0, (sum, c) => sum + c.value);
    final colors = Theme.of(context).colorScheme;
    if (total == 0) {
      return const FinanceEmptyState(
        title: 'Your spending story starts here',
        message: 'Add expenses to discover where your money goes.',
        icon: Icons.donut_large_rounded,
      );
    }
    final selected = _selected == null
        ? null
        : categories.firstWhere((c) => c.key == _selected);
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Semantics(
                label:
                    'Interactive spending distribution. Select a category below for details.',
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 48,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is! FlTapUpEvent) return;
                        final index =
                            response?.touchedSection?.touchedSectionIndex ?? -1;
                        if (index >= 0 && index < categories.length) {
                          setState(() => _selected = categories[index].key);
                        }
                      },
                    ),
                    sections: [
                      for (final category in categories)
                        PieChartSectionData(
                          value: category.value.toDouble(),
                          color: FinanceStyle.categoryColor(category.key),
                          radius:
                              38 +
                              category.value / total * 22 +
                              (_selected == category.key ? 10 : 0),
                          title: '${(category.value / total * 100).round()}%',
                          showTitle: true,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            color: TrackerPalette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 350),
                ),
              ),
              IgnorePointer(
                child: SizedBox(
                  width: 88,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selected == null ? 'Total spent' : selected.key,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          expenseMoney(selected?.value ?? total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (selected != null)
                        Text(
                          '${(selected.value / total * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          selected == null
              ? 'Tap a slice or category to explore'
              : '${selected.key} · ${expenseMoney(selected.value)} · ${(selected.value / total * 100).toStringAsFixed(1)}%',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              for (final category in categories)
                SizedBox(
                  width: (constraints.maxWidth - 16) / 2,
                  child: Semantics(
                    selected: _selected == category.key,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selected = category.key),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: FinanceStyle.categoryColor(category.key),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _selected == category.key
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(category.value / total * 100).round()}% · ${expenseMoney(category.value)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
