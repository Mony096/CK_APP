import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as google_fonts;
import 'package:intl/intl.dart';
import 'package:bizd_tech_service/core/extensions/theme_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature_preview_edit.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ServiceDetailScreen({super.key, required this.data});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _navScrollController = ScrollController();

  final GlobalKey _customerKey = GlobalKey();
  final GlobalKey _serviceKey = GlobalKey();
  final GlobalKey _equipmentKey = GlobalKey();
  final GlobalKey _activityKey = GlobalKey();
  final GlobalKey _materialKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _issueKey = GlobalKey();
  final GlobalKey _checklistKey = GlobalKey();
  final GlobalKey _attachmentKey = GlobalKey();

  // Navigation Keys
  final GlobalKey _navCustomerKey = GlobalKey();
  final GlobalKey _navServiceKey = GlobalKey();
  final GlobalKey _navEquipmentKey = GlobalKey();
  final GlobalKey _navActivityKey = GlobalKey();
  final GlobalKey _navMaterialKey = GlobalKey();
  final GlobalKey _navTimeKey = GlobalKey();
  final GlobalKey _navIssueKey = GlobalKey();
  final GlobalKey _navChecklistKey = GlobalKey();
  final GlobalKey _navAttachmentKey = GlobalKey();

  late Map<GlobalKey, GlobalKey> _sectionToNavKey;
  late Map<String, dynamic> _displayData;
  bool _isLoading = true;
  GlobalKey? _activeKey;

  @override
  void initState() {
    super.initState();
    _activeKey = _customerKey;
    _sectionToNavKey = {
      _customerKey: _navCustomerKey,
      _serviceKey: _navServiceKey,
      _equipmentKey: _navEquipmentKey,
      _activityKey: _navActivityKey,
      _materialKey: _navMaterialKey,
      _timeKey: _navTimeKey,
      _issueKey: _navIssueKey,
      _checklistKey: _navChecklistKey,
      _attachmentKey: _navAttachmentKey,
    };
    _scrollController.addListener(_onScroll);
    _enrichData();
  }

  void _onScroll() {
    // List of keys in order
    final keys = [
      _customerKey,
      _serviceKey,
      _equipmentKey,
      _activityKey,
      _materialKey,
      _timeKey,
      _issueKey,
      _checklistKey,
      _attachmentKey,
    ];

    GlobalKey? mostVisibleKey;
    double minDistance = double.infinity;

    for (var key in keys) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero).dy;
        // Check distance to the top of the viewport (app bar height is roughly 150 incl header)
        final distance = (position - 150).abs();
        if (distance < minDistance) {
          minDistance = distance;
          mostVisibleKey = key;
        }
      }
    }

    if (mostVisibleKey != null && mostVisibleKey != _activeKey) {
      setState(() {
        _activeKey = mostVisibleKey;
      });
      _scrollNavToActive();
    }
  }

  void _scrollNavToActive() {
    final navKey = _sectionToNavKey[_activeKey];
    if (navKey != null && navKey.currentContext != null) {
      Scrollable.ensureVisible(
        navKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navScrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    setState(() {
      _activeKey = key;
    });
    _scrollNavToActive();
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _enrichData() async {
    _displayData = Map<String, dynamic>.from(widget.data);
    prettyPrint(widget.data);
    // If it's a completed service (Entry) and we're missing rich data, look it up in offline storage
    if (_displayData['U_CK_Status'] == 'Entry' &&
        (_displayData['CK_JOB_TIMECollection'] == null ||
            (_displayData['CK_JOB_TIMECollection'] as List).isEmpty)) {
      try {
        final offlineProvider =
            Provider.of<ServiceListProviderOffline>(context, listen: false);
        final completedServices = offlineProvider.completedServices;

        // Find the matching payload by DocEntry (robust comparison)
        final richPayload = completedServices.firstWhere(
          (s) =>
              s['DocEntry']?.toString() == _displayData['DocEntry']?.toString(),
          orElse: () => {},
        );
        //  prettyPrint(richPayload);
        if (richPayload.isNotEmpty) {
          print(richPayload);
          debugPrint(
              "✅ Found rich payload for DocEntry: ${_displayData['DocEntry']}");

          _displayData.addAll(Map<String, dynamic>.from(richPayload));
        } else {
          debugPrint(
              "⚠️ No rich payload found in offline storage for DocEntry: ${_displayData['DocEntry']}");
          debugPrint("Pending services count: ${completedServices.length}");
        }
      } catch (e) {
        debugPrint("❌ Error enriching detail data: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color.fromARGB(255, 66, 83, 100)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          "Service Details",
          style: google_fonts.GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStickyNavigation(context),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(context),
                  SizedBox(height: 2.5.h),
                  _buildInfoCard(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "CUSTOMER INFORMATION",
                      key: _customerKey),
                  SizedBox(height: 1.5.h),
                  _buildCustomerDetails(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "SERVICES", key: _serviceKey),
                  SizedBox(height: 1.5.h),
                  _buildServiceSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "EQUIPMENT", key: _equipmentKey),
                  SizedBox(height: 1.5.h),
                  _buildEquipmentSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "ACTIVITIES", key: _activityKey),
                  SizedBox(height: 1.5.h),
                  _buildActivitySection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "MATERIAL RESERVE",
                      key: _materialKey),
                  SizedBox(height: 1.5.h),
                  _buildMaterialSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "TIME ENTRY", key: _timeKey),
                  SizedBox(height: 1.5.h),
                  _buildTimeSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "OPEN ISSUES", key: _issueKey),
                  SizedBox(height: 1.5.h),
                  _buildIssueSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "CHECKLIST", key: _checklistKey),
                  SizedBox(height: 1.5.h),
                  _buildChecklistSection(context),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(context, "ATTACHMENTS",
                      key: _attachmentKey),
                  SizedBox(height: 1.5.h),
                  _buildAttachmentSection(context),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF22C55E),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "COMPLETED SERVICE",
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Ticket #${_displayData['DocNum'] ?? _displayData['id'] ?? 'N/A'}",
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              "DONE",
              style: google_fonts.GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.calendar_today_rounded, "Service Date",
              _formatDate(_displayData['U_CK_Date'])),
          const Divider(height: 32, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildInfoRow(context, Icons.access_time_rounded, "Start Time",
              "${_displayData['U_CK_Time'] ?? 'N/A'}"),
          const Divider(height: 32, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildInfoRow(context, Icons.access_time_rounded, "End Time",
              "${_displayData['U_CK_EndTime'] ?? 'N/A'}"),
          const Divider(height: 32, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildInfoRow(context, Icons.category_rounded, "Job Type",
              _displayData['U_CK_JobType'] ?? 'N/A'),
          const Divider(height: 32, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildInfoRow(context, Icons.category_rounded, "Service Type",
              "${_displayData['U_CK_ServiceType'] ?? 'N/A'}"),
          const Divider(height: 32, thickness: 0.8, color: Color(0xFFF1F5F9)),
          _buildInfoRow(context, Icons.priority_high_rounded, "Priority",
              _displayData['U_CK_Priority'] ?? 'Normal'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(0.5.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 2.5.w),
        Text(
          label,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: google_fonts.GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyNavigation(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _navScrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            _buildNavChip(context, "Customer", Icons.person_rounded,
                _customerKey, _navCustomerKey),
            _buildNavChip(context, "Services", Icons.room_service_rounded,
                _serviceKey, _navServiceKey),
            _buildNavChip(
                context,
                "Equipment",
                Icons.precision_manufacturing_rounded,
                _equipmentKey,
                _navEquipmentKey),
            _buildNavChip(context, "Activities", Icons.checklist_rounded,
                _activityKey, _navActivityKey),
            _buildNavChip(context, "Materials", Icons.inventory_2_rounded,
                _materialKey, _navMaterialKey),
            _buildNavChip(context, "Time Logs",
                Icons.access_time_filled_rounded, _timeKey, _navTimeKey),
            _buildNavChip(context, "Issues", Icons.report_problem_rounded,
                _issueKey, _navIssueKey),
            _buildNavChip(context, "Checklist", Icons.fact_check_rounded,
                _checklistKey, _navChecklistKey),
            _buildNavChip(context, "Files", Icons.attach_file_rounded,
                _attachmentKey, _navAttachmentKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavChip(BuildContext context, String label, IconData icon,
      GlobalKey sectionKey, GlobalKey navKey) {
    final bool isActive = _activeKey == sectionKey;

    return Padding(
      key: navKey,
      padding: EdgeInsets.only(right: 2.5.w),
      child: GestureDetector(
        onTap: () => _scrollToSection(sectionKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF22C55E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.transparent : const Color(0xFFE2E8F0),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: google_fonts.GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {Key? key}) {
    return Container(
      key: key,
      margin: EdgeInsets.only(left: 1.w, bottom: 0.5.h),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18.sp,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            title,
            style: google_fonts.GoogleFonts.plusJakartaSans(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context) {
    final contactList = _displayData['CustomerContact'] as List? ?? [];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.business_rounded,
                    size: 18.sp, color: context.colors.primary),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _displayData['CustomerName'] ?? 'No Customer Name',
                  style: google_fonts.GoogleFonts.inter(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _getCustomerAddress(),
            style: google_fonts.GoogleFonts.inter(
              fontSize: 14.sp,
              color: const Color(0xFF475569),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (contactList.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            ...contactList.map((contact) {
              final String name = contact['Name'] ?? 'N/A';
              final String phone = contact['Phone1'] ?? 'N/A';

              return Padding(
                padding: EdgeInsets.only(bottom: 1.8.h),
                child: Row(
                  children: [
                    Icon(Icons.person_pin_rounded,
                        size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 2.5.w),
                    Expanded(
                      flex: 3,
                      child: Text(
                        name,
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.phone_iphone_rounded,
                        size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 2.5.w),
                    Expanded(
                      flex: 2,
                      child: Text(
                        phone,
                        style: google_fonts.GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    final services = _displayData['CK_JOB_SERVICESCollection'] as List? ?? [];
    return _buildItemList(
      items: services,
      emptyMessage: "No services recorded.",
      icon: Icons.room_service_rounded,
      titleKey: 'U_CK_ServiceName',
      subtitleKey: 'U_CK_UnitPrice',
      subtitlePrefix: 'Price: ',
      subtitleSuffix: ' USD',
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    final equipment = _displayData['CK_JOB_EQUIPMENTCollection'] as List? ?? [];
    return _buildItemList(
      items: equipment,
      emptyMessage: "No equipment recorded.",
      icon: Icons.precision_manufacturing_rounded,
      titleKey: 'U_CK_EquipName',
      subtitleKey: 'U_CK_SerialNum',
      subtitlePrefix: 'SN: ',
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final activities = _displayData['activityLine'] as List? ?? [];
    return _buildItemList(
      items: activities,
      emptyMessage: "No activities recorded.",
      svgIcon: 'images/svg/task_check.svg',
      titleKey: 'Activity',
    );
  }

  Widget _buildMaterialSection(BuildContext context) {
    final materials = _displayData['CK_JOB_MATERIALCollection'] as List? ?? [];
    return _buildItemList(
      items: materials,
      emptyMessage: "No materials recorded.",
      icon: Icons.inventory_2_rounded,
      titleKey: 'U_CK_ItemName',
      subtitleKey: 'U_CK_Qty',
      subtitlePrefix: 'Qty: ',
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final timeEntries = _displayData['CK_JOB_TIMECollection'] as List? ?? [];
    return _buildItemList(
      items: timeEntries,
      emptyMessage: "No time entries recorded.",
      icon: Icons.access_time_filled_rounded,
      titleKey: 'U_CK_Description',
      customSubtitle: (item) {
        return "Time: ${item['U_CK_StartTime'] ?? 'N/A'} - ${item['U_CK_EndTime'] ?? 'N/A'} (${item['U_CK_Effort'] ?? '0h 0m'})";
      },
    );
  }

  Widget _buildAttachmentSection(BuildContext context) {
    final files = _displayData['files'] as List? ?? [];
    if (files.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "No attachments recorded.",
          style: google_fonts.GoogleFonts.inter(
              fontSize: 13.5.sp, color: const Color(0xFF64748B)),
        ),
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.5.w,
            mainAxisSpacing: 3.5.w,
            childAspectRatio: 1.1,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final String? base64Data = file['data'];
            final String ext = (file['ext'] ?? 'png').toString().toLowerCase();
            if (base64Data == null) return const SizedBox();

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ext == 'pdf'
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerScreen(
                                memoryData: base64Decode(base64Data),
                                title: "Signature (PDF)",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          color: const Color(0xFFFFF1F2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  color: const Color(0xFFE11D48), size: 24.sp),
                              SizedBox(height: 1.h),
                              Text(
                                "Signature",
                                style: google_fonts.GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Image.memory(
                        base64Decode(base64Data),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image_rounded,
                                size: 20.sp, color: Colors.grey)),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemList({
    required List items,
    required String emptyMessage,
    IconData? icon,
    String? svgIcon,
    required String titleKey,
    String? subtitleKey,
    String subtitlePrefix = '',
    String subtitleSuffix = '',
    String Function(dynamic)? customSubtitle,
  }) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Text(
          emptyMessage,
          style: google_fonts.GoogleFonts.inter(
              fontSize: 13.5.sp, color: const Color(0xFF94A3B8)),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: svgIcon != null
                    ? Center(
                        child: SvgPicture.asset(
                          svgIcon,
                          width: 18.sp,
                          height: 18.sp,
                          color: const Color(0xFF64748B),
                        ),
                      )
                    : Icon(icon, color: const Color(0xFF64748B), size: 18.sp),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[titleKey]?.toString() ?? 'N/A',
                      style: google_fonts.GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5.sp,
                          color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      customSubtitle != null
                          ? customSubtitle(item)
                          : "$subtitlePrefix${item[subtitleKey] ?? '0'}$subtitleSuffix",
                      style: google_fonts.GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString().split('T')[0]);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }

  String _getCustomerAddress() {
    final addressList = _displayData['CustomerAddress'] as List?;
    if (addressList == null || addressList.isEmpty)
      return 'No Address Available';
    final addr = addressList.first;
    return addr['StreetNo'] ?? 'No Address Available';
  }

  Widget _buildChecklistSection(BuildContext context) {
    final checklist = _displayData['checklistLine'] as List? ?? [];
    return _buildItemList(
      items: checklist,
      emptyMessage: "No checklist data recorded.",
      icon: Icons.assignment_turned_in_rounded,
      titleKey: 'U_CK_ChecklistTitle',
      customSubtitle: (item) {
        final String status =
            item['U_CK_TrueOutput'] == 'Yes' ? 'Passed' : 'Failed';
        return "Status: $status";
      },
    );
  }

  Widget _buildIssueSection(BuildContext context) {
    final issues = _displayData['CK_JOB_ISSUECollection'] as List? ?? [];
    return _buildItemList(
      items: issues,
      emptyMessage: "No open issues recorded.",
      icon: Icons.report_problem_rounded,
      titleKey: 'U_CK_IssueType',
      subtitleKey: 'U_CK_IssueDesc',
      subtitlePrefix: 'Desc: ',
    );
  }
}
