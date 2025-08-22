import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/text_remark.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/screens/equipment/select/businessPartnerPage.dart';
import 'package:flutter/material.dart';

class General extends StatefulWidget {
  const General({super.key, this.controller});

  // Specify the type here
  final Map<String, dynamic>? controller;

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
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12),
            topLeft: Radius.circular(12),
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
                // icon: const Icon(Icons.qr_code_scanner,
                //     color: Colors.grey),
                // onclickIcon: () {
                //   print("Scan icon tapped!");
                // },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['customerCode'],
                label: 'Customer',
                star: true,
                icon: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  _customerSelect();
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipType'],
                label: 'Status',
                star: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  _equipmentTypeSelect();
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['site'],
                label: 'Site',
                star: false,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['brand'],
                label: 'Brand',
                star: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['serialNumber'],
                label: 'Serial Number',
                star: true,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.grey,
                  size: 25,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 8),
              CustomTextRemark(
                controller: widget.controller?['remark'],
                label: 'Remark',
              ),
              const SizedBox(height: 28),
              const ComponentTitle(
                label: "Date & images",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['uploadImg'],
                label: 'Upload Image',
                star: true,
                icon: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['installedDate'],
                label: 'Installed Date',
                star: true,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['nextDate'],
                label: 'Next Service Date',
                star: false,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['warrantyDate'],
                label: 'Warranty Expire Date',
                star: true,
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.grey,
                  size: 28,
                ),
                onclickIcon: () {
                  print("Scan icon tapped!");
                },
              ),
            ],
          ),
        ),
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
                // customerCode.text = getDataFromDynamic(value["CardCode"]);
                // customerName.text = getDataFromDynamic(value["CardName"]);
              })
            }
        });
  }
}
