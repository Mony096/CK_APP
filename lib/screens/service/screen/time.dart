import 'package:bizd_tech_service/component/text_time_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  @override
  final List<dynamic> times = [];
  int updateIndexTime = -1;
  int isEditTime = -1;
  int isAdded = 0;
  final travelTime = TextEditingController();
  final travelEndTime = TextEditingController();
  final ServiceTime = TextEditingController();
  final ServiceEndTime = TextEditingController();
  final breakTime = TextEditingController();
  final breakEndTime = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> codeFieldNotifier =
      ValueNotifier({"missing": false, "value": "Code required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> nameFieldNotifier =
      ValueNotifier({"missing": false, "value": "Name required", "isAdded": 0});

  final ValueNotifier<Map<String, dynamic>> partFieldNotifier =
      ValueNotifier({"missing": false, "value": "Part required", "isAdded": 0});

  final ValueNotifier<Map<String, dynamic>> brandFieldNotifier = ValueNotifier(
      {"missing": false, "value": "Brand required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> modelFieldNotifier = ValueNotifier(
      {"missing": false, "value": "Model required", "isAdded": 0});
  void _showCreateTime() async {
    await showDialog<String>(
      barrierDismissible: false, // user must tap button!

      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          content: Container(
              padding: const EdgeInsets.only(top: 7),
              width: double.maxFinite, // Use full width of the dialog
              constraints: const BoxConstraints(
                maxHeight: 427, // Limit the height to prevent overflow
              ),
              child: Container(
                  child: ListView(
                children: [
                   const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Travel Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'Start Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'End Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Service Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'Start Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'End Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                        const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 21,
                            color: Color.fromARGB(255, 89, 89, 91),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Break Time",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                      Icon(Icons.arrow_drop_down,
                          size: 24, color: Color.fromARGB(255, 89, 89, 91))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'Start Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                      const SizedBox(
                        width: 13,
                      ),
                      Expanded(
                        child: CustomTimeFieldDialog(
                          isMissingFieldNotifier: codeFieldNotifier,
                          controller: travelTime,
                          label: 'End Time',
                          star: true,
                          // focusNode: codeFocusNode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditTime = -1;
                          });
                          // clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                              color: Color.fromARGB(255, 66, 83, 100)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            // if (onConfirm != null) {
                            //   onConfirm();
                            // }
                            // if (code.text.isEmpty ||
                            //     name.text.isEmpty ||
                            //     part.text.isEmpty ||
                            //     brand.text.isEmpty ||
                            //     model.text.isEmpty) {
                            //   codeFieldNotifier.value = {
                            //     "missing": code.text.isEmpty,
                            //     "value": "Code is required!",
                            //     "isAdded": 1,
                            //   };
                            //   nameFieldNotifier.value = {
                            //     "missing": name.text.isEmpty,
                            //     "value": "Name is required!",
                            //     "isAdded": 1,
                            //   };
                            //   partFieldNotifier.value = {
                            //     "missing": part.text.isEmpty,
                            //     "value": "Part is required!",
                            //     "isAdded": 1,
                            //   };

                            //   brandFieldNotifier.value = {
                            //     "missing": brand.text.isEmpty,
                            //     "value": "Brand is required!",
                            //     "isAdded": 1,
                            //   };
                            //   modelFieldNotifier.value = {
                            //     "missing": model.text.isEmpty,
                            //     "value": "Model is required!",
                            //     "isAdded": 1,
                            //   };
                            //   return;
                            // }

                            // _onAddComponent(context);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 66, 83, 100),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            // Adjust the padding to make the button smaller
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(
                              // isEditComp >= 0 ? "Edit" : "Add",
                              "Add Time",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ))),
          backgroundColor: Colors.white,
          elevation: 4.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 238, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // Centered title
        title: const Center(
          child: Text(
            'Time Entry',
            style: TextStyle(fontSize: 17, color: Colors.white),
            textScaleFactor: 1.0,
          ),
        ),
        // Right-aligned actions (scan barcode)
        actions: [
          IconButton(
            icon: const Row(
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.qr_code_scanner, color: Colors.white),
              ],
            ),
            onPressed: () {
              // Handle scan barcode action
            },
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
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: 80,
                  color: const Color.fromARGB(255, 66, 83, 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 66, 83, 100),
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Accept" ||
                                      widget.data["U_CK_Status"] == "Travel" ||
                                      widget.data["U_CK_Status"] == "Service" ||
                                      widget.data["U_CK_Status"] == "Entry"
                                  ? Colors.green
                                  : Colors
                                      .white, // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Center(
                              child: Icon(
                            Icons.check,
                            size: 20,
                            color: widget.data["U_CK_Status"] == "Accept" ||
                                    widget.data["U_CK_Status"] == "Travel" ||
                                    widget.data["U_CK_Status"] == "Service" ||
                                    widget.data["U_CK_Status"] == "Entry"
                                ? Colors.green
                                : Colors.white,
                          ))),
                      const Text("- - - - -",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: Colors.white),
                          textScaleFactor: 1.0),
                      Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 66, 83, 100),
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Travel" ||
                                      widget.data["U_CK_Status"] == "Service" ||
                                      widget.data["U_CK_Status"] == "Entry"
                                  ? Colors.green
                                  : Colors
                                      .white, // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Center(
                              child: Icon(
                            Icons.car_crash,
                            color: widget.data["U_CK_Status"] == "Travel" ||
                                    widget.data["U_CK_Status"] == "Service" ||
                                    widget.data["U_CK_Status"] == "Entry"
                                ? Colors.green
                                : Colors.white,
                          ))),
                      const Text("- - - - -",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: Colors.white),
                          textScaleFactor: 1.0),
                      Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 66, 83, 100),
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Service" ||
                                      widget.data["U_CK_Status"] == "Entry"
                                  ? Colors.green
                                  : Colors
                                      .white, // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset('images/svg/key.svg',
                                width: 23,
                                height: 23,
                                color: widget.data["U_CK_Status"] ==
                                            "Service" ||
                                        widget.data["U_CK_Status"] == "Entry"
                                    ? Colors.green
                                    : Colors.white),
                          )),
                      const Text("- - - - -",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              color: Colors.white),
                          textScaleFactor: 1.0),
                      Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 66, 83, 100),
                            shape:
                                BoxShape.circle, // Makes the container circular
                            border: Border.all(
                              color: widget.data["U_CK_Status"] == "Entry"
                                  ? Colors.green
                                  : Colors
                                      .white, // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Center(
                              child: Icon(Icons.flag,
                                  color: widget.data["U_CK_Status"] == "Entry"
                                      ? Colors.green
                                      : Colors.white))),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(255, 255, 255, 255),

                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: ListView(children: [
                    Container(
                      // margin: EdgeInsets.only(bottom: 1),
                      padding: const EdgeInsets.only(bottom: 6),
                      width: double.infinity,
                      // height: 250,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        border: Border.all(
                          color: Colors.green, // Border color
                          width: 1.0, // Border width
                        ),
                        borderRadius:
                            BorderRadius.circular(5.0), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 45,
                                            width:
                                                45, // Ensure the width and height are equal for a perfect circle
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape
                                                  .circle, // Makes the container circular
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255,
                                                    79,
                                                    78,
                                                    78), // Optional: Add a border if needed
                                                width: 1.0, // Border width
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                'images/svg/key.svg',
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                Expanded(
                                    flex: 4,
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 10, 4, 10),
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("The Pizza Comapny - Sen Sok",
                                                style:
                                                    TextStyle(fontSize: 12.5),
                                                textScaleFactor: 1.0),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                                "#23, Street 598 -Khan Sen Sok Phnom Penh, Cambodia",
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  height: 2,
                                                ),
                                                textScaleFactor: 1.0),
                                          ],
                                        ))),
                                const Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: Text("SVT00001",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13),
                                              textScaleFactor: 1.0),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Container(
                              // height: 150,
                              padding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 15),
                              color: const Color.fromARGB(255, 66, 83, 100),
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: SvgPicture.asset(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            'images/svg/dolla.svg',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text("Service:",
                                                          style: TextStyle(
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  Expanded(
                                                      child: Text("Status:",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                          "A/C Cleaning",
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  Expanded(
                                                      child: Text("Open",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.build,
                                              color: Colors.white,
                                              size: 25,
                                            )),
                                      ),
                                      Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text("Equipment:",
                                                          style: TextStyle(
                                                              fontSize: 13.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  Expanded(
                                                      child: Text("",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white))),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                          "Equipment Name",
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  Expanded(
                                                      child: Text(
                                                          "SN: 10002000300",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              color:
                                                                  Colors.white),
                                                          textScaleFactor:
                                                              1.0)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ), //

                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                      title: 'Thomas Wager',
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          'images/svg/clock.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      date: 'Monday, Jan 01',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DetailTime(
                      onTap: _showCreateTime,
                    ),
                    /////do somthing
                  ]),
                )),
              ],
            )),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title, required this.date});
  final dynamic icon;
  final String title;
  final String date;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 1, child: widget.icon),
          Expanded(
              flex: 4,
              child: Text(
                textScaleFactor: 1.0,
                widget.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              )),
          Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  textScaleFactor: 1.0,
                  widget.date,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              )),
        ],
      ),
    );
  }
}

class DetailTime extends StatefulWidget {
  const DetailTime({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;

  @override
  State<DetailTime> createState() => _DetailTimeState();
}

class _DetailTimeState extends State<DetailTime> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(13),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        textScaleFactor: 1.0,
                        "Travel Time:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Start Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "08:00",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("End Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "09:00",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(
                          textScaleFactor: 1.0,
                          "Eff.T",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "1 Hr",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    )),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        textScaleFactor: 1.0,
                        "Service Time:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Start Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "09:00",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("End Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "10:00",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          "1 Hr",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    )),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        textScaleFactor: 1.0,
                        "Break Time:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Start Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "12:30",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("End Time:",
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey, // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(
                                3.0), // Optional: Rounded corners
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Text(
                                  "01:00",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ),
                              SvgPicture.asset(
                                color: const Color.fromARGB(255, 29, 30, 29),
                                'images/svg/schedule.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text(
                          "1 Hr",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    )),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              height: 70,
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 10),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Container()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onTap,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        "Add Time",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ));
  }
}
