import 'dart:async';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_list_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_provider.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/features/equipment/screens/equipment_create.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  bool _isSearchExpanded = false;

  final bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => _init());

    // _scrollController.addListener(() {
    //   final provider =
    //       Provider.of<EquipmentListProvider>(context, listen: false);
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

  //   final provider = Provider.of<EquipmentListProvider>(context, listen: false);

  //   if (provider.documents.isEmpty) {
  //     await provider.fetchDocuments();
  //   }

  //   setState(() {
  //     _initialLoading = false;
  //   });
  // }

  Future<void> _refreshData() async {
    setState(() => _initialLoading = true);

    final provider =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);
    // ✅ Only fetch if not already loaded
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

  void _scanQrCode(BuildContext context) {
    final provider =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Color.fromARGB(255, 33, 46, 57),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Scan Equipment QR',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final scannedCode = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.rawValue
                  : null;

              if (scannedCode == null) return;

              Navigator.pop(dialogContext); // Close scanner dialog

              // Search for equipment by code
              final equipment = provider.equipments.firstWhere(
                (e) => e['Code'] == scannedCode,
                orElse: () => null,
              );
              print( provider.equipments);
              if (equipment != null) {
                goTo(context, EquipmentCreateScreen(data: equipment));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Equipment not found: $scannedCode'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                color: Color.fromARGB(255, 65, 66, 67),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EquipmentOfflineProvider>(
      builder: (context, deliveryProvider, _) {
        // final documents = deliveryProvider.documents;
        final documents = deliveryProvider.equipments;

        // final isLoading = deliveryProvider.isLoading;
        final provider = Provider.of<EquipmentOfflineProvider>(context);
        // final isLoadingMore = provider.isLoading && provider.hasMore;
        const loading = false;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              "Equipment",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Scanner FAB
              FloatingActionButton(
                heroTag: 'qr_scanner',
                onPressed: () => _scanQrCode(context),
                backgroundColor: const Color(0xFF22C55E),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Add Equipment FAB
              FloatingActionButton(
                heroTag: 'add_equipment',
                onPressed: () async {
                  await goTo(context, EquipmentCreateScreen(data: const {}))
                      .then((_) => _refreshData());
                },
                backgroundColor: const Color(0xFF22C55E),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _refreshData();
            },
            color: const Color(0xFF22C55E),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                    ),
                  ),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: filter,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "Search equipment...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade400, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF22C55E), size: 18),
                          onPressed: () {
                            provider.setFilter(filter.text);
                            provider.loadEquipments();
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) {
                        provider.setFilter(filter.text);
                        provider.loadEquipments();
                      },
                    ),
                  ),
                ),
                // CONTENT
                Expanded(
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
                          ? ListView(
                              children: const [
                                SizedBox(height: 200),
                                Center(
                                  child: Text(
                                    "No Equipment",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ],
                            )
                          : Container(
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
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(top: 5),
                                itemCount: documents.length,
                                // documents.length + (isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // if (index == documents.length &&
                                  //     isLoadingMore) {
                                  //   return const Padding(
                                  //     padding: EdgeInsets.symmetric(vertical: 16),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                    Row(
                                                      children: [
                                                        // Code
                                                        // SizedBox(
                                                        //   width: 90,
                                                        //   child: Text(
                                                        //     item["Code"] ?? "N/A",
                                                        //     overflow: TextOverflow
                                                        //         .ellipsis,
                                                        //     style:
                                                        //         const TextStyle(
                                                        //       fontWeight:
                                                        //           FontWeight.bold,
                                                        //       fontSize: 11,
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        Text(
                                                          item["Code"] ?? "N/A",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11,
                                                          ),
                                                        ),

                                                        const Text(" - "),

                                                        // Name
                                                        SizedBox(
                                                          width: 90,
                                                          child: Text(
                                                            item["Name"] ??
                                                                "N/A",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      size: 25,
                                                      color: Color.fromARGB(
                                                          255, 135, 137, 138),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 104,
                                                      child: Text(
                                                          textScaleFactor: 1.0,
                                                          "Serial Number",
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.031)),
                                                    ),
                                                    Text(
                                                        textScaleFactor: 1.0,
                                                        ": ${item["U_ck_eqSerNum"] ?? "N/A"}",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.031)),
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
                                                        SizedBox(
                                                          width: 104,
                                                          child: Text(
                                                              textScaleFactor:
                                                                  1.0,
                                                              "Customer Name",
                                                              style: TextStyle(
                                                                  fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.031)),
                                                        ),
                                                        // Text(
                                                        //     textScaleFactor: 1.0,
                                                        //     ": ${item["U_ck_CusName"] ?? "N/A"}",
                                                        //     style: TextStyle(
                                                        //         color:
                                                        //             Colors.green,
                                                        //         fontSize: MediaQuery.of(
                                                        //                     context)
                                                        //                 .size
                                                        //                 .width *
                                                        //             0.031)),
                                                        SizedBox(
                                                          width: 120,
                                                          child: Text(
                                                            item["U_ck_CusName"] ??
                                                                "N/A",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text("No : ${index + 1}",
                                                        style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.031)),
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
          ),
        );
      },
    );
  }
}
