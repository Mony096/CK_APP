import 'package:flutter/material.dart';
import 'package:bizd_tech_service/core/core.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';

import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isSyncing = false;
  String? _isDownloaded;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final status = await LocalStorageManger.getString('isDownloaded');
    if (mounted) {
      setState(() {
        _isDownloaded = status;
      });
    }
  }

  Future<void> _handleSyncToSAP() async {
    MaterialDialog.warningBackScreen(
      context,
      title: "Sync to SAP",
      body: "Are you sure you want to synchronize all offline work to SAP?",
      confirmLabel: "Sync Now",
      cancelLabel: "Cancel",
      icon: Icons.sync_rounded,
      onConfirm: () async {
        if (!mounted) return;
        MaterialDialog.loading(context);
        try {
          final res1 = await Provider.of<CompletedServiceProvider>(context,
                  listen: false)
              .syncAllOfflineServicesToSAP(context);
          final res2 =
              await Provider.of<EquipmentCreateProvider>(context, listen: false)
                  .syncAllOfflineEquipmentToSAP(context);

          if (mounted) {
            MaterialDialog.close(context); // Safe close loading
            if (res1 == false && res2 == false) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("No offline data to synchronize.")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Synchronization complete!")));
            }
          }
        } catch (e) {
          debugPrint("Sync Error: $e");
          if (mounted) {
            MaterialDialog.close(context); // Safe close loading
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Sync failed: ${e.toString()}")));
          }
        }
      },
    );
  }

  Future<void> _handleDownload() async {
    final onlineProviderCustomer =
        Provider.of<CustomerListProvider>(context, listen: false);
    final offlineProviderCustomer =
        Provider.of<CustomerListProviderOffline>(context, listen: false);
    final onlineProviderItem =
        Provider.of<ItemListProvider>(context, listen: false);
    final offlineProviderItem =
        Provider.of<ItemListProviderOffline>(context, listen: false);
    final onlineProviderSite =
        Provider.of<SiteListProvider>(context, listen: false);
    final offlineProviderSite =
        Provider.of<SiteListProviderOffline>(context, listen: false);
    final onlineProviderEquipment =
        Provider.of<EquipmentListProvider>(context, listen: false);
    final offlineProviderEquipment =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _DownloadDialog(
          onlineProviderCustomer: onlineProviderCustomer,
          offlineProviderCustomer: offlineProviderCustomer,
          onlineProviderItem: onlineProviderItem,
          offlineProviderItem: offlineProviderItem,
          onlineProviderSite: onlineProviderSite,
          offlineProviderSite: offlineProviderSite,
          onlineProviderEquipment: onlineProviderEquipment,
          offlineProviderEquipment: offlineProviderEquipment,
          onComplete: () {
            _checkDownloadStatus();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text("All documents downloaded successfully!",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  ],
                ),
                backgroundColor: const Color(0xFF22C55E),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          onError: (error) {
            MaterialDialog.warning(context, title: "Error", body: error);
          },
        );
      },
    );
  }

  Future<void> _handleClearData() async {
    MaterialDialog.warningClearDataDialog(
      context,
      title: 'Clear Data',
      cancelLabel: "Yes",
      onCancel: () async {
        MaterialDialog.loading(context);
        try {
          await Provider.of<ServiceListProviderOffline>(context, listen: false)
              .clearDocuments();
          await Provider.of<CustomerListProviderOffline>(context, listen: false)
              .clearDocuments();
          await Provider.of<ItemListProviderOffline>(context, listen: false)
              .clearDocuments();
          await Provider.of<EquipmentOfflineProvider>(context, listen: false)
              .clearEquipments();
          await Provider.of<SiteListProviderOffline>(context, listen: false)
              .clearDocuments();
          await LocalStorageManger.setString('isDownloaded', 'false');

          if (mounted) {
            _checkDownloadStatus();
            Navigator.of(context).pop(); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Offline data cleared successfully!")));
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to clear data: $e")));
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Data Sync",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 66, 83, 100),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<ServiceListProviderOffline, EquipmentOfflineProvider>(
        builder: (context, serviceOffline, equipmentOffline, child) {
          final serviceCount = serviceOffline.pendingSyncCount;
          final equipmentCount = equipmentOffline.pendingSyncCount;
          final totalPending = serviceCount + equipmentCount;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              _buildInfoCard(),
              const SizedBox(height: 32),
              _buildSectionHeader("Sync Actions"),
              _buildSyncItem(
                icon: Icons.cloud_upload_outlined,
                title: "Sync to SAP",
                subtitle: totalPending > 0
                    ? "Ready to sync service ($serviceCount) and Equipment ($equipmentCount)"
                    : "Upload your offline work to the server",
                onTap: _handleSyncToSAP,
                color: Colors.green,
                trailingCount: totalPending > 0 ? totalPending : null,
              ),
              _buildSyncItem(
                icon: Icons.download_outlined,
                title: "Download Data",
                subtitle: "Update your master data",
                onTap: _handleDownload,
                color: Colors.blue,
                enabled: _isDownloaded != "true",
              ),
              const SizedBox(height: 24),
              _buildSectionHeader("Danger Zone"),
              _buildSyncItem(
                icon: Icons.delete_outline,
                title: "Clear Offline Data",
                subtitle: "Remove all downloaded data from this device",
                onTap: _handleClearData,
                color: Colors.red,
                // enabled: _isDownloaded == "true",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    final bool isReady = _isDownloaded == "true";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isReady ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReady ? Colors.green.shade100 : Colors.blue.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.info_outline,
            color: isReady ? Colors.green : Colors.blue,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? "System Ready" : "Data Required",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color:
                        isReady ? Colors.green.shade900 : Colors.blue.shade900,
                  ),
                ),
                Text(
                  isReady
                      ? "All master data is downloaded and available for offline use."
                      : "Please download master data to start working offline.",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color:
                        isReady ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSyncItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool enabled = true,
    int? trailingCount,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: enabled ? onTap : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          trailing: trailingCount != null && trailingCount > 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailingCount.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade300,
                  size: 14,
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// Premium Download Dialog Widget
// ============================================================================

enum _DownloadStepStatus { waiting, downloading, completed }

class _DownloadStep {
  final String name;
  final IconData icon;
  final Color color;
  _DownloadStepStatus status = _DownloadStepStatus.waiting;
  int count = 0;
  int total = 0;

  _DownloadStep({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _DownloadDialog extends StatefulWidget {
  final CustomerListProvider onlineProviderCustomer;
  final CustomerListProviderOffline offlineProviderCustomer;
  final ItemListProvider onlineProviderItem;
  final ItemListProviderOffline offlineProviderItem;
  final SiteListProvider onlineProviderSite;
  final SiteListProviderOffline offlineProviderSite;
  final EquipmentListProvider onlineProviderEquipment;
  final EquipmentOfflineProvider offlineProviderEquipment;
  final VoidCallback onComplete;
  final Function(String) onError;

  const _DownloadDialog({
    required this.onlineProviderCustomer,
    required this.offlineProviderCustomer,
    required this.onlineProviderItem,
    required this.offlineProviderItem,
    required this.onlineProviderSite,
    required this.offlineProviderSite,
    required this.onlineProviderEquipment,
    required this.offlineProviderEquipment,
    required this.onComplete,
    required this.onError,
  });

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isStarted = false;
  bool _isCompleted = false;

  final List<_DownloadStep> _steps = [
    _DownloadStep(
      name: "Customers",
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF3B82F6),
    ),
    _DownloadStep(
      name: "Items",
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFFF59E0B),
    ),
    _DownloadStep(
      name: "Sites",
      icon: Icons.location_city_rounded,
      color: const Color(0xFF10B981),
    ),
    _DownloadStep(
      name: "Equipment",
      icon: Icons.build_circle_rounded,
      color: const Color(0xFFEC4899),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDownload();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get _completedCount =>
      _steps.where((s) => s.status == _DownloadStepStatus.completed).length;

  double get _overallProgress =>
      _steps.isEmpty ? 0 : _completedCount / _steps.length;

  Future<void> _startDownload() async {
    if (_isStarted) return;
    _isStarted = true;

    try {
      // Step 1: Customers (with progress tracking)
      await _downloadWithProgress(0, widget.onlineProviderCustomer, () async {
        await widget.onlineProviderCustomer.fetchDocumentOffline(
          loadMore: false,
          isSetFilter: false,
          context: context,
        );
        await widget.offlineProviderCustomer
            .saveDocuments(widget.onlineProviderCustomer.documentOffline);
        return widget.onlineProviderCustomer.documentOffline.length;
      });

      // Step 2: Items (with progress tracking)
      await _downloadWithProgress(1, widget.onlineProviderItem, () async {
        await widget.onlineProviderItem.fetchDocumentOffline(
          loadMore: false,
          isSetFilter: false,
          context: context,
        );
        await widget.offlineProviderItem
            .saveDocuments(widget.onlineProviderItem.documentOffline);
        return widget.onlineProviderItem.documentOffline.length;
      });

      // Step 3: Sites (with progress tracking)
      await _downloadWithProgress(2, widget.onlineProviderSite, () async {
        await widget.onlineProviderSite.fetchOfflineDocuments(
          loadMore: false,
          isSetFilter: false,
        );
        await widget.offlineProviderSite
            .saveDocuments(widget.onlineProviderSite.documentOffline);
        return widget.onlineProviderSite.documentOffline.length;
      });

      // Step 4: Equipment (with progress tracking)
      await _downloadWithProgress(3, widget.onlineProviderEquipment, () async {
        await widget.onlineProviderEquipment.fetchOfflineDocuments(
          loadMore: false,
          isSetFilter: false,
        );
        await widget.offlineProviderEquipment
            .saveDocuments(widget.onlineProviderEquipment.documentOffline);
        return widget.onlineProviderEquipment.documentOffline.length;
      });

      // All done!
      await LocalStorageManger.setString('isDownloaded', 'true');

      setState(() => _isCompleted = true);

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete();
      }
    } catch (e) {
      if (e.toString().contains("cancelled")) {
        debugPrint("Download truly cancelled. Cleaning up UI...");
        return;
      }
      if (mounted) {
        Navigator.of(context).pop();
        widget.onError(e.toString());
      }
    }
  }

  Future<void> _cancelDownload() async {
    // 1. Tell all providers to stop
    widget.onlineProviderCustomer.cancelDownload();
    widget.onlineProviderItem.cancelDownload();
    widget.onlineProviderSite.cancelDownload();
    widget.onlineProviderEquipment.cancelDownload();

    // 2. Clear already saved data to avoid partial sync
    await widget.offlineProviderCustomer.clearDocuments();
    await widget.offlineProviderItem.clearDocuments();
    await widget.offlineProviderSite.clearDocuments();
    await widget.offlineProviderEquipment.clearEquipments();

    if (mounted) {
      Navigator.of(context).pop();
      // Optional: show a message that it was cancelled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download cancelled and data removed"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Generic download method with progress tracking
  /// Works with any provider that has fetchedCount and totalCount getters
  Future<void> _downloadWithProgress(
    int index,
    ChangeNotifier provider,
    Future<int> Function() download,
  ) async {
    setState(() {
      _steps[index].status = _DownloadStepStatus.downloading;
    });

    void onProgress() {
      if (mounted) {
        // Use reflection-like approach to get fetchedCount/totalCount
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

        setState(() {
          _steps[index].count = fetched;
          _steps[index].total = total;
        });
      }
    }

    provider.addListener(onProgress);

    try {
      final count = await download();

      setState(() {
        _steps[index].status = _DownloadStepStatus.completed;
        _steps[index].count = count;
        _steps[index].total = count;
      });
    } finally {
      provider.removeListener(onProgress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isCompleted
                      ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                      : [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: _isCompleted
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                        0.3 * _pulseController.value),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                        ),
                        child: Icon(
                          _isCompleted
                              ? Icons.check_rounded
                              : Icons.cloud_download_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isCompleted ? "Download Complete!" : "Downloading Data",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCompleted
                        ? "All data is now available offline"
                        : "$_completedCount of ${_steps.length} categories",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _overallProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Steps List
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _steps.length,
                itemBuilder: (context, index) => _buildStepItem(_steps[index]),
              ),
            ),
            const Divider(height: 1),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (!_isCompleted)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _cancelDownload,
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFFEF4444)),
                        label: Text(
                          "Cancel Download",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                                color:
                                    const Color(0xFFEF4444).withOpacity(0.2)),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(_DownloadStep step) {
    final isActive = step.status == _DownloadStepStatus.downloading;
    final isCompleted = step.status == _DownloadStepStatus.completed;
    final isWaiting = step.status == _DownloadStepStatus.waiting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : isActive
                      ? step.color.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isActive
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(step.color),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    isCompleted ? Icons.check_rounded : step.icon,
                    color: isCompleted
                        ? const Color(0xFF22C55E)
                        : isWaiting
                            ? Colors.grey[400]
                            : step.color,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isWaiting ? Colors.grey[400] : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                if (isActive && step.total > 0)
                  Text(
                    "Fetching ${step.count} of ${step.total}...",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: step.color,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isCompleted)
                  Text(
                    "${step.total} records",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isActive)
                  Text(
                    "Downloading...",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: step.color,
                    ),
                  )
                else
                  Text(
                    "Waiting...",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),

          // Status badge
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Done",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
