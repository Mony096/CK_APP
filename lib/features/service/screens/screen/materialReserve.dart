
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        title: Center(
          child: Text(
            'Material Reserve',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.042,
                color: Colors.white),
          ),
        ),
        // Right-aligned actions (scan barcode)
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // refresh();
                },
                icon: const Icon(Icons.check, color: Colors.white),
              ),
              // SizedBox(width: 3),
              // IconButton(
              //   onPressed: () async {
              //     MaterialDialog.loading(context);
              //     await Provider.of<AuthProvider>(context, listen: false)
              //         .logout();
              //     Navigator.of(context).pop();
              //     Navigator.of(context).pushAndRemoveUntil(
              //       MaterialPageRoute(builder: (_) => const LoginScreenV2()),
              //       (route) => false,
              //     );
              //   },
              //   icon: const Icon(Icons.logout, color: Colors.white),
              // )
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${widget.data["CustomerName"] ?? "N/A"}",
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.033),
                                              textScaleFactor: 1.0,
                                            ),
                                            const SizedBox(
                                              height: 6,
                                            ),
                                            Text(
                                              ((widget.data["CustomerAddress"]
                                                              as List?)
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? (widget
                                                          .data[
                                                              "CustomerAddress"]
                                                          .first["StreetNo"] ??
                                                      "N/A")
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
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
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "No: ",
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                textScaleFactor: 1.0,
                                              ),
                                              Text(
                                                "${widget.data["DocNum"]}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.033),
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
                          Container(
                              // height: 150,
                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 8),
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
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "Status:",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033,
                                                        color: Colors.white),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: (widget.data[
                                                                    "CK_JOB_SERVICESCollection"]
                                                                as List)
                                                            .isEmpty
                                                        ? [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          8),
                                                              child: Text(
                                                                "No Services Available",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.032),
                                                              ),
                                                            )
                                                          ]
                                                        : (widget.data["CK_JOB_SERVICESCollection"]
                                                                        as List)
                                                                    .length >
                                                                2
                                                            ? [
                                                                ...(widget.data[
                                                                            "CK_JOB_SERVICESCollection"]
                                                                        as List)
                                                                    .take(2)
                                                                    .map((e) =>
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 8),
                                                                          child:
                                                                              Text(
                                                                            "${e["U_CK_ServiceName"]}",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.031),
                                                                            textScaleFactor:
                                                                                1.0,
                                                                          ),
                                                                        )),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              7),
                                                                  child: Text(
                                                                    "more...",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            MediaQuery.of(context).size.width *
                                                                                0.031),
                                                                    textScaleFactor:
                                                                        1.0,
                                                                  ),
                                                                ),
                                                              ]
                                                            : (widget.data[
                                                                        "CK_JOB_SERVICESCollection"]
                                                                    as List)
                                                                .map((e) =>
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              8),
                                                                      child:
                                                                          Text(
                                                                        "${e["U_CK_ServiceName"]}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: MediaQuery.of(context).size.width * 0.032),
                                                                        textScaleFactor:
                                                                            1.0,
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                  )),
                                                  Expanded(
                                                      child: Text(
                                                    "Open",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                  ///////////////////////////
                                  Row(
                                    children: [
                                      const Expanded(
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.033),
                                                    textScaleFactor: 1.0,
                                                  )),
                                                  const Expanded(
                                                      child: Text("",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white))),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              (widget.data["CK_JOB_EQUIPMENTCollection"]
                                                          as List)
                                                      .isEmpty
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      child: Text(
                                                        "No Equipment Available",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.031),
                                                      ),
                                                    )
                                                  : Container(),
                                              ...(widget.data[
                                                          "CK_JOB_EQUIPMENTCollection"]
                                                      as List)
                                                  .take(2)
                                                  .map(
                                                    (item) => Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: Text(
                                                            "${item["U_CK_EquipName"]}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.031),
                                                            textScaleFactor:
                                                                1.0,
                                                          )),
                                                          Expanded(
                                                              child: Text(
                                                            "SN: ${item["U_CK_SerialNum"]}",
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.031,
                                                                color: Colors
                                                                    .white),
                                                            textScaleFactor:
                                                                1.0,
                                                          )),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              (widget.data["CK_JOB_EQUIPMENTCollection"]
                                                              as List)
                                                          .length >
                                                      2
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 7),
                                                      child: Text(
                                                        "more...",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.031),
                                                        textScaleFactor: 1.0,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ))
                                    ],
                                  ),
                                  ///////////////////////////////////////////
                                ],
                              )),
                        ],
                      ),
                    ),
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
                )),
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
      padding: const EdgeInsets.all(13),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              widget.icon,
              const SizedBox(
                width: 8,
              ),
              Text(widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.032),
                  textScaleFactor: 1.0)
            ],
          ),
          const Icon(Icons.arrow_drop_down, size: 30, color: Colors.green)
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
      padding: const EdgeInsets.fromLTRB(13, 0, 15, 0),
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  widget.icon,
                  const SizedBox(
                    height: 38,
                  )
                ],
              )),
          Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.032),
                            textScaleFactor: 1.0,
                          ),
                          Text(
                            "Usage Qty",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.032),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.031),
                            textScaleFactor: 1.0,
                          ),
                          Text(
                            textScaleFactor: 1.0,
                            widget.qty,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.031,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            textScaleFactor: 1.0,
                            widget.desc,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.030,
                                color:
                                    const Color.fromARGB(255, 122, 126, 130)),
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
