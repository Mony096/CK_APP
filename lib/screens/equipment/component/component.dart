import 'package:bizd_tech_service/component/text_field_dialog.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Component extends StatefulWidget {
  const Component({super.key, this.controller});

  // Specify the type here
  final Map<String, dynamic>? controller;

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  int updateIndexComps = -1;
  int isEditComp = -1;
  List<dynamic> componentList = [];

  final code = TextEditingController();
  final name = TextEditingController();
  final part = TextEditingController();
  final brand = TextEditingController();
  final model = TextEditingController();
  final FocusNode codeFocusNode = FocusNode();

  void _showCreateComponent() async {
    await showDialog<String>(
      barrierDismissible: false, // user must tap button!

      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.task_outlined,
                  color: Colors.blueGrey[800],
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Create Component",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          content: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color.fromARGB(255, 219, 221, 224),
                          width: 1))),
              // color: Colors.red,
              width: double.maxFinite, // Use full width of the dialog
              constraints: const BoxConstraints(
                maxHeight: 460, // Limit the height to prevent overflow
              ),
              child: Container(
                  child: Column(
                children: [
                  CustomTextFieldDialog(
                    controller: code,
                    label: 'Code',
                    star: true,
                    focusNode: codeFocusNode,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    controller: name,
                    label: 'Name',
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    controller: part,
                    label: 'Part Number',
                    star: false,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    controller: brand,
                    label: 'Brand',
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    controller: model,
                    label: 'Model',
                    star: false,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
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
                            _onAddComponent(context);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 66, 83, 100),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            // Adjust the padding to make the button smaller
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(7, 0, 5, 0),
                            child: Text(
                              isEditComp >= 0 ? "Edit" : "Add",
                              style: const TextStyle(
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

void _onAddComponent(BuildContext context, {bool force = false}) {
  try {
    if (code.text.isEmpty) throw Exception('Code is missing.');
    if (name.text.isEmpty) throw Exception('Name is missing.');

    final item = {
      "U_ck_comCode": code.text,
      "U_U_ck_comName": name.text,
      "U_ck_partNum": part.text,
      "U_ck_brand": brand.text,
      "U_ck_model": model.text,
    };

    Provider.of<EquipmentCreateProvider>(context, listen: false)
        .addOrEditComponent(item, editIndex: isEditComp);

    // Reset edit mode
    isEditComp = -1;

    clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

  } catch (err) {
    if (err is Exception) {
      MaterialDialog.success(context, title: 'Warning', body: err.toString());
    }
  }
}


  void onEditComp(dynamic item, int index) {
    if (index < 0) return;
    MaterialDialog.warningWithRemove(
      context,
      title: 'Comps (${item['U_ck_comCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
        // Navigator.of(context).pop(); // Close warning dialog first

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateComponent(); // Then open edit form dialog
        });

        code.text = getDataFromDynamic(item["U_ck_comCode"]);
        name.text = getDataFromDynamic(item["U_U_ck_comName"]);
        part.text = getDataFromDynamic(item["U_ck_partNum"]);
        brand.text = getDataFromDynamic(item["U_ck_brand"]);
        model.text = getDataFromDynamic(item["U_ck_model"]);
        FocusScope.of(context).requestFocus(codeFocusNode);

        setState(() {
          isEditComp = index;
        });
      },

    onCancel: () {
  // Remove using Provider
  Provider.of<EquipmentCreateProvider>(context, listen: false).removeComponent(index);

  // Reset edit state
  isEditComp = -1;

  // Show SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 66, 83, 100),
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

  // Unfocus keyboard
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
              // CustomTextField(
              //   controller: code,
              //   label: 'Code',
              //   star: true,
              //   focusNode: codeFocusNode,

              // ),
              // const SizedBox(height: 8),
              // CustomTextField(
              //   controller: name,
              //   label: 'Name',
              //   star: true,

              // ),
              // const SizedBox(height: 8),
              // CustomTextField(
              //   controller: part,
              //   label: 'Part Number',
              //   star: false,
              // ),
              // const SizedBox(height: 8),
              // CustomTextField(
              //   controller: brand,
              //   label: 'Brand',
              //   star: true,
              // ),
              // const SizedBox(height: 8),
              // CustomTextField(
              //   controller: model,
              //   label: 'Model',
              //   star: false,
              // ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 13),
                child: ElevatedButton(
                  onPressed: () async {
                    // onAddComponent();
                    _showCreateComponent();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    // 'Add Component',
                    "Add Component",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              //  const SizedBox(height: 7),
              const ComponentTitle(
                label: "Component Lists",
              ),
              const SizedBox(height: 4),
              ////list----------------------------------------------------------------
              context.watch<EquipmentCreateProvider>().components.isEmpty
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
                            "No Component",
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
              ...context.watch<EquipmentCreateProvider>().components.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                // if (itemKeys.length < componentList.length) {
                //   itemKeys.add(GlobalKey());
                // }

                return GestureDetector(
                  // key: itemKeys[index],
                  onTap: () {
                    onEditComp(item, index);
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
                                        "Comps Created - No. ${index + 1}",
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
