import 'dart:async';
import 'package:bizd_tech_service/component/DateForServiceList.dart';
import 'package:bizd_tech_service/component/DatePickerDialog.dart';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/provider/service_provider.dart';
import 'package:bizd_tech_service/provider/update_status_provider.dart';
import 'package:bizd_tech_service/screens/service/component/block_service.dart';
import 'package:bizd_tech_service/screens/service/screen/sericeEntry.dart';
import 'package:bizd_tech_service/screens/service/screen/serviceById.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/dio_client.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final DioClient dio = DioClient(); // Your custom Dio client

  final bool _isLoading = false;
  List<dynamic> documents = [];
  List<dynamic> warehouses = [];
  String? userName;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _initOffline(); // this safely runs after first build
    // });
  }

  // Future<void> _init() async {
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await _loadUserName();
  //   final svProvider = Provider.of<ServiceListProvider>(context, listen: false);

  //   if (svProvider.documents.isEmpty) {
  //     await svProvider.fetchDocuments(context: context);
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  // Future<void> _initOffline() async {
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   final _userId = await LocalStorageManger.getString('UserId');

  //   await _loadUserName();
  //   final offlineProvider =
  //       Provider.of<ServiceListProviderOffline>(context, listen: false);

  //   await offlineProvider.loadDocuments();

  //   // Use filteredDocs in UI
  //   print("Offline filtered docs: ${offlineProvider");

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  Future<void> _loadUserName() async {
    final name = await getName();
    setState(() {
      userName = name;
    });
  }

  Future<String?> getName() async {
    return await LocalStorageManger.getString('UserName');
  }

  Future<void> onUpdateStatus(entry, currentStatus) async {
    MaterialDialog.loading(context);

    try {
      // ⏳ Wait 1 seconds before updating
      await Future.delayed(const Duration(seconds: 1));

      await Provider.of<ServiceListProviderOffline>(context, listen: false)
          .updateDocumentAndStatusOffline(
        docEntry: entry,
        status: currentStatus == "Pending"
            ? "Accept"
            : currentStatus == "Accept"
                ? "Travel"
                : currentStatus == "Travel"
                    ? "Service"
                    : "Entry",
        context: context,
      );
      final provider = context.read<ServiceListProviderOffline>();
      provider.refreshDocuments(); // clear filter + reload all
      MaterialDialog.close(context);
      //✅ Close loading after update
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    _dateController.clear(); // Clear the date controller
    // final provider = context.read<ServiceListProvider>();
    // provider.resetPagination();
    // provider.clearCurrentDate();
    // await provider.resfreshFetchDocuments(context);
    final provider = context.read<ServiceListProviderOffline>();
    provider.refreshDocuments(); // clear filter + reload all
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceListProviderOffline>(
      builder: (context, serviceProvider, _) {
        final documents = serviceProvider.documents.where((doc) {
          final status = doc['U_CK_Status']?.toString() ?? '';
          final date = doc['U_CK_Date']?.toString() ?? '';
          final dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());

          return status != 'Open' &&
              status != 'Entry' &&
              date.compareTo(dateNow) >= 0;
          // works if date is in yyyy-MM-dd or ISO format
        }).toList();
        final isLoading = serviceProvider.isLoading;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 66, 83, 100),
            // Leading menu icon on the left
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle menu button press or keep it empty for default Drawer action
              },
            ),
            // Centered title
            title: Center(
              child: Text(
                "$userName' Service",
                style: const TextStyle(fontSize: 17, color: Colors.white),
                textScaleFactor: 1.0,
              ),
            ),
            // Right-aligned actions (scan barcode)
            actions: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _refreshData();
                    },
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                  // SizedBox(width: 3),
                  IconButton(
                    onPressed: () async {
                      MaterialDialog.loading(context);
                      await Provider.of<AuthProvider>(context, listen: false)
                          .logout();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: DateForServiceList(
                      controller: _dateController,
                      star: true,
                      detail: false, // set true if you want read-only mode
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 50,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: TextButton(
                        // onPressed: () {
                        //   final provider = context.read<ServiceListProvider>();

                        //   if (_dateController.text.isNotEmpty) {
                        //     print(_dateController.text);

                        //     // Parse using the correct format
                        //     final parsedDate = DateFormat("dd MMMM yyyy")
                        //         .parse(_dateController.text);

                        //     provider.setDate(parsedDate, context);
                        //   }
                        // },
                        onPressed: () {
                          final provider =
                              context.read<ServiceListProviderOffline>();

                          if (_dateController.text.isNotEmpty) {
                            final parsedDate = DateFormat("dd MMMM yyyy")
                                .parse(_dateController.text);

                            provider.setDate(parsedDate);
                            provider.loadDocuments(); // ✅ apply filter
                          }
                        },

                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text("GO",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15),
                            textScaleFactor: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child: isLoading || _isLoading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.green,
                              size: 50.0,
                            ),
                          ),
                        )
                      : documents.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: Text(
                                  "No Service Available",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : Column(children: [
                              const SizedBox(
                                height: 5,
                              ),
                              ...documents.map((travel) => BlockService(
                                    data: travel as dynamic,
                                    onTap: () async {
                                      if (travel["U_CK_Status"] == "Service") {
                                        goTo(
                                                context,
                                                ServiceEntryScreen(
                                                    data: travel))
                                            .then((e) {
                                          if (e == true) {
                                            _refreshData();
                                          }

                                          // Handle any actions after returning from ServiceEntryScreen
                                        });
                                        return;
                                      }
                                      onUpdateStatus(travel["DocEntry"],
                                          travel["U_CK_Status"]);
                                    },
                                  )),
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

class DateSelector extends StatefulWidget {
  final void Function(DateTime)? onDateChanged;

  const DateSelector({super.key, this.onDateChanged});

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime? _selectedDate; // 👈 start as null

  Future<void> _selectDate(BuildContext context) async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      widget.onDateChanged?.call(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate != null
        ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
        : "No Date Selection"; // 👈 show placeholder when empty

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(flex: 1, child: Icon(Icons.date_range)),
          Expanded(
            flex: 4,
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 13),
              textScaleFactor: 1.0,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left,
                      size: 30, color: Color.fromARGB(255, 88, 89, 90)),
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(width: 3),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right,
                      size: 30, color: Color.fromARGB(255, 88, 89, 90)),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
