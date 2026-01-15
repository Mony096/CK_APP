import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MaterialReserveScreen extends StatefulWidget {
  const MaterialReserveScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _MaterialReserveScreenState createState() => _MaterialReserveScreenState();
}

class _MaterialReserveScreenState extends State<MaterialReserveScreen> {
  final numberQty = NumberFormat("#,##0", "en_US");
  void _showDetail(data) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.green, size: 25),
                    SizedBox(width: 10),
                    Text(
                      "Material Reserve",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                    thickness: 1, color: Color.fromARGB(255, 213, 215, 217)),
                // const SizedBox(height: 5),

                // Items
                _buildRow("Item Code", "${data["U_CK_ItemCode"] ?? "N/A"}"),
                _buildRow("Item Name", "${data["U_CK_ItemName"] ?? "N/A"}"),
                _buildRow("UoM Code", "${data["U_CK_UoM"] ?? "N/A"}"),
                _buildRow("Quantiy", "${data["U_CK_Qty"] ?? "N/A"}"),

                const SizedBox(height: 20),

                // Action button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 213, 215, 217), // light grey
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 13, 0, 10), // spacing inside
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // fixed width for labels
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5, // line height for label
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                height:
                    1.8, // 👈 line height (10px if font size=10, scale accordingly)
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Material Reserve',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // Status Stepper
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Service Info Card
                      ServiceInfoCard(data: widget.data),
                      const SizedBox(height: 16),
                    //endddddddddddddddddddddddddddddddddd
                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                      title: 'Material Reserve',
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          'images/svg/material.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    (widget.data["CK_JOB_MATERIALCollection"] as List<dynamic>)
                            .isNotEmpty
                        ? Container()
                        : Container(
                            height: 90,
                            padding: const EdgeInsets.all(13),
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.white,
                            child: const Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Icon(
                                    Icons.warning,
                                    size: 25,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "No Material Reserved Available",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 122, 126, 130)),
                                    textScaleFactor: 1.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ...(widget.data["CK_JOB_MATERIALCollection"]
                            as List<dynamic>)
                        .map(
                      (item) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            bool isChecked = item["U_CK_Checked"] ==
                                true; // or use another field

                            return DetailMenu(
                              onTap: () => _showDetail(item),
                              title: item["U_CK_ItemCode"] ?? "N/A",
                              name: item["U_CK_ItemName"] ?? "N/A",
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Checkbox(
                                  value: true,
                                  activeColor: Colors.green,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      item["U_CK_Checked"] = value;
                                    });
                                  },
                                ),
                              ),
                              desc: 'Res.Qty | N/A',
                              qty: '${numberQty.format(
                                double.tryParse(item["U_CK_Qty"].toString()) ??
                                    0,
                              )} ',
                            );
                          },
                        );
                      },
                    )

                    /////do somthing
                  ]),
                ),
              ],
            )),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title});
  final dynamic icon;
  final String title;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
           ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              widget.icon,
              const SizedBox(width: 12),
              Text(widget.title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.blueGrey.shade800
                  )
              )
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.green)
        ],
      ),
    );
  }
}

class DetailMenu extends StatefulWidget {
  DetailMenu(
      {super.key,
      this.icon,
      required this.title,
      required this.desc,
      required this.name,
      this.onTap,
      this.qty});
  final dynamic icon;
  final String title;
  final String name;
  final String desc;
  final dynamic qty;
  VoidCallback? onTap;

  @override
  State<DetailMenu> createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              widget.icon,
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade800),
                            ),
                          ),
                          Text(
                            "Usage Qty",
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.name,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black87),
                            ),
                          ),
                          Text(
                            widget.qty,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            widget.desc,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
