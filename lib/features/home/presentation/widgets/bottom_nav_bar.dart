import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const destinations = [
      (label: 'Home', icon: CupertinoIcons.house_fill),
      (label: 'History', icon: CupertinoIcons.chart_bar_fill),
      (label: 'Add', icon: CupertinoIcons.plus),
      (label: 'Settings', icon: CupertinoIcons.gear_alt_fill),
      (label: 'Profile', icon: CupertinoIcons.person_crop_circle_fill),
    ];

    final mappedIndex = currentIndex >= 2 ? currentIndex + 1 : currentIndex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < destinations.length; i++) ...[
              Builder(
                builder: (context) {
                  final selected = mappedIndex == i;
                  final isAdd = i == 2;
                  return Tooltip(
                    message: destinations[i].label,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (isAdd) {
                          onAdd?.call();
                        } else {
                          onTap(i > 2 ? i - 1 : i);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected || isAdd
                              ? colors.primary
                              : Colors.transparent,
                        ),
                        child: Icon(
                          destinations[i].icon,
                          size: 22,
                          color: selected || isAdd
                              ? Colors.white
                              : colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
