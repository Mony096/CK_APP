import 'dart:async';
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

  bool _isCreatingOrEditing = false;
  Map<String, dynamic> _selectedEquipmentData = {};

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

  void _navigateToCreateOrEdit(Map<String, dynamic> data) {
    setState(() {
      _selectedEquipmentData = data;
      _isCreatingOrEditing = true;
    });
  }

  void onDetail(dynamic data, int index) {
    if (index < 0) return;

    _navigateToCreateOrEdit(Map<String, dynamic>.from(data));
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
              print(provider.equipments);
              if (equipment != null) {
                _navigateToCreateOrEdit(Map<String, dynamic>.from(equipment));
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

        if (_isCreatingOrEditing) {
          return EquipmentCreateScreen(
            data: _selectedEquipmentData,
            isNested: true,
            onBack: () {
              setState(() {
                _isCreatingOrEditing = false;
              });
              _refreshData();
            },
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              "Equipment",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 66, 83, 100),
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => _scanQrCode(context),
                icon: const Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 22),
                tooltip: 'Scan QR',
              ),
              IconButton(
                onPressed: () {
                  _navigateToCreateOrEdit(const {});
                },
                icon: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 26),
                tooltip: 'Add Equipment',
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: null,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: filter,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: const Color(0xFF1E293B)),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: "Search by name or code...",
                              hintStyle: GoogleFonts.inter(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.grey.shade400, size: 22),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              provider.setFilter(filter.text);
                              provider.loadEquipments();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF425364),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF425364).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            provider.setFilter(filter.text);
                            provider.loadEquipments();
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.tune_rounded,
                              color: Colors.white, size: 20),
                          tooltip: 'Apply Filter',
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
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (deliveryProvider.isLoadingMore)
                          Text(
                            "Loading...",
                            style: GoogleFonts.inter(
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
                                        style: GoogleFonts.inter(
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
                              padding: const EdgeInsets.fromLTRB(5, 8, 5, 20),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// PAGE INFO TEXT (Responsive)
                        Flexible(
                          child: Text(
                            MediaQuery.of(context).size.width < 380
                                ? "Pg ${deliveryProvider.currentPage}/${deliveryProvider.totalPages} (${deliveryProvider.totalRecords})"
                                : "Page ${deliveryProvider.currentPage} of ${deliveryProvider.totalPages} (${deliveryProvider.totalRecords} total)",
                            style: GoogleFonts.inter(
                              fontSize: responsiveFontSize(context,
                                  mobile: 11, tablet: 13),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// PAGINATION BUTTONS
                        Row(
                          children: [
                            _buildPageButton(
                              icon: Icons.first_page_rounded,
                              onTap: deliveryProvider.canPrev
                                  ? deliveryProvider.firstPage
                                  : null,
                              isEnabled: deliveryProvider.canPrev,
                            ),
                            const SizedBox(width: 8),
                            _buildPageButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: deliveryProvider.canPrev
                                  ? deliveryProvider.previousPage
                                  : null,
                              isEnabled: deliveryProvider.canPrev,
                            ),
                            const SizedBox(width: 8),
                            _buildPageButton(
                              icon: Icons.chevron_right_rounded,
                              onTap: deliveryProvider.canNext
                                  ? deliveryProvider.nextPage
                                  : null,
                              isEnabled: deliveryProvider.canNext,
                            ),
                            const SizedBox(width: 8),
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
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Circular key icon - User's specifically requested aesthetic
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22C55E).withAlpha(15),
                border: Border.all(
                  color: const Color(0xFF22C55E),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'images/svg/key.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF22C55E),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["Name"] ?? "Unknown Equipment",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        item["Code"] ?? "N/A",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 3,
                        width: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCBD5E1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "S/N: ${item["U_ck_eqSerNum"] ?? "N/A"}",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_pin_rounded,
                        size: 13,
                        color: Color(0xFF22C55E),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item["U_ck_CusName"] ?? "No Customer Assigned",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "#${index + 1}",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
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
