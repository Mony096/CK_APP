import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MaterialReserveScreen extends StatefulWidget {
  const MaterialReserveScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _MaterialReserveScreenState createState() => _MaterialReserveScreenState();
}

class _MaterialReserveScreenState extends State<MaterialReserveScreen> {
  @override
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
            'Material Reserve',
            style: TextStyle(fontSize: 17, color: Colors.white),
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
                    DetailMenu(
                      title: 'MR0001',
                      name: "Nut & Waher",
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 67, 70, 72),
                          'images/svg/check_cicle.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      desc: 'Res.Qty | 10',
                      qty: "5",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DetailMenu(
                      title: 'MR0002',
                      name: "Copper Tube",
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 67, 70, 72),
                          'images/svg/check_cicle.svg',
                          width: 22,
                          height: 22,
                        ),
                      ),
                      desc: 'Res.Qty | 10',
                      qty: "5",
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
        children: [
          Expanded(flex: 1, child: widget.icon),
          Expanded(
              flex: 6,
              child: Text(widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  textScaleFactor: 1.0)),
        ],
      ),
    );
  }
}

class DetailMenu extends StatefulWidget {
  const DetailMenu(
      {super.key,
      this.icon,
      required this.title,
      required this.desc,
      required this.name,
      this.qty});
  final dynamic icon;
  final String title;
  final String name;
  final String desc;
  final dynamic qty;
  @override
  State<DetailMenu> createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  widget.icon,
                  const SizedBox(
                    height: 23,
                  )
                ],
              )),
          Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        textScaleFactor: 1.0,
                      ),
                      const Text(
                        "Usage Qty",
                        style: TextStyle(fontSize: 13),
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
                        style: const TextStyle(fontSize: 12.5),
                        textScaleFactor: 1.0,
                      ),
                      Text(
                        textScaleFactor: 1.0,
                        widget.qty,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Color.fromARGB(255, 0, 0, 0)),
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
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Color.fromARGB(255, 122, 126, 130)),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
