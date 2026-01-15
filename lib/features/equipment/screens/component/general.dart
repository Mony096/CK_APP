import 'package:bizd_tech_service/core/widgets/DatePicker.dart';
import 'package:bizd_tech_service/core/widgets/text_field.dart';
import 'package:bizd_tech_service/core/widgets/text_remark.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/equipment/screens/select/businessPartnerPage.dart';
import 'package:bizd_tech_service/features/equipment/screens/equipmentImage.dart';
import 'package:bizd_tech_service/features/equipment/screens/select/siteMasterPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class General extends StatefulWidget {
  const General({super.key, this.controller, required this.data});

  final Map<String, dynamic>? controller;
  final Map<String, dynamic> data;

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  List<dynamic> eqtype = ["Active", "Retired", "Suspended", "Inactive"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormSection(
            title: "Equipment Details",
            icon: Icons.info_outline_rounded,
            children: [
              CustomTextField(
                controller: widget.controller?['equipCode'],
                label: 'Equipment Code',
                star: true,
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Equipment Name',
                star: true,
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: widget.controller?['customerName'],
                label: 'Customer',
                star: true,
                readOnly: true,
                icon: const Icon(Icons.keyboard_arrow_right,
                    color: Colors.grey, size: 24),
                onclickIcon: _customerSelect,
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: widget.controller?['site'],
                label: 'Site',
                star: true,
                readOnly: true,
                icon: widget.controller?['customerCode'].text != ""
                    ? const Icon(Icons.keyboard_arrow_right,
                        color: Colors.grey, size: 24)
                    : null,
                onclickIcon: _siteSelect,
                detail: widget.data.isNotEmpty,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormSection(
            title: "Identification",
            icon: Icons.qr_code_rounded,
            children: [
              CustomTextField(
                controller: widget.controller?['brand'],
                label: 'Brand',
                star: true,
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: widget.controller?['serialNumber'],
                label: 'Serial Number',
                star: true,
                icon: Icon(Icons.camera_alt_outlined,
                    color: Colors.grey.shade500, size: 22),
                onclickIcon: () => _scanBarcode(context),
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: widget.controller?['equipType'],
                label: 'Status',
                star: true,
                readOnly: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey, size: 24),
                onclickIcon: _equipmentTypeSelect,
                detail: widget.data.isNotEmpty,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormSection(
            title: "Dates & Imagery",
            icon: Icons.event_note_rounded,
            children: [
              CustomDatePickerField(
                label: 'Installed Date',
                star: true,
                controller: widget.controller?['installedDate'],
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomDatePickerField(
                label: 'Warranty Expire Date',
                star: true,
                controller: widget.controller?['warrantyDate'],
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 12),
              CustomDatePickerField(
                label: 'Next Service Date',
                star: false,
                controller: widget.controller?['nextDate'],
                detail: widget.data.isNotEmpty,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF425364), const Color(0xFF334155)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF425364).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    goTo(context, EquipmentImageScreen(data: widget.data))
                        .then((e) {});
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.data.isNotEmpty
                            ? "View Images"
                            : "Manage Images",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextRemark(
                controller: widget.controller?['remark'],
                label: 'Remarks',
                detail: widget.data.isNotEmpty,
                star: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF425364)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF425364),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _scanBarcode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Icon(
                Icons.camera_alt, // Use an appropriate icon
                color: Color.fromARGB(255, 33, 46, 57),
                size: 24,
              ),
              SizedBox(width: 8), // Space between icon and text
              Text(
                'Scanning Serial Number...',
                textScaleFactor: 1.0,
                style: TextStyle(
                  fontSize: 17,
                  // fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.black, // Set a suitable color
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
              final barcode = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.rawValue
                  : 'Unknown';
              setState(() {
                widget.controller?['serialNumber'].text = barcode!;
              });
              Navigator.pop(context); // Close the dialog
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Adjust radius here
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text(
              'Cancel',
              textScaleFactor: 1.0,
              style: TextStyle(
                fontSize: 15,
                // fontWeight: FontWeight.bold, // Make the text bold
                color: Color.fromARGB(255, 65, 66, 67), // Set a suitable color
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _equipmentTypeSelect() async {
    final selectedValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.task_outlined,
                  color: Colors.blueGrey[800],
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          content: Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 219, 221, 224), width: 1))),
            // color: Colors.red,
            width: double.maxFinite, // Use full width of the dialog
            constraints: const BoxConstraints(
              maxHeight: 300, // Limit the height to prevent overflow
            ),
            child: ListView(
              shrinkWrap: true,
              children: eqtype.asMap().entries.map((entry) {
                var item = entry.value;

                return TextButton(
                  onPressed: () {
                    Navigator.pop(context, item);
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(10), // Add top padding of 10
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment
                        .centerLeft, // Ensure the button itself aligns to the left
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft, // Align text to the left
                    child: Text(
                      item, // Use index if needed
                      style: const TextStyle(
                          color: Color.fromARGB(255, 72, 73, 75),
                          fontWeight:
                              FontWeight.normal // Set text color to black
                          ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 4.0,
        );
      },
    );
    if (selectedValue != null) {
      setState(() {
        widget.controller?["equipType"].text = selectedValue;
      });
    }
  }

  void _customerSelect() async {
    goTo(context, const BusinessPartnerPage()).then((value) => {
          if (value != null)
            {
              setState(() {
                print(value);
                widget.controller?["customerCode"].text =
                    getDataFromDynamic(value["CardCode"]);
                widget.controller?["customerName"].text =
                    getDataFromDynamic(value["CardName"]);
                widget.controller?["site"].text = "";
                // customerCode.text = getDataFromDynamic(value["CardCode"]);
                // customerName.text = getDataFromDynamic(value["CardName"]);
              })
            }
        });
  }

  void _siteSelect() async {
    goTo(
        context,
        SiteMasterPage(
          customer: widget.controller?["customerCode"].text,
        )).then((value) => {
          if (value != null)
            {
              setState(() {
                print(value);
                widget.controller?["site"].text =
                    getDataFromDynamic(value["Code"]);
              })
            }
        });
  }
}
