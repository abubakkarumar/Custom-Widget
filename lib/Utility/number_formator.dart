import 'package:intl/intl.dart';

// numberFormatter(String value, {int decimal = 2}) {
//   if (value != null && value.isNotEmpty && value.toString().toLowerCase().trim() != "null") {
//     final cleaned = value.toString().replaceAll(",", "").replaceAll("-", "").trim();
//     num number = double.parse(cleaned);
//     var formatter = NumberFormat("#,##0.${'0' * decimal}", 'en_US');
//     return formatter.format(number);
//   }
//
// }

// String numberFormatter(dynamic value, {int decimal = 2}) {
//   if (value == null) return "0.00";
//
//   final str = value.toString().trim().toLowerCase();
//
//   if (str.isEmpty || str == "null" || str == "-") {
//     return "0.00";
//   }
//
//   final cleaned = str.replaceAll(",", "");
//
//   final number = double.tryParse(cleaned);
//   if (number == null) return "0.00";
//
//   final formatter = NumberFormat("#,##0.${'0' * decimal}", 'en_US');
//   return formatter.format(number);
// }

String numberFormatter(
    dynamic value, {
      int? decimal, // nullable
    }) {
  if (value == null) return "0";

  final str = value.toString().trim().toLowerCase();

  if (str.isEmpty || str == "null" || str == "-") {
    return "0";
  }

  final cleaned = str.replaceAll(",", "");

  final number = double.tryParse(cleaned);
  if (number == null) return "0";

  // detect decimal count from input
  int detectedDecimal = 0;
  if (cleaned.contains('.')) {
    detectedDecimal = cleaned.split('.').last.length;
  }

  final usedDecimal = decimal ?? detectedDecimal;

  final formatter =
  NumberFormat("#,##0${usedDecimal > 0 ? '.${'0' * usedDecimal}' : ''}", 'en_US');

  return formatter.format(number);
}
