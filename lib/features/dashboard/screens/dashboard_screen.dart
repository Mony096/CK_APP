import 'dart:convert';

import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
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
import 'package:bizd_tech_service/features/equipment/screens/equipment_list.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/core/extensions/theme_extensions.dart';
import 'package:bizd_tech_service/core/theme/app_tokens.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String _selectedService = "All"; // All, Open, Closed
  String _selectedPriority = "All"; // All, High, Medium, Low
  List<dynamic> documentOffline = [];
  List<dynamic> completedService = [];
  String isDownloaded = "false";
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);
      // ✅ Make sure documents are loaded
      await offlineProvider.loadDocuments();

      // ✅ Replace the list instead of addAll
      setState(() {
        documentOffline = List.from(offlineProvider.documents);
        completedService = List.from(offlineProvider.completedServices);
      });

      // ✅ Fetch ticket counts after docs are loaded
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
    setState(() {
      userName = name;
      isDownloaded = isDownLoadDone;
    });
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

  //     if (_selectedService != "All") {
  //       filter += " and U_CK_ServiceType eq '$_selectedService'";
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
        if (_selectedService != "All") {
          match = match && doc["U_CK_ServiceType"] == _selectedService;
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
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        load = false; // hide overall loading
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Matches Your Filter",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.043,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Status filter
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("Job Type")),
                  Container(
                    margin: const EdgeInsets.only(right: 45),
                    child: Wrap(
                      spacing: 5,
                      children: ["All", "Corrective", "Preventve"].map((jType) {
                        return ChoiceChip(
                          label: Text(jType,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.034,
                              )),
                          selected: _selectedJob == jType,
                          onSelected: (_) {
                            setModalState(() {
                              _selectedJob = jType;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority filter
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Service Type")),
                  Container(
                    margin: const EdgeInsets.only(left: 0),
                    child: Wrap(
                      spacing: 5,
                      children: [
                        "All",
                        "Breakdown",
                        "Emergency",
                        "Installation",
                        "Overhaul",
                        "Maintenance"
                      ].map((serice) {
                        return ChoiceChip(
                          label: Text(serice,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.034,
                              )),
                          selected: _selectedService == serice,
                          onSelected: (_) {
                            setModalState(() {
                              _selectedService = serice;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority filter
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("Priority")),
                  Container(
                    margin: const EdgeInsets.only(right: 30),
                    child: Wrap(
                      spacing: 5,
                      children:
                          ["All", "High", "Medium", "Low"].map((priority) {
                        return ChoiceChip(
                          label: Text(priority,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.034,
                              )),
                          selected: _selectedPriority == priority,
                          onSelected: (_) {
                            setModalState(() {
                              _selectedPriority = priority;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedJob = "All";
                            _selectedService = "All";
                            _selectedPriority = "All";
                          });
                          _fetchTicketCounts();

                          Navigator.pop(context);
                        },
                        child: Text(
                          "Reset",
                          style: TextStyle(
                              fontSize: 15,
                              color: context.colors.error,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // refresh tickets with filter
                          _fetchTicketCounts();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer, // button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(7), // rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 5), // optional
                        ),
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer), // text color
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Future<List<Map<String, String>>> _fetchTicketsFromApi(String date) async {
  //   try {
  //     String filter = "U_CK_Date eq '$date'";

  //     if (_selectedJob != "All") {
  //       filter += " and U_CK_JobType eq '$_selectedJob'";
  //     }

  //     if (_selectedService != "All") {
  //       filter += " and U_CK_ServiceType eq '$_selectedService'";
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
  Future<List<Map<String, String>>> _fetchTicketsFromOffline(
      String date) async {
    try {
      final offlineProvider =
          Provider.of<ServiceListProviderOffline>(context, listen: false);

      // Make sure documents are loaded
      await offlineProvider.loadDocuments();
      print(offlineProvider.documents);
      // Filter offline documents
      final filteredDocs = offlineProvider.documents.where((doc) {
        bool match = doc["U_CK_Date"] == '${date}T00:00:00Z';

        if (_selectedJob != "All") {
          match = match && doc["U_CK_JobType"] == _selectedJob;
        }
        if (_selectedService != "All") {
          match = match && doc["U_CK_ServiceType"] == _selectedService;
        }
        if (_selectedPriority != "All") {
          match = match && doc["U_CK_Priority"] == _selectedPriority;
        }

        return match;
      }).toList();

      // Map to the same format as your API
      return filteredDocs.map<Map<String, String>>((item) {
        return {
          "id": item["DocEntry"].toString(),
          "title": item["U_CK_JobName"] ?? "No Title",
          "status": item["U_CK_Status"] ?? "Open",
          "priority": item["U_CK_Priority"] ?? "Low",
        };
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 66, 83, 100),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.onPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55.0),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                // ✅ TabBar
                TabBar(
                  controller: _tabController,
                  indicator: const CustomTabIndicator(
                    indicatorWidth: 70,
                    indicatorHeight: 3,
                    color: Colors.green,
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      child: Text(
                        "Tickets",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                          color: const Color.fromARGB(255, 62, 62, 67),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "KPI",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                          color: const Color.fromARGB(255, 62, 62, 67),
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ Divider line in center
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ticketTab(),
          _kpiTab(),
        ],
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
                          _selectedService == "All" &&
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
                        _buildFilterChip("Job: $_selectedJob", () {
                          setState(() {
                            _selectedJob = "All";
                          });
                          _fetchTicketCounts();
                        }),
                        const SizedBox(width: 8),
                      ],
                      if (_selectedService != "All") ...[
                        _buildFilterChip("Svc: $_selectedService", () {
                          setState(() {
                            _selectedService = "All";
                          });
                          _fetchTicketCounts();
                        }),
                        const SizedBox(width: 8),
                      ],
                      if (_selectedPriority != "All") ...[
                        _buildFilterChip("Pri: $_selectedPriority", () {
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
        load == true
            ? SizedBox(
                height: 550,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   SpinKitFadingCircle(
                        color: Colors.green,
                        size: 45.0,
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Loading...",
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                )),
              )
            : Expanded(
                // <<< Fix: constrain ListView inside Column
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ticketGroups.length,
                  itemBuilder: (context, index) {
                    final group = ticketGroups[index];
                    final tickets = group["tickets"] as List;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: const Color.fromARGB(255, 233, 233, 235),
                          width: 1,
                        ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Theme.of(context)
                        //         .colorScheme
                        //         .onSurface
                        //         .withOpacity(0.08),
                        //     blurRadius: 4,
                        //     offset: const Offset(0, 2),
                        //   ),
                        // ],
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
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
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.031),
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
                                  await _fetchTicketsFromOffline(
                                      group["dateValue"]);
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
                                          color:
                                              context.colors.onSurfaceVariant,
                                          fontSize: 13),
                                    ),
                                  )
                                ]
                              : tickets[0] == "loading"
                                  ? [
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Center(
                                                child: SizedBox(
                                                    width: 21,
                                                    height: 21,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: context
                                                          .colors.primary,
                                                    ))),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Loading ${group["date"]}' Ticket...",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: context
                                                    .colors.onSurfaceVariant),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      )
                                    ]
                                  : tickets.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final ticket = entry.value;

                                      return _cardTicket(ticket, index);
                                    }).toList(),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.colors.secondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.colors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 14,
              color: context.colors.onSecondaryContainer.withOpacity(0.7),
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
    // Determine status color
    Color statusColor;
    Color statusBgColor;
    String status = data["U_CK_Status"] ?? "N/A";

    switch (status) {
      case "Open":
        statusColor = context.colors.error;
        statusBgColor = context.colors.errorContainer;
        break;
      case "Service":
      case "Travel":
      case "Entry":
      case "Accept":
        statusColor = const Color(0xFF2E7D32); // Green 800
        statusBgColor = const Color(0xFFE8F5E9); // Green 50
        break;
      default:
        statusColor = context.colors.primary;
        statusBgColor = context.colors.primaryContainer;
    }

    // Determine Job Type color (Corrective/Preventive)
    Color jobTypeColor = const Color(0xFF1565C0); // Blue 800
    Color jobTypeBgColor = const Color(0xFFE3F2FD); // Blue 50
    if (data["U_CK_JobType"] == "Preventive") {
      jobTypeColor = const Color(0xFFE65100); // Orange 900
      jobTypeBgColor = const Color(0xFFFFF3E0); // Orange 50
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 249, 250, 250),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to Detail Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ServiceByIdScreen(data: data as Map<String, dynamic>),
              ),
            ).then((value) => _fetchTicketCounts());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ticket ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.confirmation_number_outlined,
                              size: 16, color: context.colors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Ticket #${index + 1}",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == "Entry" ? "Completed" : status,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Customer Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.business_rounded,
                        size: 20, color: context.colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["CustomerName"] ?? "Unknown Customer",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${data["U_CK_CardCode"] ?? "N/A"}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: context.colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ((data["CustomerAddress"] as List?)?.isNotEmpty == true)
                            ? "${data["CustomerAddress"].first["StreetNo"] ?? "No Street Address"}"
                            : "No Address Available",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: context.colors.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(
                    height: 1,
                    color: context.colors.outlineVariant.withOpacity(0.5)),
                const SizedBox(height: 12),

                // Footer: Job Type, Service Type, Priority
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(
                      label: data["U_CK_JobType"] ?? "N/A",
                      color: jobTypeColor,
                      bgColor: jobTypeBgColor,
                    ),
                    _buildTag(
                      label: data["U_CK_ServiceType"] ?? "Service",
                      color: context.colors.tertiary,
                      bgColor:
                          context.colors.tertiaryContainer.withOpacity(0.4),
                    ),
                    if (data["U_CK_Priority"] != null)
                      _buildTag(
                        label: "${data["U_CK_Priority"]}",
                        color: data["U_CK_Priority"] == "High"
                            ? context.colors.error
                            : context.colors.secondary,
                        bgColor: data["U_CK_Priority"] == "High"
                            ? context.colors.errorContainer
                            : context.colors.secondaryContainer,
                        icon: Icons.flag_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
    required Color bgColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
