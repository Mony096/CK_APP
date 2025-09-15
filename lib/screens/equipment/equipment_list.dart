import 'dart:async';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/equipment/equipment_create.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});
  @override
  _EquipmentListScreenState createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client
  bool _initialLoading = true;
  final ScrollController _scrollController = ScrollController();
  final filter = TextEditingController();

  final bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    _scrollController.addListener(() {
      final provider =
          Provider.of<EquipmentListProvider>(context, listen: false);
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

    final provider = Provider.of<EquipmentListProvider>(context, listen: false);

    if (provider.documents.isEmpty) {
      await provider.fetchDocuments();
    }

    setState(() {
      _initialLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _initialLoading = true);

    final provider = Provider.of<EquipmentListProvider>(context, listen: false);
    // ✅ Only fetch if not already loaded
    provider.resetPagination();
    await provider.resfreshFetchDocuments();
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
  }

  void onDetail(dynamic data, int index) {
    if (index < 0) return;

    // MaterialDialog.viewDetailDialog(
    //   context,
    //   title: 'Equipment (${data['Code']})',
    //   cancelLabel: "Go",
    //   onCancel: () {
    //     goTo(context, EquipmentCreateScreen(data: data));
    //   },
    // );
    goTo(context, EquipmentCreateScreen(data: data));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentListProvider>(
      builder: (context, deliveryProvider, _) {
        final documents = deliveryProvider.documents;
        // final isLoading = deliveryProvider.isLoading;
        final provider = Provider.of<EquipmentListProvider>(context);
        final isLoadingMore = provider.isLoading && provider.hasMore;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (not scrollable)
              Container(
                height: 265,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 66, 83, 100),
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(12),
                  //   bottomRight: Radius.circular(12),
                  // ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 40,
                      left: 25,
                      right: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                  ),
                                  child: SvgPicture.asset(
                                    color: const Color.fromARGB(
                                        255, 102, 103, 104),
                                    'images/svg/reply.svg',
                                    width: 15,
                                  ))),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _refreshData();
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
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .logout();
                                  Navigator.of(context).pop(); // Close loading
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
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
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 105,
                        left: 25,
                        right: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  color: const Color.fromARGB(255, 39, 204, 39),
                                  'images/svg/kjav_list.svg',
                                  width: 33,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text(
                                   textScaleFactor: 1.0,
                                  "Equipment Overview",
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                await goTo(
                                        context,
                                        EquipmentCreateScreen(
                                          data: const {},
                                        ))
                                    .then(
                                        (res) => {print(res), _refreshData()});
                              },
                              child: Container(
                                width: 65,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 56, 67, 80)
                                              .withOpacity(
                                                  0.3), // Light gray shadow
                                      spreadRadius: 3, // Smaller spread
                                      blurRadius: 3, // Smaller blur
                                      offset: const Offset(
                                          0, 1), // Minimal vertical offset
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add,
                                          size: 16,
                                          color: Color.fromARGB(
                                              255, 104, 104, 110)),
                                      Text(
                                         textScaleFactor: 1.0,
                                        "New",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 104, 104, 110)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(width: 2,)
                          ],
                        )),
                    Positioned(
                        top: 170,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: 265 *
                                      3.1415926535897932 /
                                      180, // 90 degrees in radians
                                  child: SvgPicture.asset(
                                    'images/svg/reply.svg',
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 17,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                   textScaleFactor: 1.0,
                                  "Matches Your Filter",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),

                            // SizedBox(width: 2,)
                          ],
                        )),
                    Positioned(
                      top: 185,
                      left: 22,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
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
                                    hintText: "Search",
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    // Decrease vertical and horizontal padding to shrink the field
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 4, // Reduced from 8
                                        horizontal: 12 // Reduced from 12
                                        ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
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
                    )

                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // CONTENT
              Expanded(
                child: _initialLoading || provider.isLoadingSetFilter
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
                              "No Equipment",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : Container(
                            // padding: const EdgeInsets.all(0),
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
                            // margin: const EdgeInsets.all(10),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 5),
                              itemCount:
                                  documents.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == documents.length &&
                                    isLoadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: SizedBox(
                                      height: 40,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: SpinKitFadingCircle(
                                          color: Colors.green,
                                          size: 50.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final item = documents[index];

                                return GestureDetector(
                                  onTap: () {
                                    onDetail(item, index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 6.5, 10, 10),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 239, 239, 240),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Circle icon
                                        Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 39, 204, 39),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                              'images/svg/key.svg',
                                              width: 20,
                                              height: 20,
                                              color: const Color.fromARGB(
                                                  255, 39, 204, 39),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Info section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                     textScaleFactor: 1.0,
                                                    "${item["Code"] ?? "N/A"} - ${item["Name"] ?? "N/A"}",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.keyboard_arrow_right,
                                                    size: 25,
                                                    color: Color.fromARGB(
                                                        255, 135, 137, 138),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 104,
                                                    child: Text(
                                                        textScaleFactor: 1.0,
                                                        "Serial Number",
                                                        style: TextStyle(
                                                            fontSize: 13)),
                                                  ),
                                                  Text(
                                                     textScaleFactor: 1.0,
                                                      ": ${item["U_ck_eqSerNum"] ?? "N/A"}",
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 104,
                                                        child: Text(
                                                           textScaleFactor:
                                                                1.0,
                                                            "Customer Name",
                                                            style: TextStyle(
                                                                fontSize: 13)),
                                                      ),
                                                      Text(
                                                         textScaleFactor: 1.0,
                                                          ": ${item["U_ck_CusName"] ?? "N/A"}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                      13)),
                                                    ],
                                                  ),
                                                  Text("No : ${index + 1}",
                                                      style: const TextStyle(
                                                          fontSize: 13)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
