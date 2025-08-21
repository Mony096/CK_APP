import 'dart:async';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/equipment/equipment_create.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});
  @override
  _EquipmentListScreenState createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init(); // this safely runs after first build
    });
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final dnProvider =
        Provider.of<DeliveryNoteProvider>(context, listen: false);
    if (dnProvider.documents.isEmpty) {
      await dnProvider.fetchDocuments();
    }

    final whProvider = Provider.of<HelperProvider>(context, listen: false);
    if (whProvider.warehouses.isEmpty) {
      await whProvider.fetchWarehouse();
    }

    final customerProvider =
        Provider.of<HelperProvider>(context, listen: false);
    if (customerProvider.customer.isEmpty) {
      await customerProvider.fetchCustomer();
    }

    if (!mounted) return;
    setState(() {
      warehouses = whProvider.warehouses;
      customers = customerProvider.customer;

      _isLoading = false;
    });
  }

  void onCompletedSkip(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry,
            status: "Delivered",
            remarks: "",
            context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void onFailedDelivery(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry, status: "Failed", remarks: "", context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryNoteProvider>(
      builder: (context, deliveryProvider, _) {
        final documents = deliveryProvider.documents;
        final isLoading = deliveryProvider.isLoading;

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
                                onPressed: () async {
                                  Future.microtask(() {
                                    final provider =
                                        Provider.of<DeliveryNoteProvider>(
                                            context,
                                            listen: false);
                                    provider.fetchDocuments();
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
                                  "Equipment Overview",
                                  style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            GestureDetector(
                              onTap: ()=> goTo(context, EquipmentCreateScreen()),
                              child: Container(
                                width: 65,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 56, 67, 80)
                                          .withOpacity(0.3), // Light gray shadow
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
                                          color:
                                              Color.fromARGB(255, 104, 104, 110)),
                                      Text(
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
                                  "Matches Your Filter",
                                  style: TextStyle(
                                    fontSize: 16,
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
              SizedBox(
                height: 10,
              ),
              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(children: [
                    ...List.generate(10, (index) => 'Item ${index + 1}')
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return GestureDetector(
                        onTap: () {
                          // onEdit(item, index);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 6.5, 10, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: index == 0
                                    ? const Color.fromARGB(255, 222, 224, 227)
                                    : Colors.white,
                                width: 1,
                              ),
                              bottom: const BorderSide(
                                color: Color.fromARGB(255, 222, 224, 227),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 45,
                                  width:
                                      45, // Ensure the width and height are equal for a perfect circle
                                  decoration: BoxDecoration(
                                    // color:
                                    //     const Color.fromARGB(255, 33, 107, 243),
                                    shape: BoxShape
                                        .circle, // Makes the container circular
                                    border: Border.all(
                                      color: const Color.fromARGB(255, 39, 204,
                                          39), // Optional: Add a border if needed
                                      width: 1.0, // Border width
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
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("A001 - EQ Name",
                                            // "${getDataFromDynamic(item["Code"])} - ${getDataFromDynamic(item["Name"])} ", // Show index
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            textScaleFactor: 1.0),
                                        Icon(
                                          Icons.keyboard_arrow_right,
                                          size: 25,
                                          color: Color.fromARGB(
                                              255, 135, 137, 138),
                                        )
                                        // Text(
                                        //     getDataFromDynamic(
                                        //         item["U_ck_CusName"]),
                                        //     style:
                                        //         const TextStyle(fontSize: 13),
                                        //     textScaleFactor: 1.0),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 104,
                                              child: Text("Serial Number",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                  textScaleFactor: 1.0),
                                            ),
                                            Text(
                                                // ": ${getDataFromDynamic(item["U_ck_eqSerNum"])}",
                                                ": 01922",
                                                style: TextStyle(fontSize: 13),
                                                textScaleFactor: 1.0),
                                          ],
                                        ),
                                        // Text("No. ${index + 1}",
                                        //     style:
                                        //         const TextStyle(fontSize: 13),
                                        //     textScaleFactor: 1.0),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            SizedBox(
                                              width: 104,
                                              child: Text("Customer Name",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                  textScaleFactor: 1.0),
                                            ),
                                            Text(
                                                // ": ${getDataFromDynamic(item["U_ck_CusName"])}",
                                                ": EQ Name",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 13),
                                                textScaleFactor: 1.0),
                                          ],
                                        ),
                                        Text("No : ${index + 1}",
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
