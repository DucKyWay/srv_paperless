import 'package:intl/intl.dart';

enum ThaiMonth {
  january("มกราคม"),
  february("กุมภาพันธ์"),
  march("มีนาคม"),
  april("เมษายน"),
  may("พฤษภาคม"),
  june("มิถุนายน"),
  july("กรกฎาคม"),
  august("สิงหาคม"),
  september("กันยายน"),
  october("ตุลาคม"),
  november("พฤศจิกายน"),
  december("ธันวาคม");

  final String label;
  const ThaiMonth(this.label);

  static String getLabel(int monthNumber) {
    if (monthNumber < 1 || monthNumber > 12) return "ไม่ระบุ";
    return ThaiMonth.values[monthNumber - 1].label;
  }
}

class DateUtil {
  static String formatIntlDate(
    DateTime? date, {
    String errorText = 'ไม่ระบุวันที่',
  }) {
    if (date == null) return errorText;
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return errorText;
    }
  }

  static String formatThaiDate(
    DateTime? date, {
    String errorText = 'ไม่ระบุวันที่',
  }) {
    if (date == null) return errorText;

    try {
      final day = date.day;
      final month = ThaiMonth.getLabel(date.month);
      final year = date.year + 543;

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final second = date.second.toString().padLeft(2, '0');

      return "$day $month $year, $hour:$minute:$second น.";
    } catch (e) {
      return errorText;
    }
  }
}
