import 'package:bizd_tech_service/core/widgets/DatePicker.dart';
import 'package:bizd_tech_service/core/widgets/DatePickerDialog.dart';
import 'package:bizd_tech_service/core/widgets/text_field_dialog.dart';
import 'package:bizd_tech_service/core/widgets/text_remark.dart';
import 'package:bizd_tech_service/core/widgets/text_remark_dialog.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OpenIssueScreen extends StatefulWidget {
  const OpenIssueScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  _OpenIssueScreenState createState() => _OpenIssueScreenState();
}

class _OpenIssueScreenState extends State<OpenIssueScreen> {
  int updateIndexComps = -1;
  int isEditComp = -1;
  List<dynamic> componentList = [];
  int isAdded = 0;

  String? userName;

  @override
  void initState() {
    super.initState();

    _loadUserName();
  }

  final area = TextEditingController();
  final desc = TextEditingController();
  final critical = TextEditingController();
  final date = TextEditingController();
  final model = TextEditingController();
  final status = TextEditingController();
  final handleBy = TextEditingController();
  final remark = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> areaFieldNotifier =
      ValueNotifier({"missing": false, "value": "Area required", "isAdded": 0});
  final ValueNotifier<Map<String, dynamic>> descFieldNotifier = ValueNotifier(
      {"missing": false, "value": "Description required", "isAdded": 0});

  void _showCreateIssue() async {
    date.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(
              maxHeight: 650,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: areaFieldNotifier,
                    controller: area,
                    label: 'Area',
                    star: true,
                  ),
                  const SizedBox(height: 8),
                  CustomTextRemarkDialog(
                      controller: desc,
                      label: 'Description',
                      star: true,
                      detail: false,
                      isMissingFieldNotifier: descFieldNotifier),
                  const SizedBox(height: 8),
                  CustomDatePickerFieldDialog(
                      label: 'Date',
                      star: true,
                      controller: date,
                      detail: false),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: null,
                    controller: critical,
                    label: 'Critical',
                    star: false,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: null,
                    controller: status,
                    label: 'Status',
                    star: false,
                  ),
                  CustomTextFieldDialog(
                    isMissingFieldNotifier: null,
                    controller: handleBy,
                    label: 'Handle By',
                    star: false,
                  ),
                  const SizedBox(height: 8),
                  CustomTextRemarkDialog(
                      controller: remark,
                      label: 'Remarks',
                      star: false,
                      detail: false),
                ],
              ),
            ),
          ),
          actions: [
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
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                    color: Color.fromARGB(255, 66, 83, 100)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (area.text.isEmpty || desc.text.isEmpty) {
                  areaFieldNotifier.value = {
                    "missing": area.text.isEmpty,
                    "value": "Area is required!",
                    "isAdded": 1,
                  };
                  descFieldNotifier.value = {
                    "missing": desc.text.isEmpty,
                    "value": "Description is required!",
                    "isAdded": 1,
                  };

                  return;
                }
                _onAddIssue(context);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 66, 83, 100),
                foregroundColor: Colors.white,
                elevation: 3,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                isEditComp >= 0 ? "Edit" : "Add",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.036,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 4.0,
        );
      },
    );
  }

  void _onAddIssue(BuildContext context, {bool force = false}) {
    try {
      // if (name.text.isEmpty) throw Exception('Name is missing.');
      // if (brand.text.isEmpty) throw Exception('Brand is missing.');

      final item = {
        "U_CK_IssueType": area.text,
        "U_CK_IssueDesc": desc.text,
        "U_CK_RaisedBy": critical.text,
        "U_CK_CreatedDate": date.text,
        "U_CK_Status": status.text,
        "U_CK_HandledBy": handleBy.text,
        "U_CK_Comment": remark.text,
      };

      Provider.of<CompletedServiceProvider>(context, listen: false)
          .addOrEditOpenIssue(item, editIndex: isEditComp);

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
      title: 'Issue (${item['U_CK_IssueType']})',
      confirmLabel: "Edit",
      cancelLabel: "Remove",
      onConfirm: () {
        // Navigator.of(context).pop(); // Close warning dialog first

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCreateIssue(); // Then open edit form dialog
        });

        area.text = getDataFromDynamic(item["U_CK_IssueType"]);
        desc.text = getDataFromDynamic(item["U_CK_IssueDesc"]);
        critical.text = getDataFromDynamic(item["U_CK_RaisedBy"]);
        date.text = getDataFromDynamic(item["U_CK_CreatedDate"]);
        status.text = getDataFromDynamic(item["U_CK_Status"]);
        handleBy.text = getDataFromDynamic(item["U_CK_HandledBy"]);
        remark.text = getDataFromDynamic(item["U_CK_Comment"]);

        // FocusScope.of(context).requestFocus(codeFocusNode);

        setState(() {
          isEditComp = index;
        });
      },

      onCancel: () {
        // Remove using Provider
        Provider.of<CompletedServiceProvider>(context, listen: false)
            .removeOpenIssue(index);
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
                        "Open Issue Removed (${item['U_CK_IssueType']})",
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
    area.text = "";
    desc.text = "";
    critical.text = "";
    date.text = "";
    status.text = "";
    handleBy.text = "";
    remark.text = "";
    areaFieldNotifier.value = {
      "missing": false,
      "value": "Code is required!",
      "isAdded": 1,
    };
    descFieldNotifier.value = {
      "missing": false,
      "value": "Name is required!",
      "isAdded": 1,
    };
  }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('FullName');
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
            'Open Issue',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.042,
                color: Colors.white),
            textScaleFactor: 1.0,
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
                ///////////
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

                    ///endddddddddddddddddddddd
                    const SizedBox(
                      height: 10,
                    ),
                    Menu(
                      title: userName ?? '...',
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SvgPicture.asset(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          'images/svg/report.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(height: 4),
                    ////list----------------------------------------------------------------
                    context.read<CompletedServiceProvider>().openIssues.isEmpty
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 105,
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    color: Colors.grey,
                                    'images/svg/report.svg',
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Text(
                                    "No Open Issues",
                                    style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(221, 168, 168, 171),
                                    ),
                                  ),
                                ],
                              )),
                            ),
                          )
                        : Container(),
                    ...context
                        .read<CompletedServiceProvider>()
                        .openIssues
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
                          onEditComp(item, index);
                        },
                        child: DetailMenu(
                          title: item["U_CK_IssueType"],
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: SvgPicture.asset(
                              color: const Color.fromARGB(255, 67, 70, 72),
                              'images/svg/check_cicle.svg',
                              width: 22,
                              height: 22,
                            ),
                          ),
                          desc: item["U_CK_IssueDesc"],
                        ),
                      );
                    }),

                    SizedBox(
                        height: context
                                .read<CompletedServiceProvider>()
                                .openIssues
                                .isEmpty
                            ? 0
                            : 5),
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      height: 70,
                      padding: const EdgeInsets.fromLTRB(12, 12, 0, 10),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Container()),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: _showCreateIssue,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Text(
                                "Add Issue",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.031),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
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
  const DetailMenu(
      {super.key, this.icon, required this.title, required this.desc});
  final dynamic icon;
  final String title;
  final String desc;
  @override
  State<DetailMenu> createState() => _DetailMenuState();
}

class _DetailMenuState extends State<DetailMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                  Text(widget.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.032),
                      textScaleFactor: 1.0),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.desc,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.031),
                      textScaleFactor: 1.0),
                ],
              )),
        ],
      ),
    );
  }
}
