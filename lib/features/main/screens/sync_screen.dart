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
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
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
    MaterialDialog.loading(context);
    try {
      final res1 = await Provider.of<CompletedServiceProvider>(context, listen: false)
          .syncAllOfflineServicesToSAP(context);
      final res2 = await Provider.of<EquipmentCreateProvider>(context, listen: false)
          .syncAllOfflineEquipmentToSAP(context);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        if (res1 == false && res2 == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No offline data to synchronize."))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Synchronization complete!"))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sync failed: $e"))
        );
      }
    }
  }

  Future<void> _handleDownload() async {
    final onlineProvider = Provider.of<ServiceListProvider>(context, listen: false);
    final offlineProvider = Provider.of<ServiceListProviderOffline>(context, listen: false);
    final onlineProviderCustomer = Provider.of<CustomerListProvider>(context, listen: false);
    final offlineProviderCustomer = Provider.of<CustomerListProviderOffline>(context, listen: false);
    final onlineProviderItem = Provider.of<ItemListProvider>(context, listen: false);
    final offlineProviderItem = Provider.of<ItemListProviderOffline>(context, listen: false);
    final onlineProviderSite = Provider.of<SiteListProvider>(context, listen: false);
    final offlineProviderSite = Provider.of<SiteListProviderOffline>(context, listen: false);
    final onlineProviderEquipment = Provider.of<EquipmentListProvider>(context, listen: false);
    final offlineProviderEquipment = Provider.of<EquipmentOfflineProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String statusMessage = "Starting download...";
        double progress = 0.0;
        bool isDownloadStarted = false;

        final steps = [
          "Downloading Service Tickets...",
          "Saving Service Tickets...",
          "Downloading Customers...",
          "Saving Customers...",
          "Downloading Items...",
          "Saving Items...",
          "Downloading Sites...",
          "Saving Sites...",
          "Downloading Equipment...",
          "Saving Equipment...",
        ];

        return StatefulBuilder(
          builder: (statefulContext, setState) {
            Future<void> updateStep(int index, String message) async {
              setState(() {
                statusMessage = message;
                progress = (index + 1) / steps.length;
              });
            }

            if (!isDownloadStarted) {
              isDownloadStarted = true;
              Future.microtask(() async {
                try {
                  await updateStep(0, steps[0]);
                  await onlineProvider.fetchDocumentTicket(loadMore: false, isSetFilter: false, context: statefulContext);
                  await updateStep(1, steps[1]);
                  await offlineProvider.saveDocuments(onlineProvider.documentsTicket);

                  await updateStep(2, steps[2]);
                  await onlineProviderCustomer.fetchDocumentOffline(loadMore: false, isSetFilter: false, context: statefulContext);
                  await updateStep(3, steps[3]);
                  await offlineProviderCustomer.saveDocuments(onlineProviderCustomer.documentOffline);

                  await updateStep(4, steps[4]);
                  await onlineProviderItem.fetchDocumentOffline(loadMore: false, isSetFilter: false, context: statefulContext);
                  await updateStep(5, steps[5]);
                  await offlineProviderItem.saveDocuments(onlineProviderItem.documentOffline);

                  await updateStep(6, steps[6]);
                  await onlineProviderSite.fetchOfflineDocuments(loadMore: false, isSetFilter: false);
                  await updateStep(7, steps[7]);
                  await offlineProviderSite.saveDocuments(onlineProviderSite.documentOffline);

                  await updateStep(8, steps[8]);
                  await onlineProviderEquipment.fetchOfflineDocuments(loadMore: false, isSetFilter: false);
                  await updateStep(9, steps[9]);
                  await offlineProviderEquipment.saveDocuments(onlineProviderEquipment.documentOffline);

                  await LocalStorageManger.setString('isDownloaded', 'true');
                  if (mounted) {
                    _checkDownloadStatus();
                    Navigator.of(statefulContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All documents downloaded successfully!"))
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(statefulContext).pop();
                    MaterialDialog.warning(context, title: "Error", body: e.toString());
                  }
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_download, size: 40, color: Colors.blue),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: progress, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(statusMessage, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text("${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
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
          await Provider.of<ServiceListProviderOffline>(context, listen: false).clearDocuments();
          await Provider.of<CustomerListProviderOffline>(context, listen: false).clearDocuments();
          await Provider.of<ItemListProviderOffline>(context, listen: false).clearDocuments();
          await Provider.of<EquipmentOfflineProvider>(context, listen: false).clearEquipments();
          await Provider.of<SiteListProviderOffline>(context, listen: false).clearDocuments();
          await LocalStorageManger.setString('isDownloaded', 'false');
          
          if (mounted) {
            _checkDownloadStatus();
            Navigator.of(context).pop(); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Offline data cleared successfully!"))
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to clear data: $e"))
            );
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
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 32),
          _buildSectionHeader("Sync Actions"),
          _buildSyncItem(
            icon: Icons.cloud_upload_outlined,
            title: "Sync to SAP",
            subtitle: "Upload your offline work to the server",
            onTap: _handleSyncToSAP,
            color: Colors.green,
          ),
          _buildSyncItem(
            icon: Icons.download_outlined,
            title: "Download Data",
            subtitle: "Update local tickets and master data",
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
            enabled: _isDownloaded == "true",
          ),
        ],
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
                    color: isReady ? Colors.green.shade900 : Colors.blue.shade900,
                  ),
                ),
                Text(
                  isReady 
                    ? "All data is downloaded and available for offline use."
                    : "Please download master data to start working offline.",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isReady ? Colors.green.shade700 : Colors.blue.shade700,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade300,
            size: 14,
          ),
        ),
      ),
    );
  }
}
