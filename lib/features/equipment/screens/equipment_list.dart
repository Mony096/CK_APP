import 'dart:async';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/screens/equipment_create.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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

  void _navigateToCreateOrEdit(Map<String, dynamic> data,
      {bool isCreate = false}) {
    goTo(
      context,
      EquipmentCreateScreen(
        data: data,
        isCreate: isCreate,
        onBack: () {
          Navigator.pop(context);
          _refreshData();
        },
      ),
    );
  }

  void onDetail(dynamic data, int index) {
    if (index < 0) return;

    _navigateToCreateOrEdit(Map<String, dynamic>.from(data), isCreate: false);
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

              // Search for equipment by code (search all equipments, not just current page)
              final index = provider.allFilteredEquipments.indexWhere(
                (e) => e['Code'] == scannedCode,
              );
              final equipment =
                  index != -1 ? provider.allFilteredEquipments[index] : null;
              if (equipment != null) {
                _navigateToCreateOrEdit(Map<String, dynamic>.from(equipment),
                    isCreate: false);
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
          // appBar: AppBar(
          //   title: Text(
          //     "Equipment",
          //     style: google_fonts.GoogleFonts.inter(
          //       fontWeight: FontWeight.w700,
          //       fontSize: 17.sp,
          //       color: Colors.white,
          //     ),
          //   ),
          //   centerTitle: true,
          //   backgroundColor: Color.fromARGB(255, 66, 83, 100),
          //   elevation: 0,
          //   automaticallyImplyLeading: false,
          //   actions: [
          //     IconButton(
          //       onPressed: () => _scanQrCode(context),
          //       icon: const Icon(Icons.qr_code_scanner,
          //           color: Colors.white, size: 22),
          //       tooltip: 'Scan QR',
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         _navigateToCreateOrEdit(const {}, isCreate: true);
          //       },
          //       icon: const Icon(Icons.add_rounded,
          //           color: Colors.white, size: 26),
          //       tooltip: 'Add Equipment',
          //     ),
          //     const SizedBox(width: 8),
          //   ],
          // ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF1E293B),
            onPressed: () {
              _navigateToCreateOrEdit(const {}, isCreate: true);
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
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
                  padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            // border: Border.all(color: const Color(0xFFE2E8F0)),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.03),
                            //     blurRadius: 10,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],
                          ),
                          child: TextField(
                            controller: filter,
                            style: google_fonts.GoogleFonts.inter(
                                fontSize: 14.5.sp,
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w500),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: "Search equipment...",
                              hintStyle: google_fonts.GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 14.sp,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(Icons.search_rounded,
                                    color: const Color(0xFF1E293B),
                                    size: 19.sp),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              provider.setFilter(filter.text);
                              provider.loadEquipments();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _scanQrCode(context),
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.qr_code_scanner_rounded,
                              color: const Color(0xFF334155), size: 18.sp),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      GestureDetector(
                        onTap: () {
                          provider.setFilter(filter.text);
                          provider.loadEquipments();
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF334155), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF1E293B).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(Icons.tune_rounded,
                              color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                if (documents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${deliveryProvider.currentCount} of ${deliveryProvider.totalRecords} items",
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: 12.8.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (deliveryProvider.isLoadingMore)
                          Text(
                            "Loading...",
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                      ],
                    ),
                  ),
                // CONTENT
                Expanded(
                  child: loading
                      ? const Center(
                          child: SpinKitFadingCircle(
                            color: Color(0xFF22C55E),
                            size: 40.0,
                          ),
                        )
                      : documents.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.inventory_2_outlined,
                                          size: 64,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No Equipment Found",
                                        style: google_fonts.GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 20),
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                final item = documents[index];
                                final globalIndex =
                                    (deliveryProvider.currentPage - 1) *
                                            deliveryProvider.pageSize +
                                        index;
                                return _buildEquipmentCard(item, globalIndex);
                              },
                            ),
                ),
                // Pagination Footer
                if (documents.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(
                          top: BorderSide(color: Color(0xFFF1F5F9))),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pg ${deliveryProvider.currentPage} of ${deliveryProvider.totalPages}",
                          style: google_fonts.GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          children: [
                            _buildPageButton(
                              icon: Icons.first_page_rounded,
                              onTap: deliveryProvider.canPrev
                                  ? deliveryProvider.firstPage
                                  : null,
                              isEnabled: deliveryProvider.canPrev,
                            ),
                            SizedBox(width: 2.w),
                            _buildPageButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: deliveryProvider.canPrev
                                  ? deliveryProvider.previousPage
                                  : null,
                              isEnabled: deliveryProvider.canPrev,
                            ),
                            SizedBox(width: 2.w),
                            _buildPageButton(
                              icon: Icons.chevron_right_rounded,
                              onTap: deliveryProvider.canNext
                                  ? deliveryProvider.nextPage
                                  : null,
                              isEnabled: deliveryProvider.canNext,
                            ),
                            SizedBox(width: 2.w),
                            _buildPageButton(
                              icon: Icons.last_page_rounded,
                              onTap: deliveryProvider.canNext
                                  ? deliveryProvider.lastPage
                                  : null,
                              isEnabled: deliveryProvider.canNext,
                            ),
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
    );
  }

  Widget _buildEquipmentCard(dynamic item, int index) {
    return GestureDetector(
      onTap: () => onDetail(item, index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.4.h, horizontal: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    'images/svg/key.svg',
                    width: 16.sp,
                    height: 16.sp,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1E293B),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item["Name"] ?? "Unknown Equipment",
                              style: google_fonts.GoogleFonts.inter(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item["Code"] ?? "N/A",
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 12.7.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.4.h),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 11.sp, color: const Color(0xFF94A3B8)),
                          SizedBox(width: 1.w),
                          Text(
                            "S/N: ${item["U_ck_eqSerNum"] == "" ? "N/A" : item["U_ck_eqSerNum"]}",
                            style: google_fonts.GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  size: 13.sp,
                  color: const Color(0xFF16A34A),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    item["U_ck_CusName"] ?? "Unassigned",
                    style: google_fonts.GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  "#${index + 1}",
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8).withOpacity(0.5),
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 11.sp, color: const Color(0xFFCBD5E1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

double responsiveFontSize(BuildContext context,
    {double mobile = 12, double tablet = 13, double desktop = 14}) {
  final double width = MediaQuery.of(context).size.width;

  if (width < 600) {
    return mobile; // Mobile
  } else if (width < 1024) {
    return tablet; // Tablet
  } else {
    return desktop; // Web / Desktop
  }
}
