import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';
import 'finance_widgets.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String>? onSelected;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 124,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (_, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = FinanceStyle.categoryColor(category);
        final active = selected == category;
        return Semantics(
          button: true,
          selected: active,
          child: Material(
            color: active
                ? color
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onSelected == null ? null : () => onSelected!(category),
              child: SizedBox(
                width: 112,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Colors.white.withValues(alpha: 0.3)
                              : color,
                        ),
                        child: Icon(
                          FinanceStyle.categoryIcon(category),
                          size: 22,
                          color: TrackerPalette.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (category == 'Transportation' ? 'Transport' : category)
                            .toUpperCase(),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active ? TrackerPalette.ink : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
