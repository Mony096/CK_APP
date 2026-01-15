import 'package:bizd_tech_service/core/widgets/text_field_dialog.dart';
import 'package:bizd_tech_service/core/widgets/title_break.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/screens/select/businessPartnerPage.dart';
import 'package:bizd_tech_service/features/equipment/screens/select/itemMasterPage.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Component extends StatefulWidget {
  const Component({super.key, this.controller, required this.data});
  final Map<String, dynamic> data;

  // Specify the type here
  final Map<String, dynamic>? controller;

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  int updateIndexComps = -1;
  int isEditComp = -1;
  List<dynamic> componentList = [];
  int isAdded = 0;
  final code = TextEditingController();
  final name = TextEditingController();
  final part = TextEditingController();
  final brand = TextEditingController();
  final brandName = TextEditingController();

  final model = TextEditingController();
  final FocusNode codeFocusNode = FocusNode();
  final ValueNotifier<Map<String, dynamic>> codeFieldNotifier =
      ValueNotifier({"missing": false, "value": "Code required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> nameFieldNotifier =
      ValueNotifier({"missing": false, "value": "Name required", "isAdded": 0});

  final ValueNotifier<Map<String, dynamic>> partFieldNotifier =
      ValueNotifier({"missing": false, "value": "Part required", "isAdded": 0});

  final ValueNotifier<Map<String, dynamic>> brandFieldNotifier = ValueNotifier(
      {"missing": false, "value": "Brand required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> modelFieldNotifier = ValueNotifier(
      {"missing": false, "value": "Model required", "isAdded": 0});

  void _showCreateComponent() async {
    await showDialog<String>(
      barrierDismissible: false, // user must tap button!

      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0), // Rounded corners
          ),
          // title: Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 0),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Icon(
          //         Icons.task_outlined,
          //         color: Colors.blueGrey[800],
          //       ),
          //       const SizedBox(
          //         width: 7,
          //       ),
          //       Text(
          //         "Create Component",
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.blueGrey[800],
          //         ),
          //         textAlign: TextAlign.left,
          //       ),
          //     ],
          //   ),
          // ),
          content: Container(
              padding: const EdgeInsets.only(top: 7),
              // decoration: const BoxDecoration(
              //     // border: Border(
              //     //     top: BorderSide(
              //     //         color: Color.fromARGB(255, 219, 221, 224),
              //     //         width: 1))
              //     ),
              // color: Colors.red,
              width: double.maxFinite, // Use full width of the dialog
              constraints: const BoxConstraints(
                maxHeight: 465, // Limit the height to prevent overflow
              ),
              child: Container(
                  child: ListView(
                children: [
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: codeFieldNotifier,
                    controller: code,
                    label: 'Code',
                    star: true,
                    readOnly: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.grey,
                      size: 28,
                    ),
                    onclickIcon: () {
                      _itemSelect();
                    },
                    focusNode: codeFocusNode,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: nameFieldNotifier,
                    controller: name,
                    label: 'Name',
                    disabled: true,
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    // isMissingFieldNotifier: partFieldNotifier,
                    controller: part,
                    label: 'Part Number',
                    disabled: true,
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: brandFieldNotifier,
                    controller: brandName,
                    label: 'Brand',
                    disabled: true,
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    // isMissingFieldNotifier: modelFieldNotifier,
                    controller: model,
                    label: 'Model',
                    disabled: true,
                    star: true,
                  ),
                  const SizedBox(height: 21),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditComp = -1;
                          });
                          clear();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.036,
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
                            if (code.text.isEmpty ||
                                    name.text.isEmpty ||
                                    // part.text.isEmpty ||
                                    brand.text.isEmpty
                                //  ||
                                // model.text.isEmpty
                                ) {
                              codeFieldNotifier.value = {
                                "missing": code.text.isEmpty,
                                "value": "Code is required!",
                                "isAdded": 1,
                              };
                              nameFieldNotifier.value = {
                                "missing": name.text.isEmpty,
                                "value": "Name is required!",
                                "isAdded": 1,
                              };
                              // partFieldNotifier.value = {
                              //   "missing": part.text.isEmpty,
                              //   "value": "Part is required!",
                              //   "isAdded": 1,
                              // };

                              brandFieldNotifier.value = {
                                "missing": brand.text.isEmpty,
                                "value": "Brand is required!",
                                "isAdded": 1,
                              };
                              // modelFieldNotifier.value = {
                              //   "missing": model.text.isEmpty,
                              //   "value": "Model is required!",
                              //   "isAdded": 1,
                              // };
                              return;
                            }

                            _onAddComponent(context);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 66, 83, 100),
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
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(
                              isEditComp >= 0 ? "Edit" : "Add",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.036,
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
      // if (name.text.isEmpty) throw Exception('Name is missing.');
      // if (brand.text.isEmpty) throw Exception('Brand is missing.');

      final item = {
        "U_ck_ItemCode": code.text,
        "U_ck_ItemName": name.text,
        "U_ck_partNum": part.text,
        // "U_ck_brand": brand.text,
        "U_ck_brand": brandName.text,
        "U_ck_model": model.text,
      };

      Provider.of<EquipmentOfflineProvider>(context, listen: false)
          .addOrEditComponent(item, editIndex: isEditComp);

      // Reset edit mode
      setState(() {
        isEditComp = -1;
      });
      clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
    } catch (err) {
      if (err is Exception) {
        // Sh SnackBar
        MaterialDialog.success(context, title: 'Warning', body: err.toString());
      }
    }
  }

  void onEditComp(dynamic item, int index) {
    if (index < 0) return;
    MaterialDialog.warningWithRemove(
      context,
      title: 'Comps (${item['U_ck_ItemCode']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
        // Navigator.of(context).pop(); // Close warning dialog first

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateComponent(); // Then open edit form dialog
        });

        code.text = getDataFromDynamic(item["U_ck_ItemCode"]);
        name.text = getDataFromDynamic(item["U_ck_ItemName"]);
        part.text = getDataFromDynamic(item["U_ck_partNum"]);
        brand.text = getDataFromDynamic(item["U_ck_brand"]);
        brandName.text = getDataFromDynamic(item["U_ck_brand"]);
        model.text = getDataFromDynamic(item["U_ck_model"]);
        FocusScope.of(context).requestFocus(codeFocusNode);

        setState(() {
          isEditComp = index;
        });
      },

      onCancel: () {
        // Remove using Provider
        Provider.of<EquipmentOfflineProvider>(context, listen: false)
            .removeComponent(index);

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
                        "Component Removed (${item['U_ck_ItemCode']})",
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
    codeFieldNotifier.value = {
      "missing": false,
      "value": "Code is required!",
      "isAdded": 1,
    };
    nameFieldNotifier.value = {
      "missing": false,
      "value": "Name is required!",
      "isAdded": 1,
    };
    partFieldNotifier.value = {
      "missing": false,
      "value": "Part is required!",
      "isAdded": 1,
    };

    brandFieldNotifier.value = {
      "missing": false,
      "value": "Brand is required!",
      "isAdded": 1,
    };
    modelFieldNotifier.value = {
      "missing": false,
      "value": "Model is required!",
      "isAdded": 1,
    };
  }

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
                Row(
                  children: [
                    Icon(Icons.assignment, color: Colors.green, size: 25),
                    SizedBox(width: 10),
                    Text(
                      "Component (${data["U_ck_ItemCode"]})",
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
                _buildRow("Code", "${data["U_ck_ItemCode"] ?? "N/A"}"),
                _buildRow("Name", "${data["U_ck_ItemName"] ?? "N/A"}"),
                _buildRow("Part Number", "${data["U_ck_partNum"] ?? "N/A"}"),
                _buildRow("Brand", "${data["U_ck_brand"] ?? "N/A"}"),
                _buildRow("Model", data["U_ck_model"]),

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
              widget.data.isEmpty
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 13),
                      child: ElevatedButton(
                        onPressed: () async {
                          // onAddComponent();
                          _showCreateComponent();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 46),
                          backgroundColor:
                              const Color.fromARGB(255, 66, 83, 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          // 'Add Component',
                          "Add Component",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.034),
                        ),
                      ),
                    )
                  : Container(),
              //  const SizedBox(height: 7),
              const ComponentTitle(
                label: "Component Lists",
              ),
              const SizedBox(height: 4),
              ////list----------------------------------------------------------------
              context.watch<EquipmentOfflineProvider>().components.isEmpty
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
                          Text(
                            "No Component",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.034,
                              // fontWeight: FontWeight.w500,
                              color: Color.fromARGB(221, 168, 168, 171),
                            ),
                          ),
                        ],
                      )),
                    )
                  : Container(),
              ...context
                  .watch<EquipmentOfflineProvider>()
                  .components
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                // if (itemKeys.length < componentList.length) {
                //   itemKeys.add(GlobalKey());
                // }

                return GestureDetector(
                  // key: itemKeys[index],
                  onTap: () {
                    if (widget.data.isEmpty) {
                      onEditComp(item, index);
                    } else {
                      _showDetail(item);
                    }
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
                              // ✅ Header row
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

                              // ✅ Item code & model row
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${item["U_ck_ItemCode"]} - ${item["U_ck_ItemName"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Model : ${((item["U_ck_model"] ?? "").toString().trim().isEmpty) ? "N/A" : item["U_ck_model"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 7.5),

                              // ✅ Brand & part row
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Brand : ${item["U_ck_brand"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Part : ${((item["U_ck_partNum"] ?? "").toString().trim().isEmpty) ? "N/A" : item["U_ck_partNum"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        textScaleFactor: 1.0,
                                        style: const TextStyle(fontSize: 13),
                                      ),
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

  void _itemSelect() async {
    goTo(context, const ItemMasterPageBusiness()).then((value) => {
          if (value != null)
            {
              setState(() {
                print(value);
                code.text = getDataFromDynamic(value["ItemCode"]);
                name.text = getDataFromDynamic(value["ItemName"]);
                part.text = getDataFromDynamic(value["Part"]);
                brand.text = getDataFromDynamic(value["BrandId"]);
                brandName.text = getDataFromDynamic(value["BrandName"]);
                model.text = getDataFromDynamic(value["Model"]);
                // widget.controller?["customerName"].text =
                //     getDataFromDynamic(value["CardName"]);
                // customerCode.text = getDataFromDynamic(value["CardCode"]);
                // customerName.text = getDataFromDynamic(value["CardName"]);
              })
            }
        });
  }
}
