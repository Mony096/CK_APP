import 'dart:async';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipmentCreateScreen extends StatefulWidget {
  EquipmentCreateScreen({super.key});
  @override
  _EquipmentCreateScreenState createState() => _EquipmentCreateScreenState();
}

class _EquipmentCreateScreenState extends State<EquipmentCreateScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  List<dynamic> customers = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init(); // this safely runs after first build
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER (not scrollable)
              Container(
                height: 180,
                color: const Color.fromARGB(255, 33, 107, 243),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 55,
                      left: 20,
                      right: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 25,
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "${userName ?? 'Loading'}'s Delivery",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
                                  Navigator.of(context).pop(); // Close loading
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
                      top: 115,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 239, 241),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note_alt,
                                      size: 20,
                                      color: Color.fromARGB(255, 85, 73, 73)),
                                  SizedBox(width: 10),
                                  Text(
                                    "Your List of Assigned Service",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 85, 73, 73),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_downward,
                                  size: 21,
                                  color: Color.fromARGB(255, 78, 64, 64)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child:  Column(children: [
                    Text("11"),
            ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

