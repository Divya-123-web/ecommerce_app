import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _price =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  static final _date = DateFormat('dd MMM yyyy, hh:mm a');

  // 2499 -> ₹2,499
  static String price(double value) => _price.format(value);

  // DateTime -> 17 Oct 2026, 08:25 PM
  static String date(DateTime value) => _date.format(value);
}