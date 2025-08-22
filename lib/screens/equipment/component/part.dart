import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/helper/helper.dart';
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
  int updateIndexPart = -1;
  int isEditPart = -1;
  List<dynamic> partList = [];

  final code = TextEditingController();
  final name = TextEditingController();
  final part = TextEditingController();
  final brand = TextEditingController();
  final model = TextEditingController();
  final FocusNode codeFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  List<GlobalKey> itemKeys = [];
  void onAddPart({bool force = false}) {
    try {
      List<dynamic> data = [...partList];

      if (code.text.isEmpty) throw Exception('Code is missing.');
      if (name.text.isEmpty) throw Exception('Name is missing.');

      final item = {
        "U_ck_comCode": code.text,
        "U_U_ck_comName": name.text,
        "U_ck_partNum": part.text,
        "U_ck_brand": brand.text,
        "U_ck_model": model.text,
      };

      int editedIndex = isEditPart;

      if (isEditPart == -1) {
        data.add(item);
      } else {
        data[isEditPart] = item;
        isEditPart = -1;
      }

      clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
      setState(() {
        partList = data;
      });

      if (editedIndex != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = itemKeys[editedIndex].currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.3, // 0.0 = top, 1.0 = bottom, 0.3 = near top
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } catch (err) {
      if (err is Exception) {
        MaterialDialog.success(context, title: 'Warning', body: err.toString());
      }
    }
  }

  void onEditPart(dynamic item, int index) {
    if (index < 0) return;
    MaterialDialog.warningWithRemove(
      context,
      title: 'Comps (${item['U_ck_comCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
        code.text = getDataFromDynamic(item["U_ck_comCode"]);
        name.text = getDataFromDynamic(item["U_U_ck_comName"]);
        part.text = getDataFromDynamic(item["U_ck_partNum"]);
        brand.text = getDataFromDynamic(item["U_ck_brand"]);
        model.text = getDataFromDynamic(item["U_ck_model"]);
        FocusScope.of(context).requestFocus(codeFocusNode);
        setState(() {
          isEditPart = index;
        });
      },
      onCancel: () {
        List<dynamic> data = [...partList];
        data.removeAt(index);

        setState(() {
          partList = data;
          isEditPart = -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color.fromARGB(255, 66, 83, 100),
            behavior: SnackBarBehavior.floating,
            elevation: 10,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            content: Row(
              children: [
                const Icon(Icons.remove_circle, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Component Removed (${item['U_ck_comCode']})",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      },
      icon: Icons.question_mark, // 👈 Pass the icon here
    );
  }

  void clear() {
    code.text = "";
    name.text = "";
    part.text = "";
    brand.text = "";
    model.text = "";
  }

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
                controller: code,
                label: 'Code',
                star: true,
                focusNode: codeFocusNode,

                // icon: const Icon(Icons.qr_code_scanner,
                //     color: Colors.grey),
                // onclickIcon: () {
                //   print("Scan icon tapped!");
                // },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: name,
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
                controller: part,
                label: 'Part Number',
                star: false,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: brand,
                label: 'Brand',
                star: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: model,
                label: 'Model',
                star: false,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 13),
                child: ElevatedButton(
                  onPressed: () async {
                    onAddPart();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isEditPart >= 0 ? "Update Part" : "Add Part",
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
              partList.isEmpty
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            color: const Color.fromARGB(221, 184, 182, 182),
                            'images/svg/kjav3.svg',
                            width: 25,
                          ),
                          const Text(
                            "No Part",
                            style: TextStyle(
                              fontSize: 15,
                              // fontWeight: FontWeight.w500,
                              color: Color.fromARGB(221, 168, 168, 171),
                            ),
                          ),
                        ],
                      )),
                    )
                  : Container(),
              ...partList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                if (itemKeys.length < partList.length) {
                  itemKeys.add(GlobalKey());
                }

                return GestureDetector(
                  key: itemKeys[index],
                  onTap: () {
                    onEditPart(item, index);
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 13),
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
                          offset: const Offset(1, 1),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.settings,
                                          size: 19,
                                          color: Color.fromARGB(
                                              255, 188, 189, 190)),
                                      const SizedBox(width: 3),
                                      Text(
                                        "Parts Created - No. ${index + 1}",
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                        textScaleFactor: 1.0,
                                      ),
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
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // width: 104,
                                      child: Text(
                                        "${item["U_ck_comCode"]} - ${item["U_U_ck_comName"]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        textScaleFactor: 1.0,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 42,
                                          child: Text("Model",
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                        Text(": ${item["U_ck_model"]}",
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 7.5),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                          child: Text("Brand",
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                        Text(": ${item["U_ck_brand"]}",
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 30,
                                          child: Text("Part",
                                              style: TextStyle(fontSize: 13)),
                                        ),
                                        Text(": ${item["U_ck_partNum"]}",
                                            style:
                                                const TextStyle(fontSize: 13),
                                            textScaleFactor: 1.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
