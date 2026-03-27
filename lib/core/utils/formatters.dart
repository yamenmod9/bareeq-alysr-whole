import 'package:intl/intl.dart';

String formatSar(dynamic value, {String locale = 'en'}) {
  final amount = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
  final f = NumberFormat.currency(locale: locale, symbol: 'SAR ', decimalDigits: 2);
  return f.format(amount);
}

String formatDate(dynamic value, {String locale = 'en'}) {
  if (value == null) {
    return '-';
  }
  DateTime? dt;
  if (value is DateTime) {
    dt = value;
  } else {
    dt = DateTime.tryParse(value.toString());
  }
  if (dt == null) {
    return value.toString();
  }
  return DateFormat.yMMMd(locale).add_jm().format(dt.toLocal());
}
