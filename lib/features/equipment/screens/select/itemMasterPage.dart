import 'package:bizd_tech_service/features/customer/provider/customer_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemMasterPageBusiness extends StatefulWidget {
  const ItemMasterPageBusiness({super.key});

  @override
  State<ItemMasterPageBusiness> createState() => _ItemMasterPageBusinessState();
}

class _ItemMasterPageBusinessState extends State<ItemMasterPageBusiness> {
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  bool _initialLoading = true;
  final filter = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    // _scrollController.addListener(() {
    //   final provider = Provider.of<ItemListProvider>(context, listen: false);
    //   if (_scrollController.position.pixels >=
    //           _scrollController.position.maxScrollExtent - 200 &&
    //       provider.hasMore &&
    //       !provider.isLoading) {
    //     provider.fetchDocuments(loadMore: true);
    //   }
    // });
  }

  // Future<void> _init() async {
  //   setState(() => _initialLoading = true);

  //   final provider = Provider.of<ItemListProvider>(context, listen: false);

  //   if (provider.documents.isEmpty) {
  //     await provider.fetchDocuments();
  //   }

  //   setState(() {
  //     _initialLoading = false;
  //   });
  // }

// Items?$select=ItemCode,ItemName,InventoryItem,InventoryUoMEntry,InventoryUOM,U_tl_dim1,U_tl_dim2 & $filter=InventoryItem eq 'tYES' ${props.filter ?? ""} &$orderby = ItemCode asc
  Future<void> _refreshData() async {
    setState(() => _initialLoading = true);

    // final provider = Provider.of<ItemListProvider>(context, listen: false);
    final provider =
        Provider.of<ItemListProviderOffline>(context, listen: false);

    // ✅ Only fetch if not already loaded
    // provider.resetPagination();
    // await provider.resfreshFetchDocuments();
    await provider.refreshDocuments();
    setState(() => _initialLoading = false);
  }

  String formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

// String formatDateTime(DateTime dt) {
//   return DateFormat('dd-MMM-yyyy - HH:mm').format(dt);
// }
  void onPressed(dynamic bp) {
    Navigator.pop(context, bp);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        title: const Text(
          "Item Lists",
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
      body: Consumer<ItemListProviderOffline>(
        builder: (context, deliveryProvider, _) {
          final documents = deliveryProvider.documents;
          final provider = Provider.of<ItemListProviderOffline>(context);
          // final isLoadingMore = provider.isLoading && provider.hasMore;
          final loading = provider.isLoading;
          print(documents);
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
              // const SizedBox(
              //   height: 15,
              // ),
              // 🔽 Filter Dropdown
              Container(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 25,
                              color: Color.fromARGB(255, 84, 84, 85),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "MATCHES YOUR FILTER",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.036,
                                  color: Color.fromARGB(255, 53, 53, 55)),
                            ),
                          ],
                        )),
                    Container(
                      padding: const EdgeInsets.fromLTRB(13, 10, 13, 5),
                      child: Row(
                        children: [
                          // smaller search field
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: filter,
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035),
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
                                  hintText: "Item Code",
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
                                  horizontal: 17, vertical: 13),
                              textStyle: const TextStyle(fontSize: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              provider.setFilter(filter.text);
                              provider.loadDocuments();
                              // example: print search text
                              // print("Search for: ${controller.text}");
                            },
                            child: const Text("GO"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(
              //   height: 5,
              // ),
              // 📦 List View with Pagination and States
              Expanded(
                // child: _initialLoading || provider.isLoadingSetFilter
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 100),
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: Colors.green,
                            size: 50.0,
                          ),
                        ),
                      )
                    : documents.isEmpty
                        ? const Center(
                            child: Text(
                              "No Item",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            // margin: const EdgeInsets.all(7),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 6),
                              itemCount: documents.length,
                              // documents.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // if (index == documents.length &&
                                //     isLoadingMore) {
                                //   return const Padding(
                                //     padding: EdgeInsets.all(4),
                                //     child: SizedBox(
                                //       height: 40,
                                //       child: Align(
                                //         alignment: Alignment.center,
                                //         child: SpinKitFadingCircle(
                                //           color: Colors.green,
                                //           size: 50.0,
                                //         ),
                                //       ),
                                //     ),
                                //   );
                                // }
                                final doc = documents[index];
                                return GestureDetector(
                                  onTap: () => onPressed(doc),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 2, 5, 2),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 239, 239, 240), // border color
                                        width: 1, // border width
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${(doc["ItemCode"] == null || doc["ItemCode"].toString().isEmpty) ? "N/A" : doc["ItemCode"]}',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.034,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 69, 70, 72)),
                                            ),
                                            const Icon(
                                              Icons.arrow_right,
                                              size: 21,
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${doc["ItemName"] ?? "N/A"}',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.033,
                                              // fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 69, 70, 72)),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
