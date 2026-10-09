import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dashboard.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../theme/dashboard_colors.dart';
import '../view_models/home_view_model.dart';
import '../widgets/action_button.dart';
import '../widgets/dashboard_icon_button.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeViewModelProvider);
    final profile = ref.watch(currentUserProfileProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      key: const PageStorageKey('home-scroll'),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 108 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: ref
                    .read(dashboardNavigationViewModelProvider.notifier)
                    .showProfile,
                customBorder: const CircleBorder(),
                child: ProfileAvatar(profile: profile),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Morning',
                      style: TextStyle(
                        fontSize: 12,
                        color: DashboardColors.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile?.displayName ?? 'Your account',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: DashboardColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              DashboardIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Notifications',
                showBadge: true,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 34),
          const Text(
            'My Wallet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: DashboardColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          WalletCard(
            balance: dashboard.wallet.balance,
            cardNumber: dashboard.wallet.cardNumber,
            expDate: dashboard.wallet.expDate,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.north_east_rounded,
                  label: 'Send',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ActionButton(
                  icon: Icons.south_west_rounded,
                  label: 'Request',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ActionButton(
                  icon: Icons.add_card_outlined,
                  label: 'Add Fund',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          DashboardSectionHeader(title: 'Transaction', onViewAll: () {}),
          const SizedBox(height: 4),
          for (final transaction in dashboard.transactions)
            TransactionTile(
              icon: switch (transaction.category) {
                TransactionCategory.transport => Icons.directions_car_outlined,
                TransactionCategory.entertainment => Icons.music_note_outlined,
                TransactionCategory.shopping => Icons.shopping_cart_outlined,
              },
              title: transaction.title,
              subtitle: transaction.subtitle,
              amount: transaction.amount,
            ),
        ],
      ),
    );
  }
}
