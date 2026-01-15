import 'dart:io';

import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Future<void> pickImage() async {
    final picker = ImagePicker();

    // Show dialog to choose source
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            // SizedBox(width: 15),
            // Icon(
            //   Icons.add_box,
            //   size: 25,
            //   color: Color.fromARGB(255, 118, 121, 123),
            // ),
            // SizedBox(width: 15),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.042,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Colors.blue,
                size: 25,
              ),
              title: Text(
                "Take Photo",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.038),
              ),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.green,
                size: 25,
              ),
              title: Text("Choose from Gallery",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.038)),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return; // User canceled

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final newFile = File(pickedFile.path);
      final newBytes = await newFile.readAsBytes();
      final newHash = sha256.convert(newBytes).toString();

      bool isDuplicate = false;
      final provider = context.read<CompletedServiceProvider>();

      for (final file in provider.imagesList) {
        final existingBytes = await file.readAsBytes();
        final existingHash = sha256.convert(existingBytes).toString();
        if (existingHash == newHash) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              "Duplicate Image",
              style: TextStyle(fontSize: 21),
            ),
            content: const Text("This image has already been selected."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
      Provider.of<CompletedServiceProvider>(context, listen: false)
          .setImages([newFile]); // Pass as list

      // setState(() {
      //   _images.add(newFile);
      // });
      // print(provider.imagesList);
    }
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
            'Image',
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
                                                  SizedBox(
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
                                                                  padding: EdgeInsets
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
                                                      padding: EdgeInsets.only(
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
////bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                      onTap: pickImage,
                      title: 'Upload Image',
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
                    const SizedBox(
                      height: 7,
                    ),
                    ImageShow(
                        image: context
                            .watch<CompletedServiceProvider>()
                            .imagesList),
                    //            const SizedBox(
                    //   height: 7,
                    // ),

                    /////do somthing
                  ]),
                )),
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Container(
                //     margin: const EdgeInsets.fromLTRB(0, 5, 5, 25),
                //     width: 122,
                //     padding: const EdgeInsets.all(5),
                //     child: TextButton(
                //       onPressed: () => Navigator.of(context).pop(),
                //       style: TextButton.styleFrom(
                //         backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(5.0),
                //         ),
                //       ),
                //       child: const Text(
                //         "Done",
                //         style: TextStyle(
                //           color: Color.fromARGB(255, 255, 255, 255),
                //           fontSize: 13,
                //         ),
                //       ),
                //     ),
                //   ),
                // )
              ],
            )),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({super.key, this.icon, required this.title, this.onTap});
  final dynamic icon;
  final VoidCallback? onTap;
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
              flex: 4,
              child: Text(widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.032),
                  textScaleFactor: 1.0)),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: widget.onTap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text(
                "Add Image",
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: MediaQuery.of(context).size.width * 0.031),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageShow extends StatefulWidget {
  const ImageShow({
    super.key,
    required this.image,
  });
  final List<dynamic> image;
  @override
  State<ImageShow> createState() => _ImageShowState();
}

class _ImageShowState extends State<ImageShow> {
  void _removeImage(int index) {
    setState(() {
      widget.image.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 41, 84, 185).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(5),
        height: 265,
        child: widget.image.isEmpty
            ? const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: Color.fromARGB(115, 63, 65, 67),
                ),
              )
            : GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(widget.image.length, (index) {
                  final file = widget.image[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ));
  }
}
