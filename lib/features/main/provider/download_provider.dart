import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

enum DownloadStepStatus { waiting, downloading, completed, error }

class DownloadStep {
  final String name;
  final IconData icon;
  final Color color;
  DownloadStepStatus status = DownloadStepStatus.waiting;
  int count = 0;
  int total = 0;

  DownloadStep({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DownloadProvider extends ChangeNotifier {
  bool _isStarted = false;
  bool _isCompleted = false;
  bool _isError = false;
  String? _errorMessage;

  bool get isStarted => _isStarted;
  bool get isCompleted => _isCompleted;
  bool get isError => _isError;
  String? get errorMessage => _errorMessage;

  final List<DownloadStep> _steps = [
    DownloadStep(
      name: "Customers",
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF3B82F6),
    ),
    DownloadStep(
      name: "Items",
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFFF59E0B),
    ),
    DownloadStep(
      name: "Sites",
      icon: Icons.location_city_rounded,
      color: const Color(0xFF10B981),
    ),
    DownloadStep(
      name: "Equipment",
      icon: Icons.build_circle_rounded,
      color: const Color(0xFFEC4899),
    ),
  ];

  List<DownloadStep> get steps => _steps;

  int get completedCount =>
      _steps.where((s) => s.status == DownloadStepStatus.completed).length;

  double get overallProgress =>
      _steps.isEmpty ? 0 : completedCount / _steps.length;

  Future<void> startDownload({
    required BuildContext context,
    required CustomerListProvider onlineProviderCustomer,
    required CustomerListProviderOffline offlineProviderCustomer,
    required ItemListProvider onlineProviderItem,
    required ItemListProviderOffline offlineProviderItem,
    required SiteListProvider onlineProviderSite,
    required SiteListProviderOffline offlineProviderSite,
    required EquipmentListProvider onlineProviderEquipment,
    required EquipmentOfflineProvider offlineProviderEquipment,
    required VoidCallback onComplete,
    required Function(String) onError,
  }) async {
    if (_isStarted && !_isError) return;

    _isStarted = true;
    _isCompleted = false;
    _isError = false;
    _errorMessage = null;

    // Reset steps
    for (var step in _steps) {
      step.status = DownloadStepStatus.waiting;
      step.count = 0;
      step.total = 0;
    }
    notifyListeners();

    try {
      // Step 1: Customers
      await _downloadWithProgress(0, onlineProviderCustomer, () async {
        await onlineProviderCustomer.fetchDocumentOffline(
          loadMore: false,
          isSetFilter: false,
          context: context,
        );
        await offlineProviderCustomer
            .saveDocuments(onlineProviderCustomer.documentOffline);
        return onlineProviderCustomer.documentOffline.length;
      });

      // Step 2: Items
      await _downloadWithProgress(1, onlineProviderItem, () async {
        await onlineProviderItem.fetchDocumentOffline(
          loadMore: false,
          isSetFilter: false,
          context: context,
        );
        await offlineProviderItem
            .saveDocuments(onlineProviderItem.documentOffline);
        return onlineProviderItem.documentOffline.length;
      });

      // Step 3: Sites
      await _downloadWithProgress(2, onlineProviderSite, () async {
        await onlineProviderSite.fetchOfflineDocuments(
          loadMore: false,
          isSetFilter: false,
        );
        await offlineProviderSite
            .saveDocuments(onlineProviderSite.documentOffline);
        return onlineProviderSite.documentOffline.length;
      });

      // Step 4: Equipment
      await _downloadWithProgress(3, onlineProviderEquipment, () async {
        await onlineProviderEquipment.fetchOfflineDocuments(
          loadMore: false,
          isSetFilter: false,
        );
        await offlineProviderEquipment
            .saveDocuments(onlineProviderEquipment.documentOffline);
        return onlineProviderEquipment.documentOffline.length;
      });

      _isCompleted = true;
      await LocalStorageManger.setString('isDownloaded', 'true');
      AwesomeNotifications().dismiss(999);
      notifyListeners();
      onComplete();
    } catch (e) {
      debugPrint("❌ Download error: $e");
      _isError = true;
      _errorMessage = e.toString();
      _isStarted = false;
      notifyListeners();

      // Clear data on error
      await offlineProviderCustomer.clearDocuments();
      await offlineProviderItem.clearDocuments();
      await offlineProviderSite.clearDocuments();
      await offlineProviderEquipment.clearEquipments();
      await LocalStorageManger.setString('isDownloaded', 'false');

      AwesomeNotifications().dismiss(999);
      onError(_errorMessage!);
    }
  }

  Future<void> _downloadWithProgress(
    int index,
    ChangeNotifier provider,
    Future<int> Function() download,
  ) async {
    _steps[index].status = DownloadStepStatus.downloading;
    notifyListeners();

    void onProgress() {
      int fetched = 0;
      int total = 0;

      if (provider is CustomerListProvider) {
        fetched = provider.fetchedCount;
        total = provider.totalCount;
      } else if (provider is ItemListProvider) {
        fetched = provider.fetchedCount;
        total = provider.totalCount;
      } else if (provider is SiteListProvider) {
        fetched = provider.fetchedCount;
        total = provider.totalCount;
      } else if (provider is EquipmentListProvider) {
        fetched = provider.fetchedCount;
        total = provider.totalCount;
      }

      _steps[index].count = fetched;
      _steps[index].total = total;
      notifyListeners();

      if (total > 0) {
        _showProgressNotification(index, fetched, total);
      }
    }

    provider.addListener(onProgress);

    try {
      final count = await download();
      _steps[index].status = DownloadStepStatus.completed;
      _steps[index].count = count;
      _steps[index].total = count;
      notifyListeners();
    } finally {
      provider.removeListener(onProgress);
    }
  }

  void _showProgressNotification(int index, int fetched, int total) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'basic_channel',
        title: 'Downloading ${_steps[index].name}...',
        body: 'Progress: $fetched / $total records',
        notificationLayout: NotificationLayout.ProgressBar,
        progress: total > 0 ? (fetched / total * 100).toDouble() : 0.0,
        locked: true,
        icon: Platform.isAndroid ? 'resource://mipmap/ic_launcher' : null,
      ),
    );
  }

  void cancelDownload(
    CustomerListProvider onlineProviderCustomer,
    ItemListProvider onlineProviderItem,
    SiteListProvider onlineProviderSite,
    EquipmentListProvider onlineProviderEquipment,
  ) {
    onlineProviderCustomer.cancelDownload();
    onlineProviderItem.cancelDownload();
    onlineProviderSite.cancelDownload();
    onlineProviderEquipment.cancelDownload();

    _isStarted = false;
    _isCompleted = false;
    AwesomeNotifications().dismiss(999);
    notifyListeners();
  }
}
