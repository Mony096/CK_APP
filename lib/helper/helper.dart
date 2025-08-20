import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<dynamic> goTo<T extends Widget>(BuildContext context, T route,
    {bool removeAllPreviousRoutes = false}) async {
  if (removeAllPreviousRoutes) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => route),
      (route) => false,
    );
  } else {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (bulider) => route));
    return result;
  }
}

String getDataFromDynamic(dynamic value, {bool isDate = false}) {
  try {
    if (value == null) return '';

    if (isDate) {
      // Handle ISO8601 or DateTime object
      DateTime date;
      if (value is String) {
        date = DateTime.parse(value);
      } else if (value is DateTime) {
        date = value;
      } else {
        return '';
      }

      return DateFormat('dd, MMM, yyyy').format(date); // e.g., 03, Jul, 2025
    }

    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(2);

    return value.toString();
  } catch (e) {
    return '';
  }
}
String formatCustomShortDate(String inputDate) {
  // Parse your original date string
  final parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);

  // Format to "19 June"
  final formattedDate = DateFormat('d MMMM').format(parsedDate);

  return formattedDate;
}
String formatCustomTime(String time) {
  // Parse the time string
  final parsedTime = DateFormat("HH:mm:ss").parse(time);

  // Format to 12-hour with AM/PM
  final formattedTime = DateFormat("h:mm a").format(parsedTime);

  return formattedTime;
}
String formatCustomTimePlusMinutes(String time, int minutesToAdd) {
  // Parse the time string (HH:mm:ss)
  final parsedTime = DateFormat("HH:mm:ss").parse(time);

  // Add minutes
  final newTime = parsedTime.add(Duration(minutes: minutesToAdd));

  // Format to 12-hour with AM/PM
  final formattedTime = DateFormat("h:mm a").format(newTime);

  return formattedTime;
}
