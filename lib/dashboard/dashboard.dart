import 'dart:convert';

import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/screens/equipment/equipment_list.dart';
import 'package:bizd_tech_service/screens/service/service.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final DioClient _dio = DioClient(); // Your custom Dio client
  bool load = false;
  String _selectedJob = "All"; // All, Open, Closed
  String _selectedService = "All"; // All, Open, Closed
  String _selectedPriority = "All"; // All, High, Medium, Low

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _tabController = TabController(length: 2, vsync: this);
    _initTicketDates();
    _fetchTicketCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isExpanded = false; // add this in your State

  Future<void> _loadUserName() async {
    final name = await LocalStorageManger.getString('FullName');
    setState(() {
      userName = name;
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
  Future<void> _fetchTicketCounts() async {
    setState(() {
      load = true; // hide loading after all counts fetched
    });
    // optional small delay before hiding overall loading
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      load = false; // hide loading after all counts fetched
    });
    for (var group in ticketGroups) {
      final dateValue = group["dateValue"];
      setState(() {
        group["isLoadingCount"] = true; // show loading
        group["tickets"] = []; // clear cached tickets
      });
      String filter = "U_CK_Date eq '$dateValue'";

      if (_selectedJob != "All") {
        filter += " and U_CK_JobType eq '$_selectedJob'";
      }

      if (_selectedService != "All") {
        filter += " and U_CK_ServiceType eq '$_selectedService'";
      }
      if (_selectedPriority != "All") {
        filter += " and U_CK_Priority eq '$_selectedPriority'";
      }

      try {
        final response =
            await _dio.get("/CK_JOBORDER/\$count?\$filter=$filter");
        setState(() {
          group["count"] = response.data;
          group["isLoadingCount"] = false; // hide loading
        });
      } catch (e) {
        setState(() {
          group["count"] = 0;
          group["isLoadingCount"] = false; // hide loading
          group["tickets"] = []; // also clear on error
        });
        debugPrint("Error fetching count for $dateValue: $e");
      }
    }
  }

  /// Fetch ticket details per date from SAP
  // Future<List<Map<String, String>>> _fetchTicketsFromApi(String date) async {
  //   try {
  //     final response = await _dio.get(
  //       "/CK_JOBORDER?\$filter=U_CK_Date eq '$date'",
  //     );

  //     final List data = response.data["value"] ?? [];
  //     return data.map<Map<String, String>>((item) {
  //       return {
  //         "id": item["DocEntry"].toString(),
  //         "title": item["U_CK_JobName"] ?? "No Title",
  //         "status": item["U_CK_Status"] ?? "Open",
  //       };
  //     }).toList();
  //   } catch (e) {
  //     debugPrint("Error fetching tickets for $date: $e");
  //     return [];
  //   }
  // }

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
                  const Text("Matches Your Filter",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          label: Text(jType),
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
                          label: Text(serice),
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
                          label: Text(priority),
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
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
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
                          backgroundColor: const Color.fromARGB(
                              255, 66, 83, 100), // button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(7), // rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 5), // optional
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white), // text color
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

  Future<List<Map<String, String>>> _fetchTicketsFromApi(String date) async {
    try {
      String filter = "U_CK_Date eq '$date'";

      if (_selectedJob != "All") {
        filter += " and U_CK_JobType eq '$_selectedJob'";
      }

      if (_selectedService != "All") {
        filter += " and U_CK_ServiceType eq '$_selectedService'";
      }
      if (_selectedPriority != "All") {
        filter += " and U_CK_Priority eq '$_selectedPriority'";
      }

      final response = await _dio.get(
        "/CK_JOBORDER?\$filter=$filter",
      );

      final List data = response.data["value"] ?? [];
      return data.map<Map<String, String>>((item) {
        return {
          "id": item["DocEntry"].toString(),
          "title": item["U_CK_JobName"] ?? "No Title",
          "status": item["U_CK_Status"] ?? "Open",
          "priority": item["U_CK_Priority"] ?? "Low",
        };
      }).toList();
    } catch (e) {
      debugPrint("Error fetching tickets for $date: $e");
      return [];
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Open":
        return Colors.redAccent;
      case "In Progress":
        return Colors.orangeAccent;
      case "Closed":
        return Colors.green;
      case "Pending":
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildDrawerItem(
      IconData icon, String title, int index, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  Future<void> downloadAllDocuments(BuildContext context) async {
    final onlineProvider =
        Provider.of<ServiceListProvider>(context, listen: false);
    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String statusMessage = "Starting download...";

        bool isDownloadStarted = false;

        return StatefulBuilder(
          builder: (statefulContext, setState) {
            if (!isDownloadStarted) {
              isDownloadStarted = true;
              Future.microtask(() async {
                try {
                  // --- Download Services ---
                  setState(() {
                    statusMessage = "Downloading Services...";
                  });
                  await onlineProvider.fetchDocuments(
                    loadMore: false,
                    isSetFilter: false,
                    context: statefulContext,
                  );
                  setState(() {
                    statusMessage = "Saving Services to offline storage...";
                  });
                  await offlineProvider.saveDocuments(onlineProvider.documents);

                  await Future.delayed(
                      const Duration(milliseconds: 500)); // Brief pause

                  // --- Download Service Tickets ---
                  // setState(() {
                  //   statusMessage = "Downloading Service Tickets...";
                  // });
                  // await onlineProvider.fetchDocumentTicket(
                  //   loadMore: false,
                  //   isSetFilter: false,
                  //   context: statefulContext,
                  // );
                  // setState(() {
                  //   statusMessage =
                  //       "Saving Service Tickets to offline storage...";
                  // });
                  // await offlineProvider
                  //     .saveDocuments(onlineProvider.documentsTicket);

                  await Future.delayed(
                      const Duration(milliseconds: 500)); // Brief pause

                  // Download complete
                  ScaffoldMessenger.of(statefulContext).showSnackBar(
                    const SnackBar(
                        content:
                            Text("All documents downloaded successfully!")),
                  );
                  print(offlineProvider.documents);
                } catch (e) {
                  // Download failed
                  ScaffoldMessenger.of(statefulContext).showSnackBar(
                    SnackBar(content: Text("Failed to download: $e")),
                  );
                } finally {
                  // Ensure the dialog is popped only once
                  if (Navigator.of(dialogContext).canPop()) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              });
            }

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(statusMessage),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> clearOfflineData(BuildContext context) async {
    final offlineProviderService =
        Provider.of<ServiceListProviderOffline>(context, listen: false);
    final offlineProviderServiceTicket =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    try {
      // Clear service data
      await offlineProviderService.clearDocuments();

      // Clear service ticket data
      await offlineProviderServiceTicket.clearDocuments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offline data cleared successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Center(
          child: GestureDetector(
            onTap: () async {
              final offlineProvider = Provider.of<ServiceListProviderOffline>(
                  context,
                  listen: false);

              // Load documents from Hive first
              await offlineProvider.loadDocuments();

              print("Offline documents:");
              for (var doc in offlineProvider.documents) {
                print(doc);
              }
            },
            child: const Text(
              'Bizd Service Mobile',
              style: TextStyle(fontSize: 17, color: Colors.white),
              textScaleFactor: 1.0,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedJob = "All"; // All, Open, Closed
                _selectedService = "All"; // All, Open, Closed
                _selectedPriority = "All"; // All, High, Medium, Low
              });

              _fetchTicketCounts();
            },
          ),
        ],
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
                  tabs: const [
                    Tab(
                      child: Text(
                        "Tickets",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 62, 62, 67),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "KPI",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 62, 62, 67),
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
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 66, 83, 100)),
              currentAccountPicture: SvgPicture.asset(
                'images/svg/key.svg',
                color: const Color.fromARGB(255, 49, 134, 69),
                fit: BoxFit.contain,
              ),
              accountName: Text(
                userName ?? '...',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text(
                'George_Keeng88@gmail.com',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                      Icons.settings, "Service", 0, const ServiceScreen()),
                  _buildDrawerItem(
                      Icons.build, "Equipment", 1, const EquipmentListScreen()),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.black54),
              title: const Text("Download"),
              onTap: () async {
                downloadAllDocuments(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.black54),
              title: const Text("Clear"),
              onTap: () async {
                clearOfflineData(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black54),
              title: const Text("Log out"),
              onTap: () async {
                MaterialDialog.loading(context);
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
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
  Widget _ticketTab() {
    return Column(
      children: [
        // 🔹 Filter bar
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  "Job: $_selectedJob | Service: $_selectedService | Priority: $_selectedPriority",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _showFilterDialog,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 0),
                  height: 30,
                  child: const Icon(Icons.filter_alt, color: Colors.green),
                ),
              )
            ],
          ),
        ),

        // 🔹 Ticket list
        load == true
            ? const SizedBox(
                height: 550,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.green,
                      ),
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
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                            backgroundColor: Colors.indigo[50],
                            child: const Icon(Icons.date_range,
                                color: Color.fromARGB(255, 76, 99, 122)),
                          ),
                          title: Row(
                            children: [
                              Text(
                                group["date"],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 15),
                              group["isLoadingCount"] == true
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.green,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          subtitle: Text(
                            "Tickets:  ${group["isLoadingCount"] == true ? "fetching..." : group["count"]}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          // ✅ custom right icon
                          // ✅ custom rotating arrow
                          trailing: AnimatedRotation(
                            turns: _isExpanded
                                ? 0.5
                                : 0.0, // 0.5 = 180°, 0.25 = 90°
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ),

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
                              final fetchedTickets = await _fetchTicketsFromApi(
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
                                  const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "No tickets available!",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  )
                                ]
                              : tickets[0] == "loading"
                                  ? [
                                      Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Center(
                                                child: SizedBox(
                                                    width: 21,
                                                    height: 21,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.green,
                                                    ))),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Loading ${group["date"]}' Ticket...",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      )
                                    ]
                                  : tickets.map<Widget>((ticket) {
                                      return _cardTicket(ticket, Colors.red);
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

  /// KPI Tab
  Widget _kpiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              _kpiCard("Monthly Closed Tickets", "0", Colors.redAccent),
              const SizedBox(width: 12),
              _kpiCard("Yearly In-Service Rate", "100%", Colors.green),
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

  Widget _cardTicket(dynamic data, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      padding: const EdgeInsets.fromLTRB(0, 6.5, 10, 10),
      decoration: BoxDecoration(
        border: const Border(
          left: BorderSide(
            color: Color.fromARGB(255, 66, 83, 100),
            width: 8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 133, 136, 138).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ],
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings,
                              size: 19,
                              color: Color.fromARGB(255, 188, 189, 190)),
                          SizedBox(width: 3),
                          Text(
                            "Ticket - No. 1",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Corrective Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37), // Gold yellow
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "Corrective",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Entry Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50), // Green
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              "Entry",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ✅ Item code & model row
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 21,
                            color: Colors.blue, // you can change the color
                          ),
                          SizedBox(width: 5), // spacing between icon and text
                          Text(
                            "1000098 - John Sey",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaleFactor: 1.0,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 7.5),

                  // ✅ Brand & part row
                  Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: const Text(
                          "# / 23, Street 872 - Khan Sen Sok phnom Penh",
                          // maxLines: 1,
                          // overflow:
                          //     TextOverflow
                          //         .ellipsis,
                          softWrap: true,
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 12.5),
                        ),
                      )),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 9, 10, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 85,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Service Type",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 133, 134, 137),
                                        fontSize: 13),
                                  ),
                                  Text(
                                    ":",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 133, 134, 137),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              " Breakdown",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1.0,
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(
                              width: 85,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Priority",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 133, 134, 137),
                                        fontSize: 13),
                                  ),
                                  Text(
                                    ":",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 133, 134, 137),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              " High",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white, // same as Card background
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // soft shadow
              blurRadius: 4,
              offset: const Offset(0, 2), // subtle elevation
            ),
          ],
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  color: color,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
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
            color: Colors.black.withOpacity(0.1),
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
            const Text(
              "No data available",
              style: TextStyle(color: Colors.grey, fontSize: 14),
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
    this.color = Colors.green,
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
