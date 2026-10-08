// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../core/widgets/wallet_card.dart';
import 'portfolio_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5',
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Jane Cooper',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'My Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Wallet Card
                    const WalletCard(
                      balance: '\$12505.58',
                      cardNumber: '••••  ••••  ••••  6925',
                      expDate: '10/28',
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ActionButton(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Send',
                          onTap: () {},
                        ),
                        ActionButton(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Request',
                          onTap: () {},
                        ),
                        ActionButton(
                          icon: Icons.add_rounded,
                          label: 'Add Fund',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    // Transaction List
                    const TransactionTile(
                      icon: Icons.local_taxi_rounded,
                      title: 'Uber Ride',
                      subtitle: 'Transport • May 29',
                      amount: '\$8.75',
                    ),
                    const TransactionTile(
                      icon: Icons.music_note_rounded,
                      title: 'Spotify Premium',
                      subtitle: 'Entertainment • May 15',
                      amount: '\$19.99',
                    ),
                    const TransactionTile(
                      icon: Icons.shopping_bag_rounded,
                      title: 'Amazon Purchase',
                      subtitle: 'Shopping • May 12',
                      amount: '\$120.00',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Nav
            AppBottomNavBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PortfolioScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}