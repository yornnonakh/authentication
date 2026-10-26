import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/finance_format.dart';
import '../view_models/expense_view_model.dart';

class FinanceMonthPicker extends ConsumerWidget {
  const FinanceMonthPicker({super.key, this.onPurple = false});
  final bool onPurple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(financeMonthProvider);
    final color = onPurple
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    return Material(
      color: onPurple
          ? Colors.white.withValues(alpha: 0.12)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final now = DateTime.now();
          final result = await showDatePicker(
            context: context,
            initialDate: month,
            firstDate: DateTime(2000),
            lastDate: now,
            helpText: 'Choose a month',
          );
          if (result != null && context.mounted) {
            ref.read(financeMonthProvider.notifier).select(result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  financeMonthLabel(month),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class FinanceSectionHeading extends StatelessWidget {
  const FinanceSectionHeading({super.key, required this.title, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      );
      if (action != null &&
          constraints.maxWidth < 360 &&
          MediaQuery.textScalerOf(context).scale(16) > 18) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            Align(alignment: Alignment.centerRight, child: action!),
          ],
        );
      }
      return Row(
        children: [
          Expanded(flex: 3, child: heading),
          if (action != null)
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Align(alignment: Alignment.centerRight, child: action!),
            ),
        ],
      );
    },
  );
}
