import 'package:flutter/foundation.dart';

import 'money_input.dart';

enum TransactionType { expense, income }

abstract final class TransactionCategories {
  static const expenses = [
    'Food & Dining',
    'Transportation',
    'Utilities & Bills',
    'Entertainment',
    'Shopping',
    'Healthcare',
    'Travel',
    'Miscellaneous',
  ];
  static const income = [
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Other',
  ];
  static List<String> forType(TransactionType type) =>
      type == TransactionType.expense ? expenses : income;
}

@immutable
class Transaction {
  factory Transaction({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String category,
    String? notes,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty || title.trim().length > 80) {
      throw ArgumentError(
        'A transaction needs an ID and a title of up to 80 characters.',
      );
    }
    if (!amount.isFinite ||
        amount <= 0 ||
        amount > 999999999.99 ||
        (amount * 100).round() <= 0) {
      throw ArgumentError('Amount must be a positive, finite currency amount.');
    }
    if (!TransactionCategories.forType(type).contains(category)) {
      throw ArgumentError('Category does not match the transaction type.');
    }
    if (notes != null && notes.length > 500) {
      throw ArgumentError('Notes must be 500 characters or fewer.');
    }
    return Transaction._(
      id: id,
      title: title.trim(),
      amount: (amount * 100).round() / 100,
      date: date,
      type: type,
      category: category,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );
  }
  const Transaction._({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? notes;
  int get amountCents => (amount * 100).round();
  bool get isIncome => type == TransactionType.income;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'type': type.name,
    'category': category,
    'notes': notes,
  };
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    type: TransactionType.values.byName(json['type'] as String),
    category: json['category'] as String,
    notes: json['notes'] as String?,
  );
}

abstract final class TransactionValidation {
  static String? title(String? value) => value == null || value.trim().isEmpty
      ? 'Enter a description.'
      : value.trim().length > 80
      ? 'Use 80 characters or fewer.'
      : null;
  static String? amount(String? value) => parseExpenseCents(value ?? '') == null
      ? 'Enter a positive amount with up to 2 decimal places.'
      : null;
  static String? notes(String? value) =>
      (value?.length ?? 0) > 500 ? 'Use 500 characters or fewer.' : null;
  static bool validDate(DateTime date, DateTime now) => !DateTime(
    date.year,
    date.month,
    date.day,
  ).isAfter(DateTime(now.year, now.month, now.day));
}
