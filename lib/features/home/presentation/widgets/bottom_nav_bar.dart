import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key,required this.currentIndex,required this.onTap,this.onAdd});
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const destinations = [
      (label: 'Home',icon: CupertinoIcons.house),
      (label: 'History',icon: CupertinoIcons.list_bullet),
      (label: 'Add',icon: CupertinoIcons.plus_circle),
      (label: 'Settings',icon: CupertinoIcons.settings),
      (label: 'Profile',icon: CupertinoIcons.person_crop_circle),
    ];
    return CupertinoTabBar(
      currentIndex: currentIndex >= 2 ? currentIndex + 1 : currentIndex,
      activeColor: colors.primary,inactiveColor: colors.onSurfaceVariant,
      backgroundColor: colors.surfaceContainerLow,
      border: Border(top: BorderSide(color: colors.outlineVariant,width: 0.5)),
      onTap: (index) {
        if (index == 2) { onAdd?.call(); }
        else { onTap(index > 2 ? index - 1 : index); }
      },
      items: [for (var i = 0; i < destinations.length; i++) BottomNavigationBarItem(
        icon: Tooltip(message: i == 2 ? 'Add transaction' : destinations[i].label,
          child: Icon(destinations[i].icon,color: i == 2 && onAdd == null ? colors.onSurfaceVariant.withValues(alpha: 0.4) : null)),
        label: destinations[i].label,
      )],
    );
  }
}
