import 'package:intl/intl.dart';
export '../../domain/models/expense_tracker.dart' show expenseMoney;

String financeMonthLabel(DateTime date) => DateFormat.yMMMM().format(date);
String financeDateLabel(DateTime date) => DateFormat.yMMMd().format(date);
