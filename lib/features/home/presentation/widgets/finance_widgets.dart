import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';

abstract final class FinanceStyle {
  static Color income(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF83DCAB)
      : const Color(0xFF207447);
  static Color expense(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFAAA3)
      : const Color(0xFFB83D49);
  static const categoryColors = [
    Color(0xFFFFBBB2),
    Color(0xFFA9C9FF),
    Color(0xFF92C0FF),
    Color(0xFFF5B8DB),
    Color(0xFFBD9AF6),
    Color(0xFFA6DCC8),
    Color(0xFF68DEE2),
    Color(0xFFF4D18C),
  ];
  static Color categoryColor(String category) {
    final index = TransactionCategories.expenses.indexOf(category);
    if (index >= 0) return categoryColors[index];
    return switch (category) {
      'Salary' => const Color(0xFFA6DCC8),
      'Freelance' => const Color(0xFFBD9AF6),
      'Investments' => const Color(0xFFA9C9FF),
      'Gifts' => const Color(0xFFF5B8DB),
      _ => const Color(0xFFF4D18C),
    };
  }

  static IconData categoryIcon(String category) => switch (category) {
    'Food & Dining' => Icons.restaurant_rounded,
    'Transportation' => Icons.directions_car_outlined,
    'Utilities & Bills' => Icons.receipt_long_outlined,
    'Entertainment' => Icons.headphones_rounded,
    'Shopping' => Icons.shopping_bag_outlined,
    'Healthcare' => Icons.health_and_safety_outlined,
    'Travel' => Icons.flight_takeoff_rounded,
    'Salary' => Icons.work_outline_rounded,
    'Freelance' => Icons.laptop_mac_rounded,
    'Investments' => Icons.trending_up_rounded,
    'Gifts' => Icons.card_giftcard_rounded,
    _ => Icons.more_horiz_rounded,
  };
}

class FinanceCard extends StatelessWidget {
  const FinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(padding: padding, child: child),
  );
}

class TransactionIcon extends StatelessWidget {
  const TransactionIcon({
    super.key,
    required this.transaction,
    this.size = 44,
    this.heroTag,
  });
  final Transaction transaction;
  final double size;
  final String? heroTag;
  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome
        ? const Color(0xFFA6DCC8)
        : FinanceStyle.categoryColor(transaction.category);
    final icon = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(
            FinanceStyle.categoryIcon(transaction.category),
            color: TrackerPalette.ink,
            size: size * 0.48,
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: size * 0.35,
            height: size * 0.35,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isIncome
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: size * 0.25,
              color: transaction.isIncome
                  ? FinanceStyle.income(context)
                  : FinanceStyle.expense(context),
            ),
          ),
        ),
      ],
    );
    return heroTag == null ? icon : Hero(tag: heroTag!, child: icon);
  }
}

class FinanceTransactionTile extends StatelessWidget {
  const FinanceTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.heroTag,
  });
  final Transaction transaction;
  final VoidCallback? onTap;
  final String? heroTag;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        leading: TransactionIcon(
          transaction: transaction,
          heroTag: heroTag,
          size: 38,
        ),
        title: Text(
          transaction.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${transaction.category} · ${financeDateLabel(transaction.date)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            '${transaction.isIncome ? '+' : '-'}${expenseMoney(transaction.amountCents)}',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: transaction.isIncome
                  ? FinanceStyle.income(context)
                  : FinanceStyle.expense(context),
            ),
          ),
        ),
        onTap: onTap,
      ),
    ),
  );
}

class FinanceEmptyState extends StatelessWidget {
  const FinanceEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.action,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}
