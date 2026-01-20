import 'dart:async';
import 'dart:io';
import 'package:bizd_tech_service/core/widgets/DateForServiceList.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/component/block_service.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/screen/sericeEntry.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:bizd_tech_service/core/extensions/theme_extensions.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  final bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  String? userName;
  final TextEditingController _dateController = TextEditingController();

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSyncServices(); // Auto-sync on screen load
    });
  }

  /// Auto-sync services when screen loads (if online)
  Future<void> _autoSyncServices() async {
    if (_isSyncing) return;

    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    try {
      setState(() => _isSyncing = true);
      offlineProvider.setSyncing(true);

      // Check internet connectivity
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        debugPrint("📴 No internet connection - skipping sync");
        return;
      }

      debugPrint("📡 Internet available - starting auto-sync...");

      // Get providers
      final onlineProvider =
          Provider.of<ServiceListProvider>(context, listen: false);

      // Get existing DocEntries from offline storage
      final existingDocEntries = await offlineProvider.getExistingDocEntries();
      debugPrint(
          "📦 Found ${existingDocEntries.length} existing offline records");

      // Fetch only NEW services from API
      final newServices = await onlineProvider.fetchNewServicesForSync(
        existingDocEntries: existingDocEntries,
      );

      if (newServices.isNotEmpty) {
        // Merge new services with existing offline data
        await offlineProvider.mergeNewDocuments(newServices);
        debugPrint(
            "✅ Auto-sync complete: ${newServices.length} new services added");
      } else {
        debugPrint("✅ Auto-sync complete: No new services to add");
        // Still load documents to refresh the view
        await offlineProvider.loadDocuments();
      }
    } catch (e) {
      debugPrint("❌ Auto-sync error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        offlineProvider.setSyncing(false);
      }
    }
  }

  /// Check if device has internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Future<void> _init() async {
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await _loadUserName();
  //   final svProvider = Provider.of<ServiceListProvider>(context, listen: false);

  //   if (svProvider.documents.isEmpty) {
  //     await svProvider.fetchDocuments(context: context);
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  // Future<void> _initOffline() async {
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   final _userId = await LocalStorageManger.getString('UserId');

  //   await _loadUserName();
  //   final offlineProvider =
  //       Provider.of<ServiceListProviderOffline>(context, listen: false);

  //   await offlineProvider.loadDocuments();

  //   // Use filteredDocs in UI
  //   print("Offline filtered docs: ${offlineProvider");

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('UserName');
  }

  Future<void> onUpdateStatus(int entry, String currentStatus) async {
    MaterialDialog.loading(context);

    try {
      // ⏳ Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);
      final onlineProvider =
          Provider.of<ServiceListProvider>(context, listen: false);

      final cachedDoc = await offlineProvider.getDocumentByDocEntry(entry);
      if (cachedDoc == null) {
        throw "Document not found";
      }

      final now = DateTime.now();
      final timeStamp = DateFormat("HH:mm:ss").format(now);
      // Determine next status
      String nextStatus;
      switch (currentStatus) {
        case "Pending" || "Open":
          nextStatus = "Accept";
          break;
        case "Accept":
          nextStatus = "Travel";
          break;
        case "Travel":
          nextStatus = "Service";
          break;
        default:
          nextStatus = "Entry";
      }

      // Prepare payload
      final updatePayload = {
        // ...cachedDoc,
        // "U_CK_TravelTime": currentStatus == "Accept" ? timeStamp : undefined,
        "U_CK_Time": cachedDoc["U_CK_Time"] ?? "",
        "U_CK_EndTime": cachedDoc["U_CK_EndTime"] ?? "",
        'DocEntry': entry,
        'U_CK_Status': nextStatus,
      };

      if (currentStatus == "Pending" || currentStatus == "Open") {
        updatePayload["U_CK_Time"] = timeStamp;
      } else {
        updatePayload["U_CK_EndTime"] = timeStamp;
      }
      if (currentStatus == "Open" || currentStatus == "Pending") {
        updatePayload["U_CK_AcceptTime"] = timeStamp;
      }
      if (currentStatus == "Accept") {
        updatePayload["U_CK_TravelTime"] = timeStamp;
      }
      debugPrint("📤 Updating status to $nextStatus for DocEntry: $entry");

      // 1. Update Online if internet is available
      final hasInternet = await _checkInternetConnection();
      if (hasInternet) {
        await onlineProvider.updateStatusDirectToSAP(
          updatePayload: updatePayload,
          context: context,
        );
      } else {
        debugPrint("📡 Offline mode: Skipping SAP update, will sync later.");
      }

      // 2. Update Offline storage
      await offlineProvider.updateDocumentAndStatusOffline(
        docEntry: entry,
        status: nextStatus,
        time: timeStamp,
        context: context,
      );

      // 3. Refresh and Close
      offlineProvider.refreshDocuments();

      if (mounted) {
        MaterialDialog.close(context);
      }
    } catch (e) {
      debugPrint("❌ Error in onUpdateStatus: $e");
      if (mounted) {
        MaterialDialog.close(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    _dateController.clear(); // Clear the date controller
    // final provider = context.read<ServiceListProvider>();
    // provider.resetPagination();
    // provider.clearCurrentDate();
    // await provider.resfreshFetchDocuments(context);
    final provider = context.read<ServiceListProviderOffline>();
    provider.refreshDocuments(); // clear filter + reload all
  }

  Future<void> clearOfflineDataWithLogout(BuildContext context) async {
    final offlineProviderService =
        Provider.of<ServiceListProviderOffline>(context, listen: false);
    final offlineProviderServiceCustomer =
        Provider.of<CustomerListProviderOffline>(context, listen: false);
    final offlineProviderServiceItem =
        Provider.of<ItemListProviderOffline>(context, listen: false);
    final offlineProviderEquipment =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);
    final offlineProviderSite =
        Provider.of<SiteListProviderOffline>(context, listen: false);

    try {
      // Clear service data
      await offlineProviderService.clearDocuments();
      await offlineProviderServiceCustomer.clearDocuments();
      await offlineProviderServiceItem.clearDocuments();
      await offlineProviderEquipment.clearEquipments();
      await offlineProviderSite.clearDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
    // Show loading popup
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceListProviderOffline>(
      builder: (context, serviceProvider, _) {
        final documents = serviceProvider.documents.where((doc) {
          final status = doc['U_CK_Status']?.toString() ?? '';
          final date = doc['U_CK_Date']?.toString() ?? '';
          final dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());

          // return status != 'Open' &&
          //     status != 'Entry' &&
          //     date.compareTo(dateNow) >= 0;
          return status != 'Entry' &&
              status != "Rejected" &&
              date.compareTo(dateNow) >= 0;
          // works if date is in yyyy-MM-dd or ISO format
        }).toList();
        final isLoading = serviceProvider.isLoading;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   backgroundColor: Color.fromARGB(255, 66, 83, 100),
          //   elevation: 0,
          //   centerTitle: true,
          //   title: Text(
          //     "Service Manager",
          //     style: GoogleFonts.inter(
          //       fontSize: 17.sp,
          //       fontWeight: FontWeight.w700,
          //       color: Colors.white,
          //     ),
          //   ),
          //   actions: [
          //     _isSyncing
          //         ? Padding(
          //             padding: EdgeInsets.only(right: 3.w),
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 SizedBox(
          //                   width: 14.sp,
          //                   height: 14.sp,
          //                   child: CircularProgressIndicator(
          //                     strokeWidth: 2,
          //                     valueColor: AlwaysStoppedAnimation<Color>(
          //                       Colors.greenAccent,
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2.w),
          //                 Text(
          //                   "Syncing...",
          //                   style: GoogleFonts.inter(
          //                     fontSize: 13.sp,
          //                     fontWeight: FontWeight.w500,
          //                     color: Colors.white,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           )
          //         : Container(),
          //   ],
          // ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.5.h),
              // Modern Filter Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: DateForServiceList(
                        controller: _dateController,
                        star: false,
                        detail: false,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      height: 52, // Match DateForServiceList height
                      width: 14.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF425364), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF425364).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          final provider =
                              context.read<ServiceListProviderOffline>();

                          if (_dateController.text.isNotEmpty) {
                            try {
                              final parsedDate = DateFormat("dd MMMM yyyy")
                                  .parse(_dateController.text);

                              provider.setDate(parsedDate);
                              provider.loadDocuments();
                            } catch (e) {
                              debugPrint("Error parsing date: $e");
                            }
                          }
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 19.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 1.5.h),
              Expanded(
                child: documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_late_outlined,
                              size: 40.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "No Services Scheduled",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              "Scheduled services will appear here",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        // padding: EdgeInsets.symmetric(vertical: 1.h),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final travel = documents[index];
                          return BlockService(
                            data: travel as dynamic,
                            onRefresh: _refreshData,
                            onTap: () async {
                              if (travel["U_CK_Status"] == "Service") {
                                goTo(context, ServiceEntryScreen(data: travel))
                                    .then((e) {
                                  if (e == true) {
                                    _refreshData();
                                  }
                                });
                                return;
                              }
                              onUpdateStatus(
                                travel["DocEntry"],
                                travel["U_CK_Status"],
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
