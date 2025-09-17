import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
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
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      load = false; // hide loading after all counts fetched
    });
    for (var group in ticketGroups) {
      final dateValue = group["dateValue"];
      setState(() {
        group["isLoadingCount"] = true; // show loading
        group["tickets"] = []; // clear cached tickets
      });

      try {
        final response = await _dio
            .get("/CK_JOBORDER/\$count?\$filter=U_CK_Date eq '$dateValue'");
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
  String _selectedStatus = "All"; // All, Open, Closed
  String _selectedPriority = "All"; // All, High, Medium, Low

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
                  const Text("Filter",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Status filter
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("Status")),
                  Wrap(
                    spacing: 10,
                    children: ["All", "Open", "Closed"].map((status) {
                      return ChoiceChip(
                        label: Text(status),
                        selected: _selectedStatus == status,
                        onSelected: (_) {
                          setModalState(() {
                            _selectedStatus = status;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Priority filter
                  const Align(
                      alignment: Alignment.centerLeft, child: Text("Priority")),
                  Wrap(
                    spacing: 10,
                    children: ["All", "High", "Medium", "Low"].map((priority) {
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
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = "All";
                            _selectedPriority = "All";
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {}); // refresh tickets with filter
                          Navigator.pop(context);
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
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

      if (_selectedStatus != "All") {
        filter += " and U_CK_Status eq '$_selectedStatus'";
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
        title: const Center(
          child: Text(
            'Bizd Service Mobile',
            style: TextStyle(fontSize: 17, color: Colors.white),
            textScaleFactor: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _selectedStatus = "All"; // All, Open, Closed
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
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.green,
                    width: 3.0,
                  ),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(
                  child: Text(
                    "Ticket",
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 62, 62, 67)),
                  ),
                ),
                Tab(
                  child: Text(
                    "KPI",
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 62, 62, 67)),
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
    return load == true
        ? Text("Loading")
        : Column(
            children: [
              // 🔹 Filter bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
                        "Status: $_selectedStatus  |  Priority: $_selectedPriority",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.green),
                      onPressed: () {
                        _showFilterDialog(); // call your bottom sheet
                      },
                    ),
                  ],
                ),
              ),

              // 🔹 Ticket list
              Expanded(
                // <<< Fix: constrain ListView inside Column
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ticketGroups.length,
                  itemBuilder: (context, index) {
                    final group = ticketGroups[index];
                    final tickets = group["tickets"] as List;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
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
                            child: const Icon(Icons.event_note,
                                color: Colors.indigo),
                          ),
                          title: Row(
                            children: [
                              Text(
                                group["date"],
                                style: const TextStyle(
                                  fontSize: 15,
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
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onExpansionChanged: (expanded) async {
                            if (expanded && tickets.isEmpty) {
                              setState(() {
                                group["tickets"] = ["loading"];
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
                                      style: TextStyle(color: Colors.grey),
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
                                                    width: 23,
                                                    height: 23,
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
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons
                                                    .confirmation_number_outlined,
                                                color: Colors.blue),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    ticket["title"],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "ID: ${ticket["id"]}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                ticket["status"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              backgroundColor: _statusColor(
                                                  ticket["status"]),
                                            ),
                                          ],
                                        ),
                                      );
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

  Widget _kpiCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listCard(String title, List<String> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text("No data available",
                  style: TextStyle(color: Colors.grey))
            else
              Column(
                children: items
                    .map((item) => ListTile(
                          title: Text(item),
                          leading: const Icon(Icons.check_circle_outline),
                        ))
                    .toList(),
              )
          ],
        ),
      ),
    );
  }
}
