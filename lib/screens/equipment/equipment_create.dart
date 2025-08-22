import 'dart:async';
import 'package:bizd_tech_service/component/text_field.dart';
import 'package:bizd_tech_service/component/text_remark.dart';
import 'package:bizd_tech_service/component/title_break.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/equipment/component/general.dart';
import 'package:bizd_tech_service/screens/equipment/component/component.dart';
import 'package:bizd_tech_service/screens/equipment/component/part.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipmentCreateScreen extends StatefulWidget {
  const EquipmentCreateScreen({super.key});
  @override
  _EquipmentCreateScreenState createState() => _EquipmentCreateScreenState();
}

class _EquipmentCreateScreenState extends State<EquipmentCreateScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client
  int _selectedIndex = 0; // Tracks the selected tab
  late PageController _pageController; // Page controller for body content
  bool _isLoading = false;
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
      _init(); // this safely runs after first build
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

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final dnProvider =
        Provider.of<DeliveryNoteProvider>(context, listen: false);
    if (dnProvider.documents.isEmpty) {
      await dnProvider.fetchDocuments();
    }

    final whProvider = Provider.of<HelperProvider>(context, listen: false);
    if (whProvider.warehouses.isEmpty) {
      await whProvider.fetchWarehouse();
    }

    final customerProvider =
        Provider.of<HelperProvider>(context, listen: false);
    if (customerProvider.customer.isEmpty) {
      await customerProvider.fetchCustomer();
    }

    if (!mounted) return;
    setState(() {
      warehouses = whProvider.warehouses;
      customers = customerProvider.customer;

      _isLoading = false;
    });
  }

  void onCompletedSkip(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry,
            status: "Delivered",
            remarks: "",
            context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void onFailedDelivery(dynamic entry, List<dynamic> documents) async {
    MaterialDialog.loading(context); // Show loading dialog
    await Provider.of<UpdateStatusProvider>(context, listen: false)
        .updateDocumentAndStatus(
            docEntry: entry, status: "Failed", remarks: "", context: context);
    await Future.microtask(() {
      final provider =
          Provider.of<DeliveryNoteProvider>(context, listen: false);
      provider.fetchDocuments();
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryNoteProvider>(
      builder: (context, deliveryProvider, _) {
        final documents = deliveryProvider.documents;
        final isLoading = deliveryProvider.isLoading;

        return Scaffold(
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
                                onTap: () => Navigator.of(context).pop(),
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
                                    Future.microtask(() {
                                      final provider =
                                          Provider.of<DeliveryNoteProvider>(
                                              context,
                                              listen: false);
                                      provider.fetchDocuments();
                                    });
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
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                // onTap: () =>
                                //     goTo(context, EquipmentCreateScreen()),
                                child: Container(
                                  width: 65,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 56, 67, 80)
                                            .withOpacity(
                                                0.3), // Light gray shadow
                                        spreadRadius: 3, // Smaller spread
                                        blurRadius: 3, // Smaller blur
                                        offset: const Offset(
                                            0, 1), // Minimal vertical offset
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 3, 3),
                                    child: Center(
                                      child: Text(
                                        "save",
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => _onTabTapped(0),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds:
                                              500), // 1 second animation
                                      curve: Curves.easeInOut,
                                      width: 105,
                                      padding: _selectedIndex != 0
                                          ? const EdgeInsets.all(9)
                                          : const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: _selectedIndex == 0
                                            ? Border(
                                                bottom: BorderSide(
                                                  color: _selectedIndex == 0
                                                      ? Colors.green
                                                      : Colors.transparent,
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
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () => _onTabTapped(1),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds:
                                              500), // 1-second animation
                                      curve: Curves.easeInOut,
                                      width: 110,
                                      padding: _selectedIndex != 1
                                          ? const EdgeInsets.all(9)
                                          : const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: _selectedIndex == 1
                                            ? Border(
                                                bottom: BorderSide(
                                                  color: _selectedIndex == 1 &&
                                                          !_isTransitioningBetween0And2
                                                      ? Colors.green
                                                      : Colors.transparent,
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
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  GestureDetector(
                                    onTap: () => _onTabTapped(2),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds:
                                              500), // 0.7-second animation
                                      curve: Curves.easeInOut,
                                      width: 110,
                                      padding: _selectedIndex != 2
                                          ? const EdgeInsets.all(9)
                                          : const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: _selectedIndex == 2
                                            ? Border(
                                                bottom: BorderSide(
                                                  color: _selectedIndex == 2
                                                      ? Colors.green
                                                      : Colors.transparent,
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
                                  )
                                ],
                              ),
                            ],
                          )),
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
                      controller: {
                        "equipCode": equipCode,
                        "equipName": equipName,
                        "customerCode": customerCode,
                        "equipType": equipType,
                        "site": site,
                        "brand": brand,
                        "serialNumber": serialNumber,
                        "remark": remark,
                        "uploadImg":uploadImg,
                        "installedDate": installedDate,
                        "nextDate": nextDate,
                        "warrantyDate": warrantyDate
                      },
                    ),
                     Component(
                      controller: {
                        "equipCode": equipCode,
                        "equipName": equipName
                      },
                    ),
                     Part(
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
        );
      },
    );
  }
}
