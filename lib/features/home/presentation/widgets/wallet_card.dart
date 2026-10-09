import 'package:flutter/material.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.balance,
    required this.cardNumber,
    required this.expDate,
  });

  final String balance;
  final String cardNumber;
  final String expDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF100D10), Color(0xFF261D25), Color(0xFF3D4552)],
          stops: [0, 0.62, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Finsight',
                style: TextStyle(
                  color: Color(0xFFB4B2B8),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Current Balance',
            style: TextStyle(color: Color(0xFF969399), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            balance,
            style: const TextStyle(
              color: Color(0xFFE8E6E9),
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  cardNumber,
                  style: const TextStyle(
                    color: Color(0xFFCAC7CE),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Exp.Date',
                    style: TextStyle(color: Color(0xFF969399), fontSize: 10),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    expDate,
                    style: const TextStyle(
                      color: Color(0xFFE8E6E9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
