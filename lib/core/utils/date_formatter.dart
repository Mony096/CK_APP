

import 'package:intl/intl.dart';

String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  // Format: 'dd, MMMM, yyyy'
  String formattedDate = DateFormat('dd, MMMM, yyyy').format(dateTime);
  return formattedDate;
}
