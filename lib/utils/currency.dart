import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter({required String currencyCode})
      : _formatter = NumberFormat.simpleCurrency(name: currencyCode);

  final NumberFormat _formatter;

  String cents(int value) {
    return _formatter.format(value / 100);
  }
}
