import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannedReceipt {
  const ScannedReceipt({
    required this.merchant,
    required this.amount,
    required this.category,
  });
  final String merchant;
  final double amount;
  final String category;
}

abstract interface class ReceiptScanner {
  Future<ScannedReceipt> scan();
}

final receiptScannerProvider = Provider<ReceiptScanner>(
  (ref) => MockReceiptScanner(),
);

class MockReceiptScanner implements ReceiptScanner {
  @override
  Future<ScannedReceipt> scan() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return const ScannedReceipt(
      merchant: 'Starbucks',
      amount: 4.75,
      category: 'Food & Dining',
    );
  }
}
