import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bizd_tech_service/core/extensions/theme_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/signature/signature_preview_edit.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ServiceDetailScreen({super.key, required this.data});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _customerKey = GlobalKey();
  final GlobalKey _serviceKey = GlobalKey();
  final GlobalKey _equipmentKey = GlobalKey();
  final GlobalKey _activityKey = GlobalKey();
  final GlobalKey _materialKey = GlobalKey();
  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _issueKey = GlobalKey();
  final GlobalKey _checklistKey = GlobalKey();
  final GlobalKey _attachmentKey = GlobalKey();

  late Map<String, dynamic> _displayData;
  bool _isLoading = true;
  GlobalKey? _activeKey;

  @override
  void initState() {
    super.initState();
    _activeKey = _customerKey;
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
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    setState(() {
      _activeKey = key;
    });
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
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(context),
                  const SizedBox(height: 20),
                  _buildInfoCard(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Customer Information",
                      key: _customerKey),
                  const SizedBox(height: 12),
                  _buildCustomerDetails(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Services", key: _serviceKey),
                  const SizedBox(height: 12),
                  _buildServiceSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Equipment", key: _equipmentKey),
                  const SizedBox(height: 12),
                  _buildEquipmentSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Activities", key: _activityKey),
                  const SizedBox(height: 12),
                  _buildActivitySection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Material Reserve",
                      key: _materialKey),
                  const SizedBox(height: 12),
                  _buildMaterialSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Time Entry", key: _timeKey),
                  const SizedBox(height: 12),
                  _buildTimeSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Open Issues", key: _issueKey),
                  const SizedBox(height: 12),
                  _buildIssueSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Checklist", key: _checklistKey),
                  const SizedBox(height: 12),
                  _buildChecklistSection(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, "Attachments",
                      key: _attachmentKey),
                  const SizedBox(height: 12),
                  _buildAttachmentSection(context),
                  const SizedBox(height: 48),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "COMPLETED SERVICE",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ticket #${_displayData['DocNum'] ?? _displayData['id'] ?? 'N/A'}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // Optional badge (nice touch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "DONE",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.calendar_today_rounded, "Service Date",
              _formatDate(_displayData['U_CK_Date'])),
          const Divider(height: 24, thickness: 0.5),
          _buildInfoRow(context, Icons.access_time_rounded, "Start Time",
              "${_displayData['U_CK_Time'] ?? 'N/A'}"),
          const Divider(height: 24, thickness: 0.5),
          _buildInfoRow(context, Icons.access_time_rounded, "End Time",
              "${_displayData['U_CK_EndTime'] ?? 'N/A'}"),
          const Divider(height: 24, thickness: 0.5),
          _buildInfoRow(context, Icons.category_rounded, "Job Type",
              _displayData['U_CK_JobType'] ?? 'N/A'),
          const Divider(height: 24, thickness: 0.5),
          _buildInfoRow(context, Icons.category_rounded, "Service Type",
              "${_displayData['U_CK_ServiceType'] ?? 'N/A'}"),
          const Divider(height: 24, thickness: 0.5),
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
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildNavChip(
                context, "Customer", Icons.person_rounded, _customerKey),
            _buildNavChip(
                context, "Services", Icons.room_service_rounded, _serviceKey),
            _buildNavChip(context, "Equipment",
                Icons.precision_manufacturing_rounded, _equipmentKey),
            _buildNavChip(
                context, "Activities", Icons.checklist_rounded, _activityKey),
            _buildNavChip(
                context, "Materials", Icons.inventory_2_rounded, _materialKey),
            _buildNavChip(context, "Time Logs",
                Icons.access_time_filled_rounded, _timeKey),
            _buildNavChip(
                context, "Issues", Icons.report_problem_rounded, _issueKey),
            _buildNavChip(
                context, "Checklist", Icons.fact_check_rounded, _checklistKey),
            _buildNavChip(
                context, "Files", Icons.attach_file_rounded, _attachmentKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavChip(
      BuildContext context, String label, IconData icon, GlobalKey key) {
    final bool isActive = _activeKey == key;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _scrollToSection(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF22C55E) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : const Color(0xFFF1F5F9),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF1E293B),
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
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context) {
    final contactList = _displayData['CustomerContact'] as List? ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayData['CustomerName'] ?? 'No Customer Name',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCustomerAddress(),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          if (contactList.isNotEmpty) ...[
            const Divider(height: 24),
            ...contactList.map((contact) {
              final String name = contact['Name'] ?? 'N/A';
              final String phone = contact['Phone1'] ?? 'N/A';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.phone_iphone_rounded,
                        size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        phone,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
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
      subtitleKey: 'U_CK_Effort',
      subtitlePrefix: 'Duration: ',
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "No attachments recorded.",
          style:
              GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final String? base64Data = file['data'];
            final String ext = (file['ext'] ?? 'png').toString().toLowerCase();
            if (base64Data == null) return const SizedBox();

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
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
                          color: const Color(0xFFFEE2E2),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFDC2626), size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  "Signature",
                                  style: GoogleFonts.inter(
                                    fontSize: 1,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.memory(
                        base64Decode(base64Data),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image_rounded)),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emptyMessage,
          style:
              GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: svgIcon != null
                    ? Center(
                        child: SvgPicture.asset(
                          svgIcon,
                          width: 22,
                          height: 22,
                          color: const Color(0xFF64748B),
                        ),
                      )
                    : Icon(icon, color: const Color(0xFF64748B), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item[titleKey]?.toString() ?? 'N/A',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customSubtitle != null
                          ? customSubtitle(item)
                          : "$subtitlePrefix${item[subtitleKey] ?? '0'}$subtitleSuffix",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
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
