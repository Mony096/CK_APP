import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/main.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BusinessPartnerPage extends StatefulWidget {
  const BusinessPartnerPage({super.key});

  @override
  State<BusinessPartnerPage> createState() => _BusinessPartnerPageState();
}

class _BusinessPartnerPageState extends State<BusinessPartnerPage> {
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  bool _initialLoading = true;
  final filter = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    _scrollController.addListener(() {
      final provider =
          Provider.of<CustomerListProvider>(context, listen: false);
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
        Provider.of<CustomerListProvider>(context, listen: false);
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
        Provider.of<CustomerListProvider>(context, listen: false);
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
        backgroundColor: const Color.fromARGB(255, 102, 103, 104),
        title: const Text(
          "Customer Lists",
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
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer<CustomerListProvider>(
        builder: (context, deliveryProvider, _) {
          final documents = deliveryProvider.documents;
          final provider = Provider.of<CustomerListProvider>(context);
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
              Container(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
                child: Row(
                  children: [
                    // smaller search field
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: filter,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 206, 206, 208),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 203, 203, 203),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 96, 126, 105),
                                width: 1.5,
                              ),
                            ),
                            hintText: "Search",
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            // Decrease vertical and horizontal padding to shrink the field
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 4, // Reduced from 8
                                horizontal: 12 // Reduced from 12
                                ),
                            // border: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(10),
                            //   borderSide: BorderSide.none,
                            // ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // smaller button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: const TextStyle(fontSize: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        provider.setFilter(filter.text);

                        // example: print search text
                        // print("Search for: ${controller.text}");
                      },
                      child: const Text("GO"),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              // 📦 List View with Pagination and States
              Expanded(
                child: _initialLoading || provider.isLoadingSetFilter
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: const Center(
                          child: SpinKitFadingCircle(
                            color: Colors.blue,
                            size: 50.0,
                          ),
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

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 15),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 248, 231, 231),
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
                                                    doc["CardCode"],
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
                                                        color: Colors.green),
                                                  ),
                                                  Text(
                                                    "  1111",
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
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Failed",
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
                                            "aa",
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
                                          "aaaa",
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
