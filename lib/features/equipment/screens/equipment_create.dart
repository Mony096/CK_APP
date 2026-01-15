import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_create_provider.dart';
import 'package:bizd_tech_service/features/equipment/screens/component/general.dart';
import 'package:bizd_tech_service/features/equipment/screens/component/component.dart';
import 'package:bizd_tech_service/features/equipment/screens/component/part.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/core/network/dio_client.dart';
import 'package:bizd_tech_service/core/core.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        orElse: () => <String, dynamic>{},
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

      // --- Populate provider with components, parts ---
      provider.setComponents(
          List<dynamic>.from(offlineData["CK_CUSEQUI01Collection"] ?? []));
      provider.setParts(
          List<dynamic>.from(offlineData["CK_CUSEQUI02Collection"] ?? []));

      // --- Convert stored base64 files back to temporary File objects ---
      final List<File> offlineFiles = [];
      if (offlineData["files"] != null) {
        int i = 0;
        for (var fileMap in offlineData["files"]) {
          final bytes = base64Decode(fileMap["data"]);
          final tempDir = await getTemporaryDirectory();

          // ✅ ensure unique filename (avoids overwriting)
          final filePath =
              "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${i}_${fileMap['name']}";
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          offlineFiles.add(file);
          i++;
        }
      }

      // ✅ Replace images list (not append duplicates)
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
        .saveEquipmentOffline(data: {
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
    }, context: context);
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
        Provider.of<EquipmentOfflineProvider>(context, listen: false);
    provider.setComponents([]);
    provider.setParts([]);
  }

  void onBackScreen() {
    MaterialDialog.warningBackScreen(
      context,
      title: '',
      body: "Are you sure you want to go back without Saving?",
      confirmLabel: "Yes",
      cancelLabel: "No",
      onConfirm: () {
        Provider.of<EquipmentOfflineProvider>(context, listen: false)
            .clearCollection();
        Navigator.of(context).pop();
      },

      onCancel: () {},
      icon: Icons.question_mark, // 👈 Pass the icon here
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.data.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        final provider =
            Provider.of<EquipmentOfflineProvider>(context, listen: false);
        provider.clearCollection();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            isEditing ? "Equipment Detail" : "New Equipment",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 66, 83, 100),
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {
              if (isEditing) {
                Provider.of<EquipmentOfflineProvider>(context, listen: false)
                    .clearCollection();
                Navigator.of(context).pop();
              } else {
                onBackScreen();
              }
            },
          ),
          actions: isEditing
              ? null
              : [
                  TextButton(
                    onPressed: onCreateEQ,
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
        ),
        body: Column(
          children: [
            // Premium Tab Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('General', 0),
                  _buildTabButton('Component', 1),
                  _buildTabButton('Part', 2),
                ],
              ),
            ),
            // Content
            Expanded(
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
        bottomNavigationBar: AdaptiveBottomNavBar(
          selectedIndex: 2, // Equipment tab
          onItemTapped: (index) {
            if (index != 2) {
              // Navigate back and let MainScreen handle the tab change
              Provider.of<EquipmentOfflineProvider>(context, listen: false)
                  .clearCollection();
              Navigator.of(context).pop(index);
            }
          },
          items: const [
            AdaptiveNavItem(
              label: 'Home',
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
            ),
            AdaptiveNavItem(
              label: 'Service',
              icon: Icons.miscellaneous_services_outlined,
              activeIcon: Icons.miscellaneous_services,
            ),
            AdaptiveNavItem(
              label: 'Equipment',
              icon: Icons.build_outlined,
              activeIcon: Icons.build,
            ),
            AdaptiveNavItem(
              label: 'Sync',
              icon: Icons.sync_outlined,
              activeIcon: Icons.sync,
            ),
            AdaptiveNavItem(
              label: 'Account',
              icon: Icons.person_outline,
              activeIcon: Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color:
                    isSelected ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey.shade500,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
