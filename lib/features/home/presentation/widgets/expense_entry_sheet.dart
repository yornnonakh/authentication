import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/transaction_form_view_model.dart';
import 'category_selector.dart';
import 'receipt_scan_preview.dart';
import '../../../../core/theme/tracker_palette.dart';

String expenseMonthLabel(DateTime month) => financeMonthLabel(month);
Future<DateTime?> showExpenseEntrySheet(
  BuildContext context,
  DateTime month, {
  bool budget = false,
  Transaction? transaction,
}) {
  ProviderScope.containerOf(
    context,
  ).read(financeMonthProvider.notifier).select(month);
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => ExpenseEntrySheet(
      month: month,
      budget: budget,
      transaction: transaction,
    ),
  );
}

class ExpenseEntrySheet extends ConsumerStatefulWidget {
  const ExpenseEntrySheet({
    super.key,
    required this.month,
    this.budget = false,
    this.transaction,
  });
  final DateTime month;
  final bool budget;
  final Transaction? transaction;
  @override
  ConsumerState<ExpenseEntrySheet> createState() => _ExpenseEntrySheetState();
}

class _ExpenseEntrySheetState extends ConsumerState<ExpenseEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title, _amount, _notes;
  bool _budgetSaving = false;
  String? _budgetError;
  @override
  void initState() {
    super.initState();
    final form = ref.read(transactionFormProvider(widget.transaction));
    final budget =
        ref.read(expenseViewModelProvider).value?.budgetFor(widget.month) ?? 0;
    _title = TextEditingController(text: form.title);
    _amount = TextEditingController(
      text: widget.budget
          ? (budget > 0 ? (budget / 100).toStringAsFixed(2) : '')
          : form.amount,
    );
    _notes = TextEditingController(text: form.notes);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.budget) {
      if (_budgetSaving) return;
      setState(() {
        _budgetSaving = true;
        _budgetError = null;
      });
      final success = await ref
          .read(expenseViewModelProvider.notifier)
          .setBudget(widget.month, parseExpenseCents(_amount.text)!);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context, widget.month);
      } else {
        setState(() {
          _budgetSaving = false;
          _budgetError = 'Unable to save. Please try again.';
        });
      }
    } else {
      final transaction = await ref
          .read(transactionFormProvider(widget.transaction).notifier)
          .save();
      if (mounted && transaction != null) {
        Navigator.pop(context, transaction.date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = transactionFormProvider(widget.transaction);
    final form = ref.watch(provider);
    final model = ref.read(provider.notifier);
    final colors = Theme.of(context).colorScheme;
    final busy = widget.budget ? _budgetSaving : form.busy;
    ref.listen(provider, (previous, next) {
      if (previous?.scanVersion != next.scanVersion && next.scanVersion > 0) {
        _title.text = next.title;
        _amount.text = next.amount;
      }
    });
    return PopScope(
      canPop: !busy,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.budget
                      ? 'Monthly budget'
                      : widget.transaction == null
                      ? 'Add transaction'
                      : 'Edit transaction',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.budget
                      ? 'Set your spending limit for ${expenseMonthLabel(widget.month)}.'
                      : 'The small details make the big picture.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                if (!widget.budget) ...[
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                    ],
                    selected: {form.type},
                    onSelectionChanged: busy
                        ? null
                        : (selection) => model.setType(selection.first),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: busy ? null : model.scan,
                    icon: form.isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner_outlined),
                    label: Text(
                      form.isScanning
                          ? 'Reading mock receipt…'
                          : 'Scan Receipt (AI)',
                    ),
                  ),
                  if (form.isScanning)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: ReceiptScanPreview(),
                    ),
                  if (form.scanVersion > 0)
                    Card.filled(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              color: TrackerPalette.coral,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mock receipt scanned',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    'Starbucks · \$4.75 · Food & Dining',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Demo scan. Review the details before saving.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('transaction-title'),
                    controller: _title,
                    enabled: !busy,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: model.setTitle,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Merchant or source',
                      counterText: '',
                    ),
                    validator: TransactionValidation.title,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  key: const Key('transaction-amount'),
                  controller: _amount,
                  enabled: !busy,
                  onChanged: widget.budget ? null : model.setAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (USD)',
                    prefixText: '\$ ',
                    hintText: '0.00',
                  ),
                  validator: TransactionValidation.amount,
                ),
                if (!widget.budget) ...[
                  const SizedBox(height: 16),
                  CategorySelector(
                    categories: TransactionCategories.forType(form.type),
                    selected: form.category,
                    onSelected: busy ? null : model.setCategory,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(financeDateLabel(form.date)),
                    onPressed: busy
                        ? null
                        : () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: form.date,
                              firstDate: form.date.year < 2000
                                  ? DateTime(form.date.year)
                                  : DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null && mounted) model.setDate(date);
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('transaction-notes'),
                    controller: _notes,
                    enabled: !busy,
                    maxLines: 2,
                    maxLength: 500,
                    onChanged: model.setNotes,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Anything you want to remember',
                      counterText: '',
                    ),
                    validator: TransactionValidation.notes,
                  ),
                ],
                if ((widget.budget ? _budgetError : form.error) != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    (widget.budget ? _budgetError : form.error)!,
                    style: TextStyle(color: colors.error),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Cancel',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surfaceContainerLow,
                        foregroundColor: TrackerPalette.coral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: busy ? null : _save,
                        child: Text(
                          busy
                              ? (form.isScanning ? 'Scanning…' : 'Saving…')
                              : widget.budget
                              ? 'Save budget'
                              : form.type == TransactionType.income
                              ? 'Save income'
                              : 'Save expense',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
