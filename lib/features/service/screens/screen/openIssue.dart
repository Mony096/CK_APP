import 'package:bizd_tech_service/core/widgets/DatePickerDialog.dart';
import 'package:bizd_tech_service/core/widgets/text_field_dialog.dart';
import 'package:bizd_tech_service/core/widgets/text_remark_dialog.dart';
import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF425364),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Open Issue',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, color: Colors.white),
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
                // Status Stepper
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    children: [
                       // Service Info Card
                       ServiceInfoCard(data: widget.data),

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
                      color: Colors.transparent, // Transparent to blend with background
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _showCreateIssue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.add, size: 20, color: Colors.white),
                            label: Text(
                              "Add Issue",
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /////do somthing
                  ]),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
           ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              widget.icon,
              const SizedBox(width: 12),
              Text(widget.title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.blueGrey.shade800
                  )
              )
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.green)
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
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
         boxShadow: [
           BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
           ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
             child: widget.icon, // Adjust icon size if needed
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.blueGrey.shade900
                      )
                  ),
                  const SizedBox(height: 6),
                  Text(widget.desc,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4
                      )
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
