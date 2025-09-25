import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/screens/equipment/component/general.dart';
import 'package:bizd_tech_service/screens/equipment/component/component.dart';
import 'package:bizd_tech_service/screens/equipment/component/part.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EquipmentCreateScreen extends StatefulWidget {
  EquipmentCreateScreen({super.key, required this.data});
  Map<String, dynamic> data;
  @override
  _EquipmentCreateScreenState createState() => _EquipmentCreateScreenState();
}

class _EquipmentCreateScreenState extends State<EquipmentCreateScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client
  int _selectedIndex = 0; // Tracks the selected tab
  late PageController _pageController; // Page controller for body content
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;
  final equipType = TextEditingController();
  final customerCode = TextEditingController();
  final customerName = TextEditingController();
  final site = TextEditingController();

  final brand = TextEditingController();

  final equipName = TextEditingController();
  final equipCode = TextEditingController();

  final serialNumber = TextEditingController();
  final model = TextEditingController();
  final condition = TextEditingController();
  final remark = TextEditingController();
  final component = TextEditingController();

  final uploadImg = TextEditingController();
  final installedDate = TextEditingController();
  final nextDate = TextEditingController();
  final warrantyDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize the PageController

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOffline(); // this safely runs after first build
    });
  }

  bool _isTransitioningBetween0And2 = false;

  void _onTabTapped(int index) {
    // Check for the specific transition
    if ((_selectedIndex == 0 && index == 2) ||
        (_selectedIndex == 2 && index == 0)) {
      setState(() {
        _isTransitioningBetween0And2 = true;
      });
      // print("Transitioning specifically between 0 and 2");
    } else {
      setState(() {
        _isTransitioningBetween0And2 = false;
      });
      // Animate PageView to the new page
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    // Update the selected index
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  // Future<void> _init() async {
  //   //when create
  //   if (widget.data.isEmpty) {
  //     installedDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //     nextDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //     warrantyDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //     uploadImg.text = "";
  //     equipType.text = "Active";
  //   }

  //   if (widget.data.isEmpty) return;
  //   //when edit
  //   if (!mounted) return;

  //   MaterialDialog.loading(context); // Show loading dialog

  //   try {
  //     // --- Fetch equipment ---
  //     final response = await dio.get("/CK_CUSEQUI('${widget.data["Code"]}')");

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = response.data;

  //       // --- Fetch attachments as Files ---
  //       List<File> sapFiles = [];
  //       final attachmentEntry = data["U_ck_AttachmentEntry"];

  //       if (attachmentEntry != null) {
  //         final attachmentRes =
  //             await dio.getAttachment("/Attachments2($attachmentEntry)");

  //         if (attachmentRes.statusCode == 200) {
  //           final attData = attachmentRes.data;
  //           final lines = attData["Attachments2_Lines"] as List<dynamic>;
  //           final token = await LocalStorageManger.getString('SessionId');

  //           for (var line in lines) {
  //             final url =
  //                 "/Attachments2(${line["AbsoluteEntry"]})/\$value?filename='${line["FileName"]}.${line["FileExtension"]}'";

  //             try {
  //               // download bytes
  //               final imgRes = await http.get(
  //                 Uri.parse(
  //                     "https://svr10.biz-dimension.com:9093/api/sapIntegration/Attachments2"),
  //                 headers: {
  //                   'Content-Type': "application/json",
  //                   "Authorization": 'Bearer $token',
  //                   'sapUrl': url
  //                 },
  //               );
  //               if (imgRes.statusCode == 200) {
  //                 // Ensure bytes are valid

  //                 // Save file to temp directory
  //                 final tempDir = await getTemporaryDirectory();
  //                 final fileName =
  //                     "${line["FileName"]}.${line["FileExtension"]}";
  //                 final filePath = "${tempDir.path}/$fileName";
  //                 final file = File(filePath);

  //                 await file.writeAsBytes(imgRes.bodyBytes);
  //                 sapFiles.add(file);
  //               } else {
  //                 String errorMessage = "Unknown error";
  //                 try {
  //                   final decoded = jsonDecode(imgRes.body);
  //                   if (decoded is Map && decoded.containsKey("error")) {
  //                     errorMessage =
  //                         decoded["error"]["message"]["value"].toString();
  //                   }
  //                 } catch (_) {
  //                   // body was not valid JSON
  //                   errorMessage = imgRes.body;
  //                 }

  //                 await MaterialDialog.warning(
  //                   context,
  //                   title: "Error",
  //                   body: "Failed to fetch image: $errorMessage",
  //                 );
  //               }
  //             } catch (e) {
  //               print("Failed to fetch image ${line["FileName"]}: $e");
  //             }
  //           }
  //         }
  //       }

  //       if (!mounted) return;

  //       setState(() {
  //         equipType.text = getDataFromDynamic(data["U_ck_eqStatus"]);
  //         equipName.text = getDataFromDynamic(data['Name']);
  //         equipCode.text = getDataFromDynamic(data['Code']);
  //         customerCode.text = getDataFromDynamic(data['U_ck_CusCode']);
  //         customerName.text = getDataFromDynamic(data['U_ck_CusName']);
  //         serialNumber.text = getDataFromDynamic(data["U_ck_eqSerNum"]);
  //         site.text = getDataFromDynamic(data["U_ck_siteCode"]);
  //         remark.text = getDataFromDynamic(data['U_ck_Remark']);
  //         brand.text = getDataFromDynamic(data["U_ck_eqBrand"]);
  //         model.text = getDataFromDynamic(data["U_ck_eqModel"]);

  //         installedDate.text = getDataFromDynamic(
  //             data['U_ck_InstalDate']?.toString().split("T").first);
  //         nextDate.text = getDataFromDynamic(
  //             data["U_ck_NsvDate"]?.toString().split("T").first);
  //         warrantyDate.text = getDataFromDynamic(
  //             data["U_ck_WarExpDate"]?.toString().split("T").first);
  //       });

  //       // --- Update provider ---
  //       final provider =
  //           Provider.of<EquipmentCreateProvider>(context, listen: false);
  //       provider.setComponents(data["CK_CUSEQUI01Collection"] ?? []);
  //       provider.setParts(data["CK_CUSEQUI02Collection"] ?? []);
  //       provider.setImages(sapFiles); // store list of Files

  //       print("Fetched SAP images: ${sapFiles.length}");
  //     } else {
  //       throw Exception("Failed to load documents");
  //     }
  //   } catch (e) {
  //     print("Error fetching documents: $e");
  //   } finally {
  //     if (mounted) MaterialDialog.close(context);
  //   }
  // }
  Future<void> _initOffline() async {
    // 1️⃣ When creating new equipment
    if (widget.data.isEmpty) {
      installedDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      nextDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      warrantyDate.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      uploadImg.text = "";
      equipType.text = "Active";
      return; // no need to continue
    }

    // 2️⃣ When editing existing equipment
    if (!mounted) return;
    MaterialDialog.loading(context);

    try {
      // --- Get offline provider ---
      final provider =
          Provider.of<EquipmentOfflineProvider>(context, listen: false);

      // --- Load offline equipments ---
      await provider.loadEquipments();

      // --- Find the equipment by code or unique identifier ---
      final offlineData = provider.equipments.firstWhere(
        (e) => e['Code'] == widget.data['Code'],
        orElse: () => {},
      );

      if (offlineData.isEmpty) {
        // Not found offline, fallback to default or show warning
        await MaterialDialog.warning(
          context,
          title: "Warning",
          body: "Equipment not found offline.",
        );
        return;
      }

      // --- Populate controllers ---
      setState(() {
        equipType.text = offlineData['U_ck_eqStatus'] ?? "Active";
        equipName.text = offlineData['Name'] ?? "";
        equipCode.text = offlineData['Code'] ?? "";
        customerCode.text = offlineData['U_ck_CusCode'] ?? "";
        customerName.text = offlineData['U_ck_CusName'] ?? "";
        serialNumber.text = offlineData["U_ck_eqSerNum"] ?? "";
        site.text = offlineData["U_ck_siteCode"] ?? "";
        remark.text = offlineData['U_ck_Remark'] ?? "";
        brand.text = offlineData["U_ck_eqBrand"] ?? "";
        model.text = offlineData["U_ck_eqModel"] ?? "";

        installedDate.text =
            offlineData['U_ck_InstalDate']?.toString().split("T").first ?? "";
        nextDate.text =
            offlineData["U_ck_NsvDate"]?.toString().split("T").first ?? "";
        warrantyDate.text =
            offlineData["U_ck_WarExpDate"]?.toString().split("T").first ?? "";
      });

      // --- Populate provider with components, parts, and images ---
      provider.setComponents(
          List<dynamic>.from(offlineData["CK_CUSEQUI01Collection"] ?? []));
      provider.setParts(
          List<dynamic>.from(offlineData["CK_CUSEQUI02Collection"] ?? []));

      // Convert stored base64 files back to temporary File objects
      final List<File> offlineFiles = [];
      if (offlineData["files"] != null) {
        for (var fileMap in offlineData["files"]) {
          final bytes = base64Decode(fileMap["data"]);
          final tempDir = await getTemporaryDirectory();
          final filePath = "${tempDir.path}/${fileMap['name']}";
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          offlineFiles.add(file);
        }
      }
      provider.setImages(offlineFiles);

      print("Loaded offline images: ${offlineFiles.length}");
    } catch (e) {
      debugPrint("Error loading offline equipment: $e");
      await MaterialDialog.warning(
        context,
        title: "Error",
        body: e.toString(),
      );
    } finally {
      if (mounted) MaterialDialog.close(context);
    }
  }

  void onCreateEQ() async {
    if (equipCode.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Equipment Code is required!",
      );
      return;
    }
    if (equipName.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Equipment Name is required!",
      );
      return;
    }
    if (customerCode.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Customer is required!",
      );
      return;
    }
    if (equipType.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Status is required!",
      );
      return;
    }
    if (brand.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Brand is required!",
      );
      return;
    }
    if (serialNumber.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Serial Number is required!",
      );
      return;
    }
    if (installedDate.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, Installed Date is required!",
      );
      return;
    }
    if (warrantyDate.text.isEmpty) {
      MaterialDialog.requiredFielDialog(
        context,
        title: 'Required Field',
        cancelLabel: "Ok",
        body: "Oops, warranty Expire Date is required!",
      );
      return;
    }
    await Provider.of<EquipmentOfflineProvider>(context, listen: false)
        .saveEquipmentOffline(
      data: {
        "U_ck_eqStatus": equipType.text,
        "U_ck_CusCode": customerCode.text,
        "U_ck_CusName": customerName.text,
        "U_ck_siteCode": site.text,
        "Code": equipCode.text,
        "Name": equipName.text,
        "U_ck_eqSerNum": serialNumber.text,
        "U_ck_eqBrand": brand.text,
        "U_ck_eqModel": model.text,
        "U_ck_Remark": remark.text,
        "U_ck_InstalDate": installedDate.text,
        "U_ck_NsvDate": nextDate.text,
        "U_ck_WarExpDate": warrantyDate.text,
        // Components, parts, and images are automatically included from provider
      },
    );
  }

  void clearAllFields() {
    equipType.clear();
    customerCode.clear();
    customerName.clear();
    site.clear();
    brand.clear();
    equipName.clear();
    equipCode.clear();
    serialNumber.clear();
    model.clear();
    condition.clear();
    remark.clear();
    component.clear();
    uploadImg.clear();
    installedDate.clear();
    nextDate.clear();
    warrantyDate.clear();
    final provider =
        Provider.of<EquipmentCreateProvider>(context, listen: false);
    provider.setComponents([]);
    provider.setParts([]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final provider =
            Provider.of<EquipmentCreateProvider>(context, listen: false);
        provider.clearCollection();

        return true; // Allow navigation to pop
      },
      child: Scaffold(
        body: Stack(
          children: [
            // HEADER (positioned at the back)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 280,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 66, 83, 100),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 40,
                      left: 25,
                      right: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () => {
                                    Provider.of<EquipmentCreateProvider>(
                                            context,
                                            listen: false)
                                        .clearCollection(),
                                    Navigator.of(context).pop()
                                  },
                              child: Container(
                                  width: 28,
                                  height: 28,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                  ),
                                  child: SvgPicture.asset(
                                    color: const Color.fromARGB(
                                        255, 102, 103, 104),
                                    'images/svg/reply.svg',
                                    width: 15,
                                  ))),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (widget.data.isNotEmpty) {
                                    _initOffline();
                                  } else {
                                    clearAllFields();
                                  }
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 27,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  MaterialDialog.loading(context);
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .logout();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  size: 27,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 105,
                        left: 25,
                        right: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'images/svg/key.svg',
                                      width: 30,
                                      height: 30,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text(
                                  "Equipment Setup",
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () =>
                                  widget.data.isEmpty ? onCreateEQ() : null,
                              child: Container(
                                width: 65,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(255, 56, 67, 80)
                                              .withOpacity(
                                                  0.3), // Light gray shadow
                                      spreadRadius: 3, // Smaller spread
                                      blurRadius: 3, // Smaller blur
                                      offset: const Offset(
                                          0, 1), // Minimal vertical offset
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 3, 3),
                                  child: Center(
                                    child: Text(
                                      widget.data.isEmpty ? "Save" : "Detail",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    Positioned(
                      top: 175,
                      left: 28,
                      right: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabTapped(0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                padding: _selectedIndex != 0
                                    ? const EdgeInsets.all(9)
                                    : const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: _selectedIndex == 0
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: Colors.green,
                                            width: 5,
                                          ),
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    "General",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabTapped(1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                padding: _selectedIndex != 1
                                    ? const EdgeInsets.all(9)
                                    : const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: _selectedIndex == 1
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: Colors.green,
                                            width: 5,
                                          ),
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Component",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabTapped(2),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                padding: _selectedIndex != 2
                                    ? const EdgeInsets.all(9)
                                    : const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: _selectedIndex == 2
                                      ? const Border(
                                          bottom: BorderSide(
                                            color: Colors.green,
                                            width: 5,
                                          ),
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Part",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 185,
                      left: 22,
                      right: 25,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: const Row(
                          children: [],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // CONTENT (positioned on top)
            Positioned(
              top: 230, // Adjust this value for the desired overlap
              left: 0,
              right: 0,
              bottom: 0,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: [
                  General(
                    data: widget.data,
                    controller: {
                      "equipCode": equipCode,
                      "equipName": equipName,
                      "customerCode": customerCode,
                      "customerName": customerName,
                      "equipType": equipType,
                      "site": site,
                      "brand": brand,
                      "serialNumber": serialNumber,
                      "remark": remark,
                      "uploadImg": uploadImg,
                      "installedDate": installedDate,
                      "nextDate": nextDate,
                      "warrantyDate": warrantyDate
                    },
                  ),
                  Component(
                    data: widget.data,
                    controller: {
                      "equipCode": equipCode,
                      "equipName": equipName
                    },
                  ),
                  Part(
                    data: widget.data,
                    controller: {
                      "equipCode": equipCode,
                      "equipName": equipName
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
