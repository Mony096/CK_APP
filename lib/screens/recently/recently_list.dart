import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/main.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/delivery_history_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BlockDeliveryNotification {
  final String fromWarehouse;
  final String toWarehouse;
  final double distanceKm;
  final DateTime deliveryDate;
  final String address;
  final String status; // Add this line ✅

  BlockDeliveryNotification({
    required this.fromWarehouse,
    required this.toWarehouse,
    required this.distanceKm,
    required this.deliveryDate,
    required this.address,
    required this.status, // Add this line ✅
  });
}

class DeliveryNotificationList extends StatefulWidget {
  const DeliveryNotificationList({super.key});

  @override
  State<DeliveryNotificationList> createState() =>
      _DeliveryNotificationListState();
}

class _DeliveryNotificationListState extends State<DeliveryNotificationList> {
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  bool _initialLoading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    _scrollController.addListener(() {
      final provider =
          Provider.of<DeliveryNoteHistoryProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          provider.hasMore &&
          !provider.isLoading) {
        provider.fetchDocuments(loadMore: true);
      }
    });
  }

  Future<void> _init() async {
    setState(() => _initialLoading = true);

    final provider =
        Provider.of<DeliveryNoteHistoryProvider>(context, listen: false);
    final whProvider = Provider.of<HelperProvider>(context, listen: false);

    if (provider.documents.isEmpty) {
      await provider.fetchDocuments();
    }

    if (whProvider.warehouses.isEmpty) {
      await whProvider.fetchWarehouse();
    }

    if (whProvider.customer.isEmpty) {
      await whProvider.fetchCustomer();
    }

    setState(() {
      warehouses = whProvider.warehouses;
      customers = whProvider.customer;
      _initialLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _initialLoading = true);

    final provider =
        Provider.of<DeliveryNoteHistoryProvider>(context, listen: false);
    // ✅ Only fetch if not already loaded
    provider.resetPagination();
    await provider.fetchDocuments();

    setState(() {
      _initialLoading = false;
    });
  }

  String formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }
// String formatDateTime(DateTime dt) {
//   return DateFormat('dd-MMM-yyyy - HH:mm').format(dt);
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 33, 107, 243),
        title: const Text(
          "Delivered Recently",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  Future.microtask(() {
                    _refreshData();
                  });
                },
                icon: const Icon(
                  Icons.refresh,
                  size: 27,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  MaterialDialog.loading(context);
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pop(); // Close loading
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  size: 27,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<DeliveryNoteHistoryProvider>(
        builder: (context, deliveryProvider, _) {
          final documents = deliveryProvider.documents;
          final provider = Provider.of<DeliveryNoteHistoryProvider>(context);
          final isLoadingMore = provider.isLoading && provider.hasMore;

          // if (isLoading && documents.isEmpty) {
          //   return const Center(
          //     child: SpinKitFadingCircle(
          //       color: Colors.blue,
          //       size: 50.0,
          //     ),
          //   );
          // }

          // if (documents.isEmpty) {
          //   return const Center(
          //     child: Text(
          //       "No Delivered Recently",
          //       style: TextStyle(fontSize: 16, color: Colors.grey),
          //     ),
          //   );
          // }
          return Column(
            children: [
              SizedBox(
                height: 20,
              ),
              // 🔽 Filter Dropdown
              SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Row(
                    children: [
                      Icon(
                        Icons.list,
                        size: 25,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "MATCHES YOUR FILTER",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 25,
                child: ButtonTheme(
                    alignedDropdown:
                        true, // 👈 ensures popup aligns with button
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: DropdownButton<String>(
                        isExpanded: true, // important for full width
                        value: provider.currentFilter,
                        items: const [
                          DropdownMenuItem(
                              value: "All",
                              child: Text(
                                "All",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 66, 66, 68)),
                              )),
                          DropdownMenuItem(
                              value: "Completed",
                              child: Text(
                                "Completed",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 66, 66, 68)),
                              )),
                          DropdownMenuItem(
                              value: "Failed",
                              child: Text("Failed",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 66, 66, 68),
                                      fontWeight: FontWeight.normal))),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            provider.setFilter(value);
                          }
                        },
                      ),
                    )),
              ),
              SizedBox(
                height: 5,
              ),
              // 📦 List View with Pagination and States
              Expanded(
                child: _initialLoading || provider.isLoadingSetFilter
                    ? const Center(
                        child: SpinKitFadingCircle(
                          color: Colors.blue,
                          size: 50.0,
                        ),
                      )
                    : documents.isEmpty
                        ? const Center(
                            child: Text(
                              "No Delivered Recently",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 8),
                            itemCount:
                                documents.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == documents.length && isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: SizedBox(
                                    height: 40,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SpinKitFadingCircle(
                                        color: Colors.blue,
                                        size: 50.0,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final doc = documents[index];
                              final warehouse = warehouses.firstWhere(
                                (e) =>
                                    e["WarehouseCode"] ==
                                    doc["DocumentLines"][0]["WarehouseCode"],
                                orElse: () => {"WarehouseName": "N/A"},
                              );
                              final whName = warehouse["WarehouseName"];

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: doc["U_lk_delstat"] == "Delivered"
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 248, 231, 231),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.store,
                                                      size: 18,
                                                      color: Colors.black),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    whName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "→ ",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          doc["U_lk_delstat"] ==
                                                                  "Delivered"
                                                              ? Colors.green
                                                              : Colors.red,
                                                    ),
                                                  ),
                                                  Text(
                                                    "  ${doc["CardName"]}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 80,
                                          margin:
                                              const EdgeInsets.only(bottom: 22),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: doc["U_lk_delstat"] ==
                                                    "Delivered"
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              doc["U_lk_delstat"] == "Delivered"
                                                  ? "Completed"
                                                  : "Failed",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 20, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            doc["DocumentLines"][0]
                                                        ["ShipToDescription"]
                                                    .toString()
                                                    .isEmpty
                                                ? "N/A"
                                                : doc["DocumentLines"][0]
                                                    ["ShipToDescription"],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 119, 116, 116),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Icon(Icons.directions_car,
                                            size: 20, color: Colors.green),
                                        SizedBox(width: 6),
                                        Text(
                                          "N/A km",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 119, 116, 116),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 20, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${doc["DocDate"].split("T")[0]}  ${formatCustomTime(doc["DocTime"])}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 119, 116, 116),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
