import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/screens/service/screen/serviceById.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class BlockService extends StatelessWidget {
  const BlockService({super.key, this.onTap, required this.data});
  final VoidCallback? onTap;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 370,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 133, 136, 138).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(
          color: Colors.green, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(5.0), // Rounded corners
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              width: double.infinity,
              child: Row(
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
                                color: Colors.green, /////////Icon Right
                                shape: BoxShape
                                    .circle, // Makes the container circular
                                border: Border.all(
                                  color: const Color.fromARGB(255, 79, 78,
                                      78), // Optional: Add a border if needed
                                  width: 1.0, // Border width
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  'images/svg/key.svg',
                                  width: 30,
                                  height: 30,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 4,
                      child: Container(
                          // decoration: const BoxDecoration(
                          //   border: Border(
                          //     left: BorderSide(
                          //       color: Color.fromARGB(255, 108, 110, 112),
                          //       width: 0.5,
                          //     ),
                          //   ),
                          // ),
                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["CustomerName"] ?? "N/A",
                                style: const TextStyle(fontSize: 12.5),
                                textScaleFactor: 1.0,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ((data["CustomerAddress"] as List?)
                                            ?.isNotEmpty ==
                                        true)
                                    ? (data["CustomerAddress"]
                                            .first["StreetNo"] ??
                                        "N/A")
                                    : "N/A",
                                style: const TextStyle(
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "No: ",
                                  style: TextStyle(fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                                Text(
                                  "${data["DocNum"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  textScaleFactor: 1.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: const Color.fromARGB(255, 66, 83, 100),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 37,
                                height: 37,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 66, 83, 100),
                                  shape: BoxShape
                                      .circle, // Makes the container circular
                                  border: Border.all(
                                    color: data["U_CK_Status"] == "Accept" ||
                                            data["U_CK_Status"] == "Travel" ||
                                            data["U_CK_Status"] == "Service" ||
                                            data["U_CK_Status"] == "Entry"
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
                                  color: data["U_CK_Status"] == "Accept" ||
                                          data["U_CK_Status"] == "Travel" ||
                                          data["U_CK_Status"] == "Service" ||
                                          data["U_CK_Status"] == "Entry"
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
                                  shape: BoxShape
                                      .circle, // Makes the container circular
                                  border: Border.all(
                                    color: data["U_CK_Status"] == "Travel" ||
                                            data["U_CK_Status"] == "Service" ||
                                            data["U_CK_Status"] == "Entry"
                                        ? Colors.green
                                        : Colors
                                            .white, // Optional: Add a border if needed
                                    width: 2.0, // Border width
                                  ),
                                ),
                                child: Center(
                                    child: Icon(
                                  Icons.car_crash,
                                  color: data["U_CK_Status"] == "Travel" ||
                                          data["U_CK_Status"] == "Service" ||
                                          data["U_CK_Status"] == "Entry"
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
                                  shape: BoxShape
                                      .circle, // Makes the container circular
                                  border: Border.all(
                                    color: data["U_CK_Status"] == "Service" ||
                                            data["U_CK_Status"] == "Entry"
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
                                      color: data["U_CK_Status"] == "Service" ||
                                              data["U_CK_Status"] == "Entry"
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
                                  shape: BoxShape
                                      .circle, // Makes the container circular
                                  border: Border.all(
                                    color: data["U_CK_Status"] == "Entry"
                                        ? Colors.green
                                        : Colors
                                            .white, // Optional: Add a border if needed
                                    width: 2.0, // Border width
                                  ),
                                ),
                                child: Center(
                                    child: Icon(Icons.flag,
                                        color: data["U_CK_Status"] == "Entry"
                                            ? Colors.green
                                            : Colors.white))),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 19,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                                "${data["U_CK_Time"]} - ${data["U_CK_EndTime"]}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                textScaleFactor: 1.0),
                          ],
                        ),
                      )),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        width: 100,
                        height: 35,
                        margin: EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            // Define your button's action here
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text("${data["U_CK_JobType"] ?? "N/A"}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              textScaleFactor: 1.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          goTo(context, ServiceByIdScreen(data: data));
                        },
                        child:  Center(
                            child: SizedBox(
                              height: 50,
                              child: Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.green,
                                size: 35,
                              ),
                            ),
                          
                        ),
                      )),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${data["U_CK_CardCode"] ?? "N/A"} - ${data["CustomerName"] ?? "N/A"}",
                                          style:
                                              const TextStyle(fontSize: 12.5),
                                          textScaleFactor: 1.0),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        "SN: ${(data["CK_JOB_EQUIPMENTCollection"] as List?)?.isNotEmpty == true ? data["CK_JOB_EQUIPMENTCollection"].first["U_CK_SerialNum"] ?? "N/A" : "N/A"}",
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          height: 2,
                                        ),
                                        textScaleFactor: 1.0,
                                      )
                                    ],
                                  ))),
                          Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: data["U_CK_Status"] == "Accept"
                                          ? Colors.yellow
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: TextButton(
                                      onPressed: onTap,
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                      child: Text(
                                          data["U_CK_Status"] == "Pending"
                                              ? "Accept"
                                              : data["U_CK_Status"] == "Accept"
                                                  ? "Travel"
                                                  : data["U_CK_Status"] ==
                                                          "Travel"
                                                      ? "Service"
                                                      : "Entry",
                                          style: TextStyle(
                                              color: data["U_CK_Status"] ==
                                                      "Accept"
                                                  ? const Color.fromARGB(
                                                      255, 8, 8, 8)
                                                  : const Color.fromARGB(
                                                      255, 255, 255, 255),
                                              fontSize: 13),
                                          textScaleFactor: 1.0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ), ////
                  ),
                ],
              ),
            ), /////
          )
        ],
      ),
    );
  }
}
