import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';
import 'expense_view_model.dart';

class LedgerFilters {
  const LedgerFilters({this.query = '', this.type, this.category});
  final String query;
  final TransactionType? type;
  final String? category;
}

final ledgerFiltersProvider =
    NotifierProvider.autoDispose<LedgerViewModel, LedgerFilters>(
      LedgerViewModel.new,
    );

class LedgerViewModel extends Notifier<LedgerFilters> {
  @override
  LedgerFilters build() => const LedgerFilters();
  void search(String value) => state = LedgerFilters(
    query: value,
    type: state.type,
    category: state.category,
  );
  void setType(TransactionType? type) => state = LedgerFilters(
    query: state.query,
    type: type,
    category:
        type == null ||
            TransactionCategories.forType(type).contains(state.category)
        ? state.category
        : null,
  );
  void setCategory(String? category) => state = LedgerFilters(
    query: state.query,
    type: state.type,
    category: category,
  );
  void clear() => state = const LedgerFilters();
}

final ledgerTransactionsProvider = Provider.autoDispose<List<Transaction>>((
  ref,
) {
  final filters = ref.watch(ledgerFiltersProvider);
  final transactions =
      ref.watch(expenseViewModelProvider).value?.transactions ?? [];
  return transactions
      .where(
        (t) =>
            (filters.type == null || filters.type == t.type) &&
            (filters.category == null || filters.category == t.category) &&
            fuzzyTitleMatches(t.title, filters.query),
      )
      .toList()
    ..sort(compareTransactions);
});

class LedgerGroup {
  LedgerGroup({required this.month, required List<Transaction> transactions})
    : transactions = List.unmodifiable(transactions);
  final DateTime month;
  final List<Transaction> transactions;
}

final ledgerGroupsProvider = Provider.autoDispose<List<LedgerGroup>>((ref) {
  final groups = <DateTime, List<Transaction>>{};
  for (final t in ref.watch(ledgerTransactionsProvider)) {
    groups.putIfAbsent(DateTime(t.date.year, t.date.month), () => []).add(t);
  }
  return groups.entries
      .map((g) => LedgerGroup(month: g.key, transactions: g.value))
      .toList();
});

bool fuzzyTitleMatches(String title, String query) {
  String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
      .trim();
  final haystack = normalize(title);
  final needle = normalize(query);
  if (needle.isEmpty || haystack.contains(needle)) return true;
  final compact = haystack.replaceAll(' ', '');
  final target = needle.replaceAll(' ', '');
  var index = 0;
  for (final character in compact.runes) {
    if (index < target.length &&
        String.fromCharCode(character) == target[index]) {
      index++;
    }
  }
  if (index == target.length) return true;
  return needle
      .split(RegExp(r'\s+'))
      .every(
        (word) => haystack
            .split(RegExp(r'\s+'))
            .any(
              (candidate) =>
                  candidate.contains(word) ||
                  (word.length >= 4 &&
                      _editDistance(word, candidate) <=
                          (word.length >= 8 ? 2 : 1)),
            ),
      );
}

int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final deletion = previous[j] + 1;
      final insertion = current[j - 1] + 1;
      final substitution = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
      current[j] = [
        deletion,
        insertion,
        substitution,
      ].reduce((x, y) => x < y ? x : y);
    }
    previous = current;
  }
  return previous.last;
}
