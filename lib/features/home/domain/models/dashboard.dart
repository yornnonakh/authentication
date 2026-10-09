enum TransactionCategory { transport, entertainment, shopping }

enum InvestmentBrand { apple, paypal, facebook }

enum AllocationType { available, bonds, spent }

class Wallet {
  const Wallet({
    required this.balance,
    required this.cardNumber,
    required this.expDate,
  });

  final String balance;
  final String cardNumber;
  final String expDate;
}

class WalletTransaction {
  const WalletTransaction({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final TransactionCategory category;
  final String title;
  final String subtitle;
  final String amount;
}

class Investment {
  const Investment({
    required this.brand,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.change,
    required this.isPositive,
    this.sparkline = const [],
  });

  final InvestmentBrand brand;
  final String name;
  final String symbol;
  final String amount;
  final String change;
  final bool isPositive;
  final List<double> sparkline;
}

class PortfolioAllocation {
  const PortfolioAllocation({
    required this.type,
    required this.label,
    required this.amount,
    required this.fraction,
  });

  final AllocationType type;
  final String label;
  final String amount;
  final double fraction;
}

class Dashboard {
  Dashboard({
    required this.wallet,
    required List<WalletTransaction> transactions,
    required List<Investment> investments,
    required List<PortfolioAllocation> allocations,
  }) : transactions = List.unmodifiable(transactions),
       investments = List.unmodifiable(investments),
       allocations = List.unmodifiable(allocations);

  final Wallet wallet;
  final List<WalletTransaction> transactions;
  final List<Investment> investments;
  final List<PortfolioAllocation> allocations;
}
