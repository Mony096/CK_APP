import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/screens/service/screen/image.dart';
import 'package:bizd_tech_service/screens/service/screen/materialReserve.dart';
import 'package:bizd_tech_service/screens/service/screen/openIssue.dart';
import 'package:bizd_tech_service/screens/service/screen/serviceCheckList.dart';
import 'package:bizd_tech_service/screens/service/screen/signature.dart';
import 'package:bizd_tech_service/screens/service/screen/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  __ServiceEntryScreenState createState() => __ServiceEntryScreenState();
}

class __ServiceEntryScreenState extends State<ServiceEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 238, 240),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            // Handle menu button press or keep it empty for default Drawer action
          },
        ),
        // Centered title
        title: Center(
          child: Text(
            'Service Entry',
            style: TextStyle(fontSize: 17, color: Colors.white),
            textScaleFactor: 1.0,
          ),
        ),
        // Right-aligned actions (scan barcode)
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // refresh();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              // SizedBox(width: 3),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.white),
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: 80,
                  color: Color.fromARGB(255, 66, 83, 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: 37,
                          height: 37,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 66, 83, 100),
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
                            color: Color.fromARGB(255, 66, 83, 100),
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
                            color: Color.fromARGB(255, 66, 83, 100),
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
                            color: Color.fromARGB(255, 66, 83, 100),
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
                SizedBox(
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
                      padding: EdgeInsets.only(bottom: 6),
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
                          Container(
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
                                        padding:
                                            EdgeInsets.fromLTRB(4, 10, 4, 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "The Pizza Comapny - Sen Sok",
                                              style: TextStyle(fontSize: 12.5),
                                              textScaleFactor: 1.0,
                                            ),
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
                                              textScaleFactor: 1.0,
                                            ),
                                          ],
                                        ))),
                                Expanded(
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
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            "SVT00001",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                            textScaleFactor: 1.0,
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Container(
                              // height: 150,
                              padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                              color: Color.fromARGB(255, 66, 83, 100),
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
                                      Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Text(
                                                    "Service:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13.5),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "Status:",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13.5,
                                                        color: Colors.white),
                                                    textScaleFactor: 1.0,
                                                  )),
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
                                                        color: Colors.white,
                                                        fontSize: 12.5),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "Open",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.5),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 6),
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
                                                      child: Text(
                                                    "Equipment:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 13.5),
                                                    textScaleFactor: 1.0,
                                                  )),
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
                                                        color: Colors.white,
                                                        fontSize: 12.5),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "SN: 10002000300",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontSize: 12.5,
                                                        color: Colors.white),
                                                    textScaleFactor: 1.0,
                                                  )),
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
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(
                            context,
                            ServiceCheckListScreen(
                              data: widget.data,
                            ));
                      },
                      child: Menu(
                        title: 'Checklist',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/activity.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(
                            context,
                            MaterialReserveScreen(
                              data: widget.data,
                            ));
                      },
                      child: Menu(
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
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(
                            context,
                            ImageScreen(
                              data: widget.data,
                            ));
                      },
                      child: Menu(
                        title: 'Image',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/image.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(context, TimeScreen(data: widget.data));
                      },
                      child: Menu(
                        title: 'Time Entry',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/clock.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(context, SignatureScreen(data: widget.data));
                      },
                      child: Menu(
                        title: 'Signature',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/signature.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        goTo(context, OpenIssueScreen(data: widget.data));
                      },
                      child: Menu(
                        title: 'Open Issue',
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            'images/svg/report.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    /////do somthing
                    SizedBox(
                      height: 7,
                    ),
                  ]),
                )),
              ],
            )),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        height: 70,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Container()),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () {
                  // Define your button's action here
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: Text(
                  "Complete",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
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
      padding: EdgeInsets.all(13),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(flex: 1, child: widget.icon),
          Expanded(
              flex: 6,
              child: Text(
                widget.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textScaleFactor: 1.0,
              )),
          Expanded(
              flex: 1,
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 30,
              )),
        ],
      ),
    );
  }
}
