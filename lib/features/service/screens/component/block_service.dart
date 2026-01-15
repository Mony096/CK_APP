// import 'package:bizd_tech_service/core/utils/helper_utils.dart';

// import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
// import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';

// class BlockService extends StatelessWidget {
//   const BlockService({super.key, this.onTap, required this.data});
//   final VoidCallback? onTap;
//   final Map<String, dynamic> data;

//   @override
//   Widget build(BuildContext context) {
//     final status = data["U_CK_Status"] ?? "Open";
//     final isAccept = status == "Accept" || status == "Travel" || status == "Service" || status == "Entry";
//     final isTravel = status == "Travel" || status == "Service" || status == "Entry";
//     final isService = status == "Service" || status == "Entry";
//     final isEntry = status == "Entry";

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade100),
//       ),
//       child: Column(
//         children: [
//           // 🔹 Header: Status Stepper
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//             decoration: BoxDecoration(
//               color: const Color(0xFF425364),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStep(context, Icons.check, isAccept),
//                 _buildConnector(context, isTravel),
//                 _buildStep(context, Icons.directions_car, isTravel),
//                 _buildConnector(context, isService),
//                 _buildStep(context, Icons.build, isService, isSvg: true, svgAsset: 'images/svg/key.svg'),
//                 _buildConnector(context, isEntry),
//                 _buildStep(context, Icons.flag, isEntry),
//               ],
//             ),
//           ),

//           // 🔹 Body Content
//           Padding(
//             padding: const EdgeInsets.all(7),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 🔹 Service Info Card
//                 ServiceInfoCard(data: data),

//                 const SizedBox(height: 16),
//                  Divider(height: 1, color: Colors.grey.shade200),
//                  const SizedBox(height: 8             ),

//                 // 🔹 Action Footer
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // View Details Button
//                     TextButton.icon(
//                       onPressed: () {
//                          goTo(context, ServiceByIdScreen(data: data));
//                       },
//                       icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF425364)),
//                       label: Text(
//                         "View Details",
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFF425364),
//                         ),
//                       ),
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         backgroundColor: Colors.transparent,
//                       ),
//                     ),

//                     // Main Action Button
//                     ElevatedButton(
//                       onPressed: onTap,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _getActionColor(status),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                       ),
//                       child: Text(
//                          _getActionLabel(status),
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getActionColor(String status) {
//     if (status == "Accept") return Colors.green;
//     if (status == "Travel") return Colors.orange;
//     if (status == "Service") return Colors.blue;
//     if (status == "Entry") return Colors.purple; // Or a completed color
//     return Colors.green; // Default for Pending -> Accept
//   }

//   String _getActionLabel(String status) {
//      if (status == "Pending") return "Accept";
//      if (status == "Accept") return "Start Travel";
//      if (status == "Travel") return "Start Service";
//      return "Complete";
//   }

//   Widget _buildStep(BuildContext context, IconData icon, bool isActive, {bool isSvg = false, String? svgAsset}) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         color: isActive ? Colors.green : Colors.transparent,
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: isActive ? Colors.green : Colors.white.withOpacity(0.3),
//           width: 2,
//         ),
//       ),
//       child: Center(
//         child: isSvg && svgAsset != null
//             ? SvgPicture.asset(
//                 svgAsset,
//                 width: 16,
//                 height: 16,
//                 color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//               )
//             : Icon(
//                 icon,
//                 size: 16,
//                 color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
//               ),
//       ),
//     );
//   }

//   Widget _buildConnector(BuildContext context, bool isActive) {
//     return Expanded(
//       child: Container(
//         height: 2,
//         color: isActive ? Colors.green : Colors.white.withOpacity(0.2),
//       ),
//     );
//   }
// }

import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceById.dart';

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
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.030),
                                textScaleFactor: 1.0,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ((data["CustomerAddress"] as List?)
                                            ?.isNotEmpty ==
                                        true)
                                    ? (data["CustomerAddress"]
                                            .first["StreetNo"] ??
                                        "No Address Available")
                                    : "No Address Available",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.030,
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
                                Text(
                                  "No: ",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.034),
                                  textScaleFactor: 1.0,
                                ),
                                Text(
                                  "${data["DocNum"]}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.030),
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
                        margin: const EdgeInsets.only(bottom: 20),
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
                                "${data["U_CK_Time"] ?? "No Time"} - ${data["U_CK_EndTime"] ?? "No Time"}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.033),
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
                        margin: const EdgeInsets.only(left: 3),
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
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.030),
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
                        child: const Center(
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
                    height: 2,
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
                                      // Text(
                                      //     "${data["U_CK_CardCode"] ?? "N/A"} - ${data["CustomerName"] ?? "N/A"}",
                                      //     style:
                                      //          TextStyle(fontSize:  MediaQuery.of(context)
                                      //                 .size
                                      //                 .width *
                                      //             0.033),
                                      //     textScaleFactor: 1.0),
                                      Row(
                                        children: [
                                          Text(data["U_CK_CardCode"] ?? "N/A",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.030),
                                              textScaleFactor: 1.0),

                                          const Text(" - "),

                                          // Name
                                          SizedBox(
                                            width: 120,
                                            child: Text(
                                              data["CustomerName"] ?? "N/A",
                                              softWrap: true,
                                              maxLines:
                                                  null, // allow multiple lines
                                              overflow: TextOverflow.ellipsis,

                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.030,
                                              ),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        "SN: ${(data["CK_JOB_EQUIPMENTCollection"] as List?)?.isNotEmpty == true ? data["CK_JOB_EQUIPMENTCollection"].first["U_CK_SerialNum"] == "" ? "No Serial No." : data["CK_JOB_EQUIPMENTCollection"].first["U_CK_SerialNum"] : "No Serial No."}",
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.032,
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
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.031),
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
