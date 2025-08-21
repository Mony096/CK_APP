
import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Part extends StatefulWidget {
  const Part({super.key, this.controller});

  // Specify the type here
  final Map<String, dynamic>? controller;

  @override
  State<Part> createState() => _PartState();
}

class _PartState extends State<Part> {
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
              // const SizedBox(height: 7),
              // const PartTitle(
              //   label: "Infomation",
              // ),
              // const SizedBox(height: 8),
              // const SizedBox(height: 10),
              CustomTextField(
                controller: widget.controller?['equipCode'],
                label: 'Code',
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
                label: 'Name',
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
                label: 'Part Number',
                star: false,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Brand',
                star: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: widget.controller?['equipName'],
                label: 'Model',
                star: false,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 13),
                child: ElevatedButton(
                  onPressed: () async {
                    try {} catch (e) {
                      // setState(() => _isLoading = false);
                      MaterialDialog.warning(
                        context,
                        title: 'Login Failed',
                        body: "Incorrect username/password or server error.",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add Part',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              //  const SizedBox(height: 7),
              const ComponentTitle(
                label: "Part Lists",
              ),
              const SizedBox(height: 4),
              ////list----------------------------------------------------------------
              GestureDetector(
                onTap: () {
                  // onEdit(item, index);
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  padding: const EdgeInsets.fromLTRB(0, 6.5, 10, 10),
                  decoration: BoxDecoration(
                    border: const Border(
                      left: BorderSide(
                        color: Color.fromARGB(255, 66, 83, 100),
                        width: 8,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 133, 136, 138)
                            .withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset:
                            const Offset(1, 1), // Right (x=3) & Bottom (y=3)
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      size: 19,
                                      color: const Color.fromARGB(
                                          255, 188, 189, 190),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text("Part Created - No. 1",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        textScaleFactor: 1.0),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: SvgPicture.asset(
                                    'images/svg/check-cycle.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 104,
                                    child: Text("A001 - EQ Name",
                                        // "${getDataFromDynamic(item["Code"])} - ${getDataFromDynamic(item["Name"])} ", // Show index
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        textScaleFactor: 1.0),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 42,
                                        child: Text("Model",
                                            style: TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ),
                                      Text(
                                          // ": ${getDataFromDynamic(item["U_ck_CusName"])}",
                                          ": Sony",
                                          style: TextStyle(fontSize: 13),
                                          textScaleFactor: 1.0),
                                    ],
                                  ),
                                  // Text("No. ${index + 1}",
                                  //     style:
                                  //         const TextStyle(fontSize: 13),
                                  //     textScaleFactor: 1.0),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 7.5,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text("Brand",
                                            style: TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ),
                                      Text(
                                          // ": ${getDataFromDynamic(item["U_ck_CusName"])}",
                                          ": EQ Name",
                                          style: TextStyle(fontSize: 13),
                                          textScaleFactor: 1.0),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text("Part",
                                            style: TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ),
                                      Text(
                                          // ": ${getDataFromDynamic(item["U_ck_CusName"])}",
                                          ": 07583",
                                          style: TextStyle(fontSize: 13),
                                          textScaleFactor: 1.0),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
