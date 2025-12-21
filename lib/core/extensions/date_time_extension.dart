
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String format(String pattern, [String locale = "id"]) =>
      DateFormat(pattern, locale).format(toLocal());
}
