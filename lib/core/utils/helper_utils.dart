import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';

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

String showDateOnService(String? date) {
  if (date == null || date.isEmpty) {
    return "No Date";
  }
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat("dd MMMM yyyy").format(parsedDate);
  } catch (e) {
    return "No Date";
  }
}

void prettyPrint(dynamic data) {
  try {
    const encoder = JsonEncoder.withIndent('  ');
    final String prettyString = encoder.convert(data);
    dev.log(prettyString);
  } catch (e) {
    dev.log(data.toString());
  }
}

/// Shared logout function - clears all offline data and navigates to login
Future<void> performLogout(BuildContext context) async {
  MaterialDialog.loading(context);

  // Get all offline providers
  final offlineProviderService =
      Provider.of<ServiceListProviderOffline>(context, listen: false);
  final offlineProviderCustomer =
      Provider.of<CustomerListProviderOffline>(context, listen: false);
  final offlineProviderItem =
      Provider.of<ItemListProviderOffline>(context, listen: false);
  final offlineProviderEquipment =
      Provider.of<EquipmentOfflineProvider>(context, listen: false);
  final offlineProviderSite =
      Provider.of<SiteListProviderOffline>(context, listen: false);

  try {
    // Clear all offline data
    await offlineProviderService.clearDocuments();
    await offlineProviderCustomer.clearDocuments();
    await offlineProviderItem.clearDocuments();
    await offlineProviderEquipment.clearEquipments();
    await offlineProviderSite.clearDocuments();
    await LocalStorageManger.setString('isDownloaded', 'false');
  } catch (e) {
    debugPrint("Error clearing data during logout: $e");
  }

  // Perform logout
  await Provider.of<AuthProvider>(context, listen: false).logout();

  if (context.mounted) {
    Navigator.of(context).pop(); // Close loading dialog
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreenV2()),
      (route) => false,
    );
  }
}
