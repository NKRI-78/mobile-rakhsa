import 'package:intl/intl.dart';

formatDateDDMMYYYY(DateTime dateTime) {
  return DateFormat('dd MMMM yyyy').format(dateTime);
}