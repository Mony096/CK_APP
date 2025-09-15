import 'package:bizd_tech_service/component/DatePicker.dart';
import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/text_remark.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/screens/equipment/select/businessPartnerPage.dart';
import 'package:bizd_tech_service/screens/equipment/equipmentImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class General extends StatefulWidget {
  const General({super.key, this.controller, required this.data});

  // Specify the type here
  final Map<String, dynamic>? controller;
  final Map<String, dynamic> data;

  @override
  State<General> createState() => _GeneralState();
}

class _GeneralState extends State<General> {
  List<dynamic> eqtype = ["Active", "Retired", "Suspended", "Inactive"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
                 bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          color: Colors.white,
          // borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 7),
              const ComponentTitle(
                label: "Infomation",
              ),
              const SizedBox(height: 8),
              // const SizedBox(height: 10),
              CustomTextField(
                  controller: widget.controller?['equipCode'],
                  label: 'Equipment Code',
                  star: true,
                  detail: widget.data.isNotEmpty
                  // icon: const Icon(Icons.qr_code_scanner,
                  //     color: Colors.grey),
                  // onclickIcon: () {
                  //   print("Scan icon tapped!");
                  // },
                  ),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['equipName'],
                  label: 'Equipment Name',
                  star: true,
                  detail: widget.data.isNotEmpty

                  // icon: const Icon(Icons.qr_code_scanner,
                  //     color: Colors.grey),
                  // onclickIcon: () {
                  //   print("Scan icon tapped!");
                  // },
                  ),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['customerName'],
                  label: 'Customer',
                  star: true,
                  readOnly: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                    size: 28,
                  ),
                  onclickIcon: () {
                    _customerSelect();
                  },
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['equipType'],
                  label: 'Status',
                  star: true,
                  readOnly: true, // 👈 new usage

                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 28,
                  ),
                  onclickIcon: () {
                    _equipmentTypeSelect();
                  },
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['site'],
                  label: 'Site',
                  star: false,
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['brand'],
                  label: 'Brand',
                  star: true,
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: widget.controller?['serialNumber'],
                  label: 'Serial Number',
                  star: true,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset('images/svg/document-barcode.svg',
                        width: 10,
                        height: 10,
                        color: const Color.fromARGB(255, 159, 161, 166)),
                  ),
                  onclickIcon: () {
                    _scanBarcode(context);
                  },
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 8),
              CustomTextRemark(
                controller: widget.controller?['remark'],
                label: 'Remark',
                detail: widget.data.isNotEmpty,
                star: false,
              ),
              const SizedBox(height: 28),
              const ComponentTitle(
                label: "Date & images",
              ),
              const SizedBox(height: 10),
              // CustomTextField(
              //     controller: widget.controller?['uploadImg'],
              //     label: 'Upload Image',
              //     star: true,
              //     icon: const Icon(
              //       Icons.image,
              //       color: Colors.grey,
              //       size: 28,
              //     ),
              //     onclickIcon: () {
              //       goTo(context, EquipmentImageScreen(data: {})).then((e) {
              //         // Handle any actions after returning from ServiceEntryScreen
              //       });
              //       return;
              //     },
              //     detail: false),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  onPressed: () {
                    goTo(context, EquipmentImageScreen(data: widget.data))
                        .then((e) {});
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    widget.data.isNotEmpty
                        ? "View ( ${context.read<EquipmentCreateProvider>().imagesList.length} / Image )"
                        : "Add Image",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              CustomDatePickerField(
                  label: 'Installed Date',
                  star: true,
                  controller: widget.controller?['installedDate'],
                  detail: widget.data.isNotEmpty),
              const SizedBox(height: 10),
              CustomDatePickerField(
                  label: 'Next Service Date',
                  star: false,
                  controller: widget.controller?['nextDate'],
                  detail: widget.data.isNotEmpty),

              const SizedBox(height: 10),

              CustomDatePickerField(
                  label: 'Warranty Expire Date',
                  star: true,
                  controller: widget.controller?['warrantyDate'],
                  detail: widget.data.isNotEmpty),
            ],
          ),
        ),
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
                // customerCode.text = getDataFromDynamic(value["CardCode"]);
                // customerName.text = getDataFromDynamic(value["CardName"]);
              })
            }
        });
  }
}
