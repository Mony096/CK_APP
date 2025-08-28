import 'package:bizd_tech_service/screens/service/component/detail_row.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceByIdScreen extends StatefulWidget {
  const ServiceByIdScreen({super.key});

  @override
  __ServiceByIdScreenState createState() => __ServiceByIdScreenState();
}

class __ServiceByIdScreenState extends State<ServiceByIdScreen> {
  @override
  List<dynamic> myTravel = [{}, {}, {}];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 83, 100),
        // Leading menu icon on the left
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            // Handle menu button press or keep it empty for default Drawer action
          },
        ),
        // Centered title
        title: const Center(
          child: Text('Service Infomation',
              style: TextStyle(fontSize: 17, color: Colors.white),
              textScaleFactor: 1.0),
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
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: const Center(
                              child: Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          ))),
                      const Text("- - - - - - -",
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
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: const Center(
                              child: Icon(
                            Icons.car_crash,
                            color: Colors.white,
                          ))),
                      const Text("- - - - - - -",
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
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'images/svg/key.svg',
                              width: 23,
                              height: 23,
                            ),
                          )),
                      const Text("- - - - - - -",
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
                              color: const Color.fromARGB(255, 255, 255,
                                  255), // Optional: Add a border if needed
                              width: 2.0, // Border width
                            ),
                          ),
                          child: const Center(
                              child: Icon(
                            Icons.flag,
                            color: Colors.white,
                          ))),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    border: Border.all(
                      color: Colors.green, // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: ListView(children: [
                    SizedBox(
                      // margin: EdgeInsets.only(bottom: 1),
                      width: double.infinity,
                      height: 240,
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
                                        padding:
                                            const EdgeInsets.fromLTRB(4, 10, 4, 10),
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
                                          padding:
                                              EdgeInsets.only(right: 10),
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
                            height: 130,
                            padding: const EdgeInsets.all(10),
                            color: const Color.fromARGB(255, 66, 83, 100),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Date : Monday , January 15",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.5),
                                                  textScaleFactor: 1.0),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text("Time 04:30 - 06:30",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.5),
                                                  textScaleFactor: 1.0),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                width: 100,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    // Define your button's action here
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                  ),
                                                  child: const Text("Repair",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                      textScaleFactor: 1.0),
                                                ),
                                              ),
                                            ],
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Thomas Wagner",
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              color: Colors.white),
                                          textScaleFactor: 1.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        child: const Center(
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.green,
                        size: 30,
                      ),
                    )),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width:
                                          45, // Ensure the width and height are equal for a perfect circle

                                      child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.build,
                                            size: 25,
                                          )),
                                    )
                                  ],
                                ),
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("The Pizza Comapny - Sen Sok",
                                          style: TextStyle(fontSize: 12.5),
                                          textScaleFactor: 1.0),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text("SN: 10003000400",
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            height: 2,
                                          ),
                                          textScaleFactor: 1.0),
                                    ],
                                  ))),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ), ////
                    const SizedBox(
                      height: 2,
                    ),
                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/building.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Customer :",
                      row1: "The Pizza Company",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/contact.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Contact :",
                      row1: "Mr. Jossep Alpha",
                      row2: "092 555 444",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/dolla.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Service :",
                      row1: "A/C Cleaning",
                      rowRight1: "USD 50.00",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const DetailRow(
                      svg: Icon(
                        Icons.build,
                        size: 25,
                      ),
                      title: "Equipment",
                      row1: "Equipment Name",
                      rowRight1: "SN: 100020000300",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/activity.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Activity :",
                      row1: "Activity Name 1",
                      isRowRight1Icon: true,
                      rowRight1: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/task_check.svg',
                        width: 25,
                        height: 25,
                      ),
                      row2: "Activity Name 2",
                      isRowRight2Icon: true,
                      rowRight2: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/task_check.svg',
                        width: 25,
                        height: 25,
                      ),
                      row3: "Activity Name 3",
                      isRowRight3Icon: true,
                      rowRight3: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/task_check.svg',
                        width: 25,
                        height: 25,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/material.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Material Reserve",
                      row1: "Material Item 1",
                      rowRight1: "10",
                      row2: "Material Item 2",
                      rowRight2: "20",
                      row3: "Material Item 3",
                      rowRight3: "30",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DetailRow(
                      svg: SvgPicture.asset(
                        color: Colors.black,
                        'images/svg/tool.svg',
                        width: 30,
                        height: 30,
                      ),
                      title: "Tool & Assets",
                      row1: "Tools Item 1",
                      rowRight1: "2",
                      row2: "Tools Item 2",
                      rowRight2: "1",
                      row3: "Tools Item 3",
                      rowRight3: "2",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      children: [
                        SizedBox(
                          width: 27,
                        ),
                        Icon(
                          Icons.warning_rounded,
                          size: 25,
                          color: Colors.red,
                        )
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 5, 10),
                      child: Text("Service task remark for technician",
                          style: TextStyle(fontSize: 12.5),
                          textScaleFactor: 1.0),
                    ),
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      height: 70,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container()),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Define your button's action here
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: const Text("Reject",
                                  style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 255, 255, 255),
                                      fontSize: 12),
                                  textScaleFactor: 1.0),
                            ),
                          ),
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
                              child: const Text("Accept",
                                  style: TextStyle(
                                      color: Color.fromARGB(
                                          255, 255, 255, 255),
                                      fontSize: 12),
                                  textScaleFactor: 1.0),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    )
                    /////do somthing
                  ]),
                )),
              ],
            )),
      ),
      // bottomNavigationBar: Container(
      //   color: const Color.fromARGB(255, 255, 255, 255),
      //   height: 70,
      //   padding: const EdgeInsets.all(12),
      //   child: Row(
      //     children: [
      //     Expanded(flex: 2,child: Container()),
      //       Expanded(
      //         child: TextButton(
      //           onPressed: () {
      //             // Define your button's action here
      //           },
      //           style: TextButton.styleFrom(
      //             backgroundColor: Colors.red,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(5.0),
      //             ),
      //           ),
      //           child: Text(
      //             "Reject",
      //             style: TextStyle(
      //                 color: const Color.fromARGB(255, 255, 255, 255),
      //                 fontSize: 13),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //       Expanded(
      //         child: TextButton(
      //           onPressed: () {
      //             // Define your button's action here
      //           },
      //           style: TextButton.styleFrom(
      //             backgroundColor: Color.fromARGB(255, 33, 107, 243),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(5.0),
      //             ),
      //           ),
      //           child: Text(
      //             "Accept",
      //             style: TextStyle(
      //                 color: const Color.fromARGB(255, 255, 255, 255),
      //                 fontSize: 13),
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 12),
      //     ],
      //   ),
      // ),
    );
  }
}
