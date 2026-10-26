import 'dart:convert';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/expense_tracker.dart';

abstract final class FinanceCsv {
  static String encode(ExpenseTracker tracker) {
    final transactions = tracker.transactions.toList()
      ..sort(compareTransactions);
    // Neutralize spreadsheet formulas in user-entered text cells.
    String text(String value) =>
        RegExp(r'^\s*[=+\-@]').hasMatch(value) ? "'$value" : value;
    return csv.encode([
      [
        'ID',
        'Title',
        'Amount',
        'Currency',
        'Date',
        'Type',
        'Category',
        'Notes',
      ],
      for (final t in transactions)
        [
          text(t.id),
          text(t.title),
          t.amount.toStringAsFixed(2),
          'USD',
          t.date.toIso8601String(),
          t.type.name,
          t.category,
          text(t.notes ?? ''),
        ],
    ]);
  }
}

abstract interface class CsvShareService {
  Future<void> share(String contents, {required Rect origin});
}

final csvShareServiceProvider = Provider<CsvShareService>(
  (ref) => NativeCsvShareService(),
);

class NativeCsvShareService implements CsvShareService {
  @override
  Future<void> share(String contents, {required Rect origin}) async {
    final date = DateTime.now().toIso8601String().split('T').first;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(utf8.encode('\uFEFF$contents'), mimeType: 'text/csv'),
        ],
        fileNameOverrides: ['finsight-transactions-$date.csv'],
        sharePositionOrigin: origin,
        subject: 'Finsight transaction export',
      ),
    );
  }
}
