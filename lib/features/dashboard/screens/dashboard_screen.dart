import 'dart:io';

import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';
import 'package:bizd_tech_service/features/service/screens/detail/service_detail_screen.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/core/extensions/theme_extensions.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.fromNotification = false});
  final bool fromNotification;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  List<Map<String, dynamic>> ticketGroups = [];
  // final DioClient _dio = DioClient(); // Your custom Dio client
  bool load = false;
  String _selectedJob = "All"; // All, Open, Closed
  String _jobClass = "All"; // All, Open, Closed
  String _selectedPriority = "All"; // All, High, Medium, Low
  List<dynamic> documentOffline = [];
  List<dynamic> completedService = [];
  String isDownloaded = "false";
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);
      // ✅ Make sure documents are loaded
      await offlineProvider.loadDocuments();
      if (!mounted) return;

      // ✅ Replace the list instead of addAll
      setState(() {
        documentOffline = List.from(offlineProvider.documents);
        completedService = List.from(offlineProvider.completedServices);
      });

      // ✅ Fetch ticket counts after docs are loaded
      await _fetchTicketCounts();
      if (!mounted) return;
      await _autoSyncServices();
      if (!mounted) return;
      await _fetchTicketCounts();
    });

    // Other initializations
    _loadUserName();
    _tabController = TabController(length: 2, vsync: this);
    _initTicketDates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isExpanded = false; // add this in your State

  Future<void> _loadUserName() async {
    final name = await LocalStorageManger.getString('FullName');
    final user = await LocalStorageManger.getString('UserName');
    final isDownLoadDone = await LocalStorageManger.getString('isDownloaded');
    if (!mounted) return;
    setState(() {
      userName = name;
      isDownloaded = isDownLoadDone;
    });
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

  void _initTicketDates() {
    DateTime now = DateTime.now();
    ticketGroups = List.generate(5, (index) {
      DateTime date = now.add(Duration(days: index));
      String formattedDate =
          index == 0 ? "Today" : DateFormat('dd MMM yyyy').format(date);
      return {
        "date": formattedDate,
        "dateValue": DateFormat('yyyy-MM-dd').format(date),
        "count": 0,
        "tickets": [],
      };
    });
  }

  /// Fetch count of tickets for each date from SAP
  // Future<void> _fetchTicketCounts() async {
  //   setState(() {
  //     load = true; // hide loading after all counts fetched
  //   });
  //   // optional small delay before hiding overall loading
  //   await Future.delayed(const Duration(milliseconds: 500));

  //   setState(() {
  //     load = false; // hide loading after all counts fetched
  //   });
  //   for (var group in ticketGroups) {
  //     final dateValue = group["dateValue"];
  //     setState(() {
  //       group["isLoadingCount"] = true; // show loading
  //       group["tickets"] = []; // clear cached tickets
  //     });
  //     String filter = "U_CK_Date eq '$dateValue'";

  //     if (_selectedJob != "All") {
  //       filter += " and U_CK_JobType eq '$_selectedJob'";
  //     }

  //     if (_jobClass != "All") {
  //       filter += " and U_CK_ServiceType eq '$_jobClass'";
  //     }
  //     if (_selectedPriority != "All") {
  //       filter += " and U_CK_Priority eq '$_selectedPriority'";
  //     }

  //     try {
  //       final response =
  //           await _dio.get("/CK_JOBORDER/\$count?\$filter=$filter");
  //       setState(() {
  //         group["count"] = response.data;
  //         group["isLoadingCount"] = false; // hide loading
  //       });
  //     } catch (e) {
  //       setState(() {
  //         group["count"] = 0;
  //         group["isLoadingCount"] = false; // hide loading
  //         group["tickets"] = []; // also clear on error
  //       });
  //       debugPrint("Error fetching count for $dateValue: $e");
  //     }
  //   }
  // }
  /// Fetch count of tickets for each date using offline documents
  /// Fetch count of tickets for each date using offline documents
  Future<void> _fetchTicketCounts() async {
    setState(() {
      load = true; // show overall loading
    });

    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);
    await offlineProvider.loadDocuments(); // make sure docs loaded
    if (!mounted) return;

    documentOffline = List.from(offlineProvider.documents);
    completedService = List.from(offlineProvider.completedServices);

    for (var group in ticketGroups) {
      final dateValue = group["dateValue"];
      setState(() {
        group["isLoadingCount"] = true; // show loading for this group
        group["tickets"] = []; // clear cached tickets
      });

      // Filter offline documents
      var filteredDocs = offlineProvider.documents.where((doc) {
        bool match = doc["U_CK_Date"] == '${dateValue}T00:00:00Z';

        if (_selectedJob != "All") {
          match = match && doc["U_CK_JobType"] == _selectedJob;
        }
        if (_jobClass != "All") {
          match = match && doc["U_CK_JobClass"] == _jobClass;
        }
        if (_selectedPriority != "All") {
          match = match && doc["U_CK_Priority"] == _selectedPriority;
        }

        return match;
      }).toList();

      setState(() {
        group["count"] = filteredDocs.length; // count of filtered docs
        group["tickets"] = filteredDocs; // optionally store actual tickets
        group["isLoadingCount"] = false; // hide loading
      });
    }

    // optional small delay for smooth UI
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        load = false; // hide overall loading
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter Tickets",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Job Type section
                  _buildFilterHeader("Job Type"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["All", "Installation", "Maintenance", "Others"]
                        .map((jType) {
                      final isSelected = _selectedJob == jType;
                      return _buildFilterSelectionChip(
                        label: jType,
                        isSelected: isSelected,
                        onSelected: () {
                          setModalState(() {
                            _selectedJob = jType;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildFilterHeader("Job Class"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      "All",
                      "Breakdown",
                      "Emergency",
                      "Overhaul",
                      "Corrective",
                      "Preventive",
                      "Ad-Hoc"
                    ].map((jobClass) {
                      final isSelected = _jobClass == jobClass;
                      return _buildFilterSelectionChip(
                        label: jobClass,
                        isSelected: isSelected,
                        onSelected: () {
                          setModalState(() {
                            _jobClass = jobClass;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildFilterHeader("Priority"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ["All", "High", "Medium", "Low"].map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return _buildFilterSelectionChip(
                        label: priority,
                        isSelected: isSelected,
                        onSelected: () {
                          setModalState(() {
                            _selectedPriority = priority;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedJob = "All";
                              _jobClass = "All";
                              _selectedPriority = "All";
                            });
                            _fetchTicketCounts();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10), // 🔽 smaller
                            minimumSize: const Size(0, 38), // 🔽 control height
                            tapTargetSize: MaterialTapTargetSize
                                .shrinkWrap, // 🔽 remove extra space
                            side: BorderSide(
                                color: context.colors.outlineVariant),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // optional smaller radius
                            ),
                          ),
                          child: Text(
                            "Reset",
                            style: GoogleFonts.inter(
                              fontSize: 13, // optional smaller text
                              fontWeight: FontWeight.w600,
                              color: context.colors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            _fetchTicketCounts();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 66, 83, 100),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10), // 🔽 smaller
                            minimumSize: const Size(0, 38), // 🔽 control height
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Apply Filters",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildFilterSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? context.colors.onPrimary
            : context.colors.onSurfaceVariant,
      ),
      selected: isSelected,
      selectedColor: Color.fromARGB(255, 66, 83, 100),
      backgroundColor: context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? Color.fromARGB(255, 66, 83, 100)
              : context.colors.outlineVariant,
          width: 1,
        ),
      ),
      showCheckmark: false,
      onSelected: (_) => onSelected(),
    );
  }

  // Future<List<Map<String, String>>> _fetchTicketsFromApi(String date) async {
  //   try {
  //     String filter = "U_CK_Date eq '$date'";

  //     if (_selectedJob != "All") {
  //       filter += " and U_CK_JobType eq '$_selectedJob'";
  //     }

  //     if (_jobClass != "All") {
  //       filter += " and U_CK_ServiceType eq '$_jobClass'";
  //     }
  //     if (_selectedPriority != "All") {
  //       filter += " and U_CK_Priority eq '$_selectedPriority'";
  //     }

  //     final response = await _dio.get(
  //       "/CK_JOBORDER?\$filter=$filter",
  //     );

  //     final List data = response.data["value"] ?? [];
  //     return data.map<Map<String, String>>((item) {
  //       return {
  //         "id": item["DocEntry"].toString(),
  //         "title": item["U_CK_JobName"] ?? "No Title",
  //         "status": item["U_CK_Status"] ?? "Open",
  //         "priority": item["U_CK_Priority"] ?? "Low",
  //       };
  //     }).toList();
  //   } catch (e) {
  //     debugPrint("Error fetching tickets for $date: $e");
  //     return [];
  //   }
  // }
  Future<List<Map<String, dynamic>>> _fetchTicketsFromOffline(
      String date) async {
    try {
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);

      // Make sure documents are loaded
      await offlineProvider.loadDocuments();
      await offlineProvider.loadCompletedServices();

      // Filter offline documents
      final filteredDocs = offlineProvider.documents.where((doc) {
        bool match = doc["U_CK_Date"] == '${date}T00:00:00Z';

        if (_selectedJob != "All") {
          match = match && doc["U_CK_JobType"] == _selectedJob;
        }
        if (_jobClass != "All") {
          match = match && doc["U_CK_ServiceType"] == _jobClass;
        }
        if (_selectedPriority != "All") {
          match = match && doc["U_CK_Priority"] == _selectedPriority;
        }

        return match;
      }).toList();

      // Map to the same format as your API and include sync status
      return filteredDocs.map<Map<String, dynamic>>((item) {
        final doc = Map<String, dynamic>.from(item);

        // If ticket is completed (Entry), find its sync status
        if (doc['U_CK_Status'] == 'Completed') {
          doc['sync_status'] = offlineProvider.getSyncStatus(doc['DocEntry']);
        }
        return doc;
      }).toList();
    } catch (e) {
      debugPrint("Error fetching tickets from offline for $date: $e");
      return [];
    }
  }

  // Color _statusColor(String status) {
  //   switch (status) {
  //     case "Open":
  //       return context.colors.error;
  //     case "In Progress":
  //       return Colors.orangeAccent;
  //     case "Closed":
  //       return context.colors.primary;
  //     case "Pending":
  //       return context.colors.onSurfaceVariant;
  //     default:
  //       return context.colors.outline;
  //   }
  // }

  // Widget _buildDrawerItem(
  //     IconData icon, String title, int index, Widget screen, bool disabled) {
  //   return ListTile(
  //     leading: Icon(icon, color: context.onSurfaceColor),
  //     title: Text(title,
  //         style: TextStyle(
  //             color: context.onSurfaceColor,
  //             fontSize: MediaQuery.of(context).size.width * 0.039)),
  //     onTap: () {
  //       // Navigator.push(
  //       //   context,
  //       //   MaterialPageRoute(builder: (context) => screen),
  //       // );
  //       goTo(context, screen).then((e) => {_fetchTicketCounts()});
  //     },
  //   );
  // }

  // Future<void> downloadAllDocuments(BuildContext context) async {
  //   // final onlineProvider =
  //   //     Provider.of<ServiceListProvider>(context, listen: false);
  //   // final offlineProvider =
  //   Provider.of<ServiceListProviderOffline>(context, listen: false);
  //   final onlineProviderCustomer =
  //       Provider.of<CustomerListProvider>(context, listen: false);
  //   final offlineProviderCustomer =
  //       Provider.of<CustomerListProviderOffline>(context, listen: false);
  //   final onlineProviderItem =
  //       Provider.of<ItemListProvider>(context, listen: false);
  //   final offlineProviderItem =
  //       Provider.of<ItemListProviderOffline>(context, listen: false);
  //   final onlineProviderSite =
  //       Provider.of<SiteListProvider>(context, listen: false);
  //   final offlineProviderSite =
  //       Provider.of<SiteListProviderOffline>(context, listen: false);
  //   final onlineProviderEquipment =
  //       Provider.of<EquipmentListProvider>(context, listen: false);
  //   final offlineProviderEquipment =
  //       Provider.of<EquipmentOfflineProvider>(context, listen: false);
  //   // final offlineDocument = offlineProvider.documents;
  //   if (isDownloaded == "true") return;

  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       String statusMessage = "Starting download...";
  //       double progress = 0.0;
  //       bool isDownloadStarted = false;

  //       final steps = [
  //         // "Downloading Service Tickets...",
  //         // "Saving Service Tickets...",
  //         "Downloading Customers...",
  //         "Saving Customers...",
  //         "Downloading Items...",
  //         "Saving Items...",
  //         "Downloading Sites...",
  //         "Saving Sites...",
  //         "Downloading Equipment...",
  //         "Saving Equipment...",
  //       ];

  //       return StatefulBuilder(
  //         builder: (statefulContext, setState) {
  //           Future<void> updateStep(int index, String message) async {
  //             setState(() {
  //               statusMessage = message;
  //               progress = (index + 1) / steps.length;
  //             });
  //           }

  //           if (!isDownloadStarted) {
  //             isDownloadStarted = true;
  //             Future.microtask(() async {
  //               try {
  //                 // --- Step 1: Service Tickets ---
  //                 await updateStep(0, steps[0]);
  //                 // await onlineProvider.fetchDocumentTicket(
  //                 //   loadMore: false,
  //                 //   isSetFilter: false,
  //                 //   context: statefulContext,
  //                 // );

  //                 // await updateStep(1, steps[1]);
  //                 // await offlineProvider
  //                 //     .saveDocuments(onlineProvider.documentsTicket);

  //                 // // --- Step 2: Customers ---
  //                 await updateStep(2, steps[2]);
  //                 await onlineProviderCustomer.fetchDocumentOffline(
  //                   loadMore: false,
  //                   isSetFilter: false,
  //                   context: statefulContext,
  //                 );

  //                 await updateStep(3, steps[3]);
  //                 await offlineProviderCustomer
  //                     .saveDocuments(onlineProviderCustomer.documentOffline);

  //                 // --- Step 3: Items ---
  //                 await updateStep(4, steps[4]);
  //                 await onlineProviderItem.fetchDocumentOffline(
  //                   loadMore: false,
  //                   isSetFilter: false,
  //                   context: statefulContext,
  //                 );

  //                 await updateStep(5, steps[5]);
  //                 await offlineProviderItem
  //                     .saveDocuments(onlineProviderItem.documentOffline);

  //                 // --- Step 4: Sites ---
  //                 await updateStep(6, steps[6]);
  //                 await onlineProviderSite.fetchOfflineDocuments(
  //                   loadMore: false,
  //                   isSetFilter: false,
  //                 );

  //                 await updateStep(7, steps[7]);
  //                 await offlineProviderSite
  //                     .saveDocuments(onlineProviderSite.documentOffline);

  //                 // --- Step 5: Equipment ---
  //                 await updateStep(8, steps[8]);
  //                 await onlineProviderEquipment.fetchOfflineDocuments(
  //                   loadMore: false,
  //                   isSetFilter: false,
  //                 );

  //                 await updateStep(9, steps[9]);
  //                 await offlineProviderEquipment
  //                     .saveDocuments(onlineProviderEquipment.documentOffline);

  //                 //All download Done
  //                 await _fetchTicketCounts();
  //                 await LocalStorageManger.setString('isDownloaded', 'true');
  //                 setState(() {
  //                   progress = 1.0;
  //                   isDownloaded = "true";
  //                   statusMessage = "All documents downloaded successfully!";
  //                 });
  //                 await Future.delayed(const Duration(seconds: 1));
  //                 // ✅ Done
  //                 MaterialDialog.close(context);
  //                 MaterialDialog.close(context);

  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     backgroundColor:
  //                         Theme.of(context).colorScheme.inverseSurface,
  //                     behavior: SnackBarBehavior.floating,
  //                     elevation: 10,
  //                     margin: const EdgeInsets.symmetric(
  //                         horizontal: 30, vertical: 15),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(9),
  //                     ),
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 14, vertical: 14),
  //                     content: Row(
  //                       children: [
  //                         // Icon(Icons.remove_circle,
  //                         //     color: Colors.white, size: 28),
  //                         // SizedBox(width: 16),
  //                         Expanded(
  //                           child: Column(
  //                             mainAxisSize: MainAxisSize.min,
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 "✅ All documents downloaded successfully!",
  //                                 style: TextStyle(
  //                                   fontSize:
  //                                       MediaQuery.of(context).size.width *
  //                                           0.033,
  //                                   color: Theme.of(context)
  //                                       .colorScheme
  //                                       .onInverseSurface,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     duration: const Duration(seconds: 4),
  //                   ),
  //                 );
  //               } catch (e) {
  //                 // await offlineProvider.clearDocuments();
  //                 await offlineProviderCustomer.clearDocuments();
  //                 await offlineProviderItem.clearDocuments();
  //                 await offlineProviderEquipment.clearEquipments();
  //                 await offlineProviderSite.clearDocuments();
  //                 await LocalStorageManger.setString('isDownloaded', 'false');
  //                 setState(() {
  //                   isDownloaded = "false";
  //                 });
  //                 await _fetchTicketCounts();
  //                 MaterialDialog.close(context);
  //                 await MaterialDialog.warning(
  //                   context,
  //                   title: "Error",
  //                   body: e.toString(),
  //                 );
  //               }
  //             });
  //           }

  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12)),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.cloud_download,
  //                     size: 40, color: context.colors.tertiary),
  //                 const SizedBox(height: 16),
  //                 LinearProgressIndicator(value: progress),
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   statusMessage,
  //                   style: TextStyle(
  //                       fontSize: MediaQuery.of(context).size.width * 0.032,
  //                       fontWeight: FontWeight.w500),
  //                 ),
  //                 const SizedBox(height: 6),
  //                 Text(
  //                   "${(progress * 100).toStringAsFixed(0)}%",
  //                   style: TextStyle(
  //                       fontSize: 12, color: context.colors.onSurfaceVariant),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  //   setState(() {
  //     load = true;
  //   });
  //   await Future.delayed(const Duration(seconds: 1));
  //   setState(() {
  //     load = false;
  //   });
  // }

  Future<void> clearOfflineData(BuildContext context) async {
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
    if (isDownloaded == "false") return;
    MaterialDialog.warningClearDataDialog(
      context,
      title: 'Clear Data',
      cancelLabel: "Yes",
      onCancel: () async {
        showDialog(
          context: context,
          barrierDismissible: false, // prevent closing by tapping outside
          builder: (_) => Center(
            child: CircularProgressIndicator(
              color: context.colors.primary,
            ),
          ),
        );
        try {
          // Clear service data
          await offlineProviderService.clearDocuments();
          await offlineProviderServiceCustomer.clearDocuments();
          await offlineProviderServiceItem.clearDocuments();
          await offlineProviderEquipment.clearEquipments();
          await offlineProviderSite.clearDocuments();
          await _fetchTicketCounts();

          // Hide loading popup
          // Navigator.of(context).pop();

          // // Show success message
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Offline data cleared successfully!")),
          // );
          MaterialDialog.close(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              behavior: SnackBarBehavior.floating,
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              content: Row(
                children: [
                  Icon(Icons.remove_circle,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Offline data cleared successfully!.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          // ✅ Close drawer
          await LocalStorageManger.setString('isDownloaded', 'false');
          setState(() {
            isDownloaded = "false";
          });
          Navigator.of(context).pop();
        } catch (e) {
          // Hide loading popup
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to clear data: $e")),
          );
        }
      },
    );
    // Show loading popup
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
      await LocalStorageManger.setString('isDownloaded', 'false');
      setState(() {
        isDownloaded = "false";
      });
    } catch (e) {
      // Hide loading popup

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
    // Show loading popup
  }

  Future<dynamic> syncAllProcessToSAP() async {
    MaterialDialog.loading(context);

    try {
      final res1 =
          await Provider.of<CompletedServiceProvider>(context, listen: false)
              .syncAllOfflineServicesToSAP(context);
      // Sync Equipment Data
      final res2 =
          await Provider.of<EquipmentCreateProvider>(context, listen: false)
              .syncAllOfflineEquipmentToSAP(context);
      if (res1 == false && res2 == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            content: Row(
              children: [
                Icon(Icons.remove_circle,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No offline data to synchronize.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        MaterialDialog.close(context);
        MaterialDialog.close(context);
        return;
      }
      MaterialDialog.close(context);
      await MaterialDialog.allSyncSuccess(context);
      return true;
    } catch (e) {
      // Hide loading popup
      Navigator.of(context).pop();
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
      return false;
    }

    // Show loading popup
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: Color.fromARGB(255, 66, 83, 100),
        //   elevation: 0,
        //   centerTitle: true,
        //   title: Text(
        //     'Dashboard',
        //     style: GoogleFonts.inter(
        //         fontSize: 18,
        //         fontWeight: FontWeight.w700,
        //         color: context.colors.onPrimary),
        //   ),
        //   actions: [
        //     if (_isSyncing)
        //       Padding(
        //         padding: const EdgeInsets.only(right: 12),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             SizedBox(
        //               width: 16,
        //               height: 16,
        //               child: CircularProgressIndicator(
        //                 strokeWidth: 2,
        //                 valueColor: AlwaysStoppedAnimation<Color>(
        //                   Colors.greenAccent,
        //                 ),
        //               ),
        //             ),
        //             const SizedBox(width: 8),
        //             Text(
        //               "Syncing...",
        //               style: GoogleFonts.inter(
        //                 fontSize: 12,
        //                 fontWeight: FontWeight.w500,
        //                 color: Colors.white,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //   ],
        //   bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(55.0),
        //     child: Container(
        //       color: Colors.white,
        //       child: Stack(
        //         children: [
        //           // ✅ TabBar
        //           TabBar(
        //             controller: _tabController,
        //             indicator: const CustomTabIndicator(
        //               indicatorWidth: 70,
        //               indicatorHeight: 3,
        //               color: Colors.green,
        //             ),
        //             indicatorSize: TabBarIndicatorSize.label,
        //             tabs: [
        //               Tab(
        //                 child: Text(
        //                   "Tickets",
        //                   style: TextStyle(
        //                     fontSize: MediaQuery.of(context).size.width * 0.036,
        //                     color: const Color.fromARGB(255, 62, 62, 67),
        //                   ),
        //                 ),
        //               ),
        //               Tab(
        //                 child: Text(
        //                   "KPI",
        //                   style: TextStyle(
        //                     fontSize: MediaQuery.of(context).size.width * 0.036,
        //                     color: const Color.fromARGB(255, 62, 62, 67),
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),

        //           // ✅ Divider line in center
        //           Container(
        //             margin: const EdgeInsets.only(top: 7),
        //             child: Align(
        //               alignment: Alignment.center,
        //               child: Container(
        //                 width: 1,
        //                 height: 30,
        //                 color: Colors.grey.shade400,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _ticketTab(),
            _kpiTab(),
          ],
        ),
      ),
    );
  }

  /// Ticket Tab
  /// Ticket Tab
  Widget _ticketTab() {
    return Column(
      children: [
        // 🔹 Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Filter Button
              InkWell(
                onTap: _showFilterDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list_rounded,
                          size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        "Filters",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Vertical Divider
              Container(
                height: 24,
                width: 1,
                color: context.colors.outlineVariant,
              ),
              const SizedBox(width: 10),

              // Active Filters List
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedJob == "All" &&
                          _jobClass == "All" &&
                          _selectedPriority == "All")
                        Text(
                          "All Tickets Shown",
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      if (_selectedJob != "All") ...[
                        _buildFilterChip("JobType: $_selectedJob", () {
                          setState(() {
                            _selectedJob = "All";
                          });
                          _fetchTicketCounts();
                        }),
                        const SizedBox(width: 8),
                      ],
                      if (_jobClass != "All") ...[
                        _buildFilterChip("JobClass: $_jobClass", () {
                          setState(() {
                            _jobClass = "All";
                          });
                          _fetchTicketCounts();
                        }),
                        const SizedBox(width: 8),
                      ],
                      if (_selectedPriority != "All") ...[
                        _buildFilterChip("Priority: $_selectedPriority", () {
                          setState(() {
                            _selectedPriority = "All";
                          });
                          _fetchTicketCounts();
                        }),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🔹 Ticket list
        // _isSyncing == true
        //     ? SizedBox(
        //         height: 550,
        //         child: Center(
        //             child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             SpinKitFadingCircle(
        //               color: Colors.green,
        //               size: 45.0,
        //             ),
        //             SizedBox(
        //               height: 20,
        //             ),
        //             Text(
        //               "Loading...",
        //               style: TextStyle(fontSize: 17),
        //             ),
        //           ],
        //         )),
        //       )
        //     :
        Expanded(
          // <<< Fix: constrain ListView inside Column
          child: ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: ticketGroups.length,
            itemBuilder: (context, index) {
              final group = ticketGroups[index];
              final tickets = group["tickets"] as List;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 239, 239, 242),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      child: Icon(Icons.date_range,
                          color: context.colors.onPrimaryContainer),
                    ),
                    title: Row(
                      children: [
                        Text(
                          group["date"],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 15),
                        group["isLoadingCount"] == true
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.colors.primary,
                              )
                            : Container()
                      ],
                    ),
                    subtitle: Text(
                      "Tickets:  ${group["isLoadingCount"] == true ? "fetching..." : group["count"]}",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: MediaQuery.of(context).size.width * 0.031),
                    ),
                    // ✅ custom right icon
                    // ✅ custom rotating arrow
                    // trailing: AnimatedRotation(
                    //   turns: _isExpanded
                    //       ? 0.5
                    //       : 0.0, // 0.5 = 180°, 0.25 = 90°
                    //   duration: const Duration(milliseconds: 200),
                    //   child: const Icon(
                    //     Icons.keyboard_arrow_down,
                    //     color: Theme.of(context).colorScheme.onSurfaceVariant,
                    //   ),
                    // ),

                    onExpansionChanged: (expanded) async {
                      setState(() {
                        _isExpanded = expanded;
                      });
                      if (expanded && tickets.isEmpty) {
                        setState(() {
                          group["tickets"] = ["loading"];
                          _isExpanded = expanded;
                          print(expanded);
                        });
                        final fetchedTickets =
                            await _fetchTicketsFromOffline(group["dateValue"]);
                        setState(() {
                          group["tickets"] = fetchedTickets;
                        });
                      }
                    },
                    childrenPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    children: tickets.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "No tickets available!",
                                style: TextStyle(
                                    color: context.colors.onSurfaceVariant,
                                    fontSize: 13),
                              ),
                            )
                          ]
                        : tickets.isNotEmpty && tickets[0] == "loading"
                            ? [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Center(
                                        child: SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Loading ${group["date"]}' Ticket...",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              ]
                            : (() {
                                // clone + sort safely
                                final sortedTickets = [...tickets]
                                  ..sort((a, b) {
                                    final docNumA = a['DocNum'] ?? 0;
                                    final docNumB = b['DocNum'] ?? 0;
                                    return docNumB.compareTo(docNumA); // DESC
                                  });

                                return sortedTickets
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final ticket = entry.value;
                                  return _cardTicket(ticket, index);
                                }).toList();
                              })(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.colors.secondaryContainer.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: context.colors.secondary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.cancel_rounded,
              size: 16,
              color: context.colors.onSecondaryContainer.withOpacity(0.6),
            )
          ],
        ),
      ),
    );
  }

  /// KPI Tab
  Widget _kpiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              _kpiCard("Monthly Closed Tickets", "0", context.colors.error),
              const SizedBox(width: 12),
              _kpiCard(
                  "Yearly In-Service Rate", "100%", context.colors.primary),
            ],
          ),
          const SizedBox(height: 20),
          _listCard("My Top 5 Fixed Items", []),
          const SizedBox(height: 20),
          _listCard("My Top 5 Visited Customers", []),
          const SizedBox(height: 20),
          _listCard("Monthly Closed Tickets", []),
        ],
      ),
    );
  }

  Widget _cardTicket(dynamic data, int index) {
    final status = data["U_CK_Status"] ?? "N/A";
    final docNum = data["DocNum"] ?? data["id"] ?? "N/A";
    final customerName = data["CustomerName"] ?? "Unknown Customer";
    final jobType = data["U_CK_JobType"] ?? "Service";
    final dateStr = data["U_CK_Date"]?.split("T")[0] ?? "";
    final startTime = data["U_CK_Time"] ?? "--:--";
    final endTime = data["U_CK_EndTime"] ?? "--:--";

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (status == "Completed" || status == "Rejected") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(
                      data: data as Map<String, dynamic>,
                      isCompleted: status == "Rejected" ? false : true),
                ),
              ).then((value) => _fetchTicketCounts());
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ServiceByIdScreen(data: data as Map<String, dynamic>),
              ),
            ).then((value) => _fetchTicketCounts());
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Doc Num, Job Type, and Status
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "#$docNum",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE047)),
                      ),
                      child: Text(
                        jobType.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    if (status == "Completed") ...[
                      _buildSyncIcon(data["sync_status"] ??
                          context
                              .read<ServiceListProviderOffline>()
                              .getSyncStatus(data['DocEntry'])),
                      SizedBox(width: 2.w),
                    ],
                    const Spacer(),
                    _buildStatusBadge(status),
                  ],
                ),
              ),

              // Customer Info Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14.sp, color: Colors.blueAccent),
                        SizedBox(width: 1.5.w),
                        Expanded(
                          child: Text(
                            ((data["CustomerAddress"] as List?)?.isNotEmpty ==
                                    true)
                                ? "${data["CustomerAddress"].first["StreetNo"] ?? "No Street Address"}"
                                : "No Address Available",
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),

              // Date & Time Footer
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoLabel("DATE"),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 14.sp, color: const Color(0xFF64748B)),
                              SizedBox(width: 1.5.w),
                              Text(
                                showDateOnService(dateStr),
                                style: GoogleFonts.inter(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 3.5.h,
                      width: 1,
                      color: const Color(0xFFF1F5F9),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoLabel("SCHEDULED"),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 14.sp, color: const Color(0xFF64748B)),
                              SizedBox(width: 1.5.w),
                              Text(
                                "$startTime - $endTime",
                                style: GoogleFonts.inter(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncIcon(String? syncStatus) {
    final bool isSynced = syncStatus == 'synced';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSynced ? Icons.cloud_done_rounded : Icons.cloud_upload_rounded,
          size: 17.sp,
          color: isSynced
              ? const Color(0xFF166534)
              : const Color.fromARGB(255, 242, 26, 26),
        ),
      ],
    );
  }

  Widget _buildInfoLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status) {
      case "Pending":
      case "Open":
        color = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        break;
      case "Accept":
        color = const Color(0xFF0D9488);
        bgColor = const Color(0xFFF0FDFA);
        break;
      case "Travel":
        color = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFEFF6FF);
        break;
      case "Service":
        color = const Color(0xFF9333EA);
        bgColor = const Color(0xFFFAF5FF);
        break;
      case "Completed":
        color = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        break;
      default:
        color = const Color(0xFF64748B);
        bgColor = const Color(0xFFF8FAFC);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status == "Completed" ? "COMPLETED" : status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up, // Or dynamic logic
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listCard(String title, List<String> items) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              "No data available",
              style: TextStyle(
                  color: context.colors.onSurfaceVariant, fontSize: 14),
            )
          else
            Column(
              children: items
                  .map(
                    (item) => ListTile(
                      title: Text(item),
                      leading: const Icon(Icons.check_circle_outline),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class CustomTabIndicator extends Decoration {
  final double indicatorWidth;
  final double indicatorHeight;
  final Color color;

  const CustomTabIndicator({
    this.indicatorWidth = 40,
    this.indicatorHeight = 3,
    required this.color,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(this, onChanged);
  }
}

class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;

  _CustomPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;

    final double xCenter =
        offset.dx + (config.size!.width / 2) - (decoration.indicatorWidth / 2);
    final double yBottom = offset.dy + config.size!.height;

    final Rect rect = Rect.fromLTWH(
      xCenter,
      yBottom - decoration.indicatorHeight,
      decoration.indicatorWidth,
      decoration.indicatorHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );
  }
}
