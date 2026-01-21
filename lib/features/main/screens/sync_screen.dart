import 'package:flutter/material.dart';
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
import 'package:bizd_tech_service/features/main/provider/download_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bizd_tech_service/features/service/screens/detail/service_detail_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

            final List<String> errors = [
              ...List<String>.from(res1['errors'] ?? []),
              ...List<String>.from(res2['errors'] ?? []),
            ];

            if (errors.isNotEmpty) {
              // Show warning dialog for each error document
              for (String errorMsg in errors) {
                if (!mounted) break;
                await MaterialDialog.warning(
                  context,
                  title: "Sync Error",
                  body: errorMsg,
                  confirmLabel: "OK",
                );
              }
            }

            if (res1['total'] == 0 && res2['total'] == 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("No offline data to synchronize.")));
            } else if (errors.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Synchronization complete!")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Synchronization finished with ${errors.length} errors.")));
            }
          }
        } catch (e) {
          debugPrint("Sync Error: $e");
          if (mounted) {
            MaterialDialog.close(context); // Safe close loading
            MaterialDialog.warning(
              context,
              title: "Sync Process Error",
              body: e.toString(),
              confirmLabel: "OK",
            );
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
            if (!mounted) return;
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
            if (!mounted) return;
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
      body: Consumer3<ServiceListProviderOffline, EquipmentOfflineProvider,
          DownloadProvider>(
        builder: (context, serviceOffline, equipmentOffline, downloadProvider,
            child) {
          final serviceCount = serviceOffline.pendingSyncCount;
          final equipmentCount = equipmentOffline.pendingSyncCount;
          final totalPending = serviceCount + equipmentCount;

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 2.5.h),
            children: [
              if (downloadProvider.isStarted && !downloadProvider.isCompleted)
                _buildActiveDownloadCard(downloadProvider),
              _buildInfoCard(),
              SizedBox(height: 3.h),
              _buildSyncItem(
                icon: Icons.cloud_upload_rounded,
                title: "Sync to SAP",
                subtitle: totalPending > 0
                    ? "Ready to sync service ($serviceCount) and Equipment ($equipmentCount)"
                    : "Upload your offline work to the server",
                onTap: _handleSyncToSAP,
                color: const Color(0xFF22C55E),
                trailingCount: totalPending > 0 ? totalPending : null,
              ),
              _buildSyncItem(
                icon: Icons.download_rounded,
                title:
                    downloadProvider.isStarted && !downloadProvider.isCompleted
                        ? "Download in Progress..."
                        : "Download Data",
                subtitle:
                    downloadProvider.isStarted && !downloadProvider.isCompleted
                        ? "Click to view progress"
                        : "Update your master data",
                onTap: _handleDownload,
                color: const Color(0xFF3B82F6),
                enabled: _isDownloaded != "true" ||
                    (downloadProvider.isStarted &&
                        !downloadProvider.isCompleted),
              ),
              SizedBox(height: 3.h),
              // ... rest of the list ...
              if (serviceOffline.completedServices
                  .any((s) => s['sync_status'] != 'synced')) ...[
                _buildSectionHeader("Operations Pending Sync"),
                ...serviceOffline.completedServices.reversed
                    .where((service) => service['sync_status'] != 'synced')
                    .map((service) {
                  return _buildServiceListItem(service, serviceOffline);
                }),
                SizedBox(height: 2.h),
              ],
              if (equipmentOffline.equipments
                  .any((e) => e['sync_status'] == 'pending')) ...[
                _buildSectionHeader("Equipment Pending Sync"),
                ...equipmentOffline.equipments.reversed
                    .where((e) => e['sync_status'] == 'pending')
                    .map((equipment) {
                  return _buildEquipmentListItem(equipment);
                }),
                SizedBox(height: 2.h),
              ],
              _buildSectionHeader("Maintenance"),
              _buildSyncItem(
                icon: Icons.delete_sweep_rounded,
                title: "Clear All Offline Data",
                subtitle: "Completely reset local storage",
                onTap: _handleClearData,
                color: const Color(0xFFEF4444),
                // enabled: _isDownloaded == "true",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveDownloadCard(DownloadProvider provider) {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  "Background Download Running",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                "${(provider.overallProgress * 100).toInt()}%",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.overallProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceListItem(
      Map<dynamic, dynamic> service, ServiceListProviderOffline provider) {
    final docEntry = service['DocEntry'];

    // Try to find the document to get the customer name
    final doc = provider.documents.cast<Map<String, dynamic>>().firstWhere(
          (d) => d['DocEntry'] == docEntry,
          orElse: () => <String, dynamic>{},
        );

    final cardName = doc['U_CK_Cardname'] ?? "Unknown Customer";
    final docNum = doc['DocNum'] ?? doc['id'] ?? 'N/A';

    final address = (doc['CustomerAddress'] as List?)?.isNotEmpty == true
        ? doc['CustomerAddress'][0]['StreetNo'] ?? 'No Address'
        : doc['Address'] ?? 'No Address';
    final date = doc['U_CK_Date'] != null
        ? doc['U_CK_Date'].toString().split('T')[0]
        : 'No Date';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(
              data: Map<String, dynamic>.from(doc.isNotEmpty ? doc : service),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.pending_actions_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          "Ticket #$docNum",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Text(
                      "PENDING",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 16.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      address,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.event_rounded,
                      size: 16.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 2.w),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentListItem(Map<dynamic, dynamic> equipment) {
    final name = equipment['Name'] ?? "Unknown Equipment";
    final code = equipment['Code'] ?? "N/A";
    final sn = equipment['U_ck_eqSerNum'] ?? "N/A";
    final customer = equipment['U_ck_CusName'] ?? "No Customer";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: const Color(0xFF3B82F6),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        "Code: $code",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    "NEW",
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                Icon(Icons.person_pin_rounded,
                    size: 16.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    customer,
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.qr_code_rounded,
                    size: 16.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 2.w),
                Text(
                  sn,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final bool isReady = _isDownloaded == "true";
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isReady ? const Color(0xFFBBF7D0) : const Color(0xFFDBEAFE),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle_rounded : Icons.info_rounded,
            color: isReady ? const Color(0xFF22C55E) : const Color(0xFF3B82F6),
            size: 25.sp,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? "System Ready" : "Data Sync Required",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: isReady
                        ? const Color(0xFF166534)
                        : const Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  isReady
                      ? "All master data is synchronized and available for offline use."
                      : "Please download master data to enable offline capabilities.",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: isReady
                        ? const Color(0xFF15803D)
                        : const Color(0xFF1D4ED8),
                    height: 1.3,
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
      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 1.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1.5,
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
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: ListTile(
          onTap: enabled ? onTap : null,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          leading: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              color: const Color(0xFF1E293B),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: trailingCount != null && trailingCount > 0
              ? Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    trailingCount.toString(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 20.sp,
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// Premium Download Dialog Widget
// ============================================================================

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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DownloadProvider>(context, listen: false);
      if (!provider.isStarted || provider.isError) {
        provider.startDownload(
          context: context,
          onlineProviderCustomer: widget.onlineProviderCustomer,
          offlineProviderCustomer: widget.offlineProviderCustomer,
          onlineProviderItem: widget.onlineProviderItem,
          offlineProviderItem: widget.offlineProviderItem,
          onlineProviderSite: widget.onlineProviderSite,
          offlineProviderSite: widget.offlineProviderSite,
          onlineProviderEquipment: widget.onlineProviderEquipment,
          offlineProviderEquipment: widget.offlineProviderEquipment,
          onComplete: widget.onComplete,
          onError: widget.onError,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: 85.w),
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
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: provider.isCompleted
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
                            width: 15.w,
                            height: 15.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: provider.isCompleted
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
                              provider.isCompleted
                                  ? Icons.check_rounded
                                  : Icons.cloud_download_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        provider.isCompleted
                            ? "Download Complete!"
                            : "Downloading Data",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        provider.isCompleted
                            ? "All data is now available offline"
                            : "${provider.completedCount} of ${provider.steps.length} categories",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: provider.overallProgress,
                          minHeight: 1.h,
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
                    itemCount: provider.steps.length,
                    itemBuilder: (context, index) =>
                        _buildStepItem(provider.steps[index]),
                  ),
                ),
                const Divider(height: 1),

                // Actions
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      if (!provider.isCompleted) ...[
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              provider.cancelDownload(
                                widget.onlineProviderCustomer,
                                widget.onlineProviderItem,
                                widget.onlineProviderSite,
                                widget.onlineProviderEquipment,
                              );
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close_rounded,
                                size: 16.sp, color: const Color(0xFFEF4444)),
                            label: Text(
                              "Stop",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.minimize_rounded, size: 16.sp),
                            label: Text(
                              "Minimize",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ] else
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
                                fontSize: 14.sp,
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
      },
    );
  }

  Widget _buildStepItem(DownloadStep step) {
    final isActive = step.status == DownloadStepStatus.downloading;
    final isCompleted = step.status == DownloadStepStatus.completed;
    final isWaiting = step.status == DownloadStepStatus.waiting;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 10.w,
            height: 10.w,
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
                    size: 18.sp,
                  ),
          ),
          SizedBox(width: 3.5.w),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isWaiting ? Colors.grey[400] : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 0.2.h),
                if (isActive && step.total > 0)
                  Text(
                    "Fetching ${step.count} of ${step.total}...",
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: step.color,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isCompleted)
                  Text(
                    "${step.total} records",
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isActive)
                  Text(
                    "Downloading...",
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: step.color,
                    ),
                  )
                else
                  Text(
                    "Waiting...",
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),

          // Status badge
          if (isCompleted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF22C55E),
                    size: 14.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    "Done",
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
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
