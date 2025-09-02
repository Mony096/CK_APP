import 'dart:async';
import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/provider/helper_provider.dart';
import 'package:bizd_tech_service/provider/service_list_provider.dart';
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
    await _loadUserName();

    final svProvider = Provider.of<ServiceListProvider>(context, listen: false);
    if (svProvider.documents.isEmpty) {
      await svProvider.fetchDocuments();
    }
    final customerProvider =
        Provider.of<HelperProvider>(context, listen: false);
    if (customerProvider.customer.isEmpty) {
      await customerProvider.fetchCustomer();
    }
    setState(() {
      _isLoading = false;
    });
  }

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
    // if (_pdf.isEmpty) {
    // print(currentStatus);
    // return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please provide a signature')),
    //   );
    //   return;
    // }
    MaterialDialog.loading(context);

    try {
      await Provider.of<UpdateStatusProvider>(context, listen: false)
          .updateDocumentAndStatus(
        docEntry: entry,
        status: currentStatus == "Pending"
            ? "Accept"
            : currentStatus == "Accept"
                ? "Travel"
                : currentStatus == "Travel"
                    ? "Service"
                    : "Entry",
        context: context, // ✅ Corrected here
      );
      Navigator.of(context).pop(); // Go back

      await _refreshData();
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
                      "Status updated successfully!",
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
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    // setState(() => _initialLoading = true);

    final provider = Provider.of<ServiceListProvider>(context, listen: false);
    // ✅ Only fetch if not already loaded
    provider.resetPagination();
    await provider.resfreshFetchDocuments();
    // setState(() => _initialLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceListProvider>(
      builder: (context, serviceProvider, _) {
        final documents = serviceProvider.documents;
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
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextFormField(

              //   controller: null,
              //   decoration: InputDecoration(
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: const BorderSide(
              //         color: Colors.grey,
              //         width: 1.0, // Border color and width when not focused
              //       ),
              //       borderRadius: BorderRadius.circular(5.0), // Rounded corners
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: const Color.fromARGB(255, 123, 125, 126),
              //         width: 1.0, // Border color and width when focused
              //       ),
              //       borderRadius: BorderRadius.circular(5.0), // Rounded corners
              //     ),
              //     contentPadding: const EdgeInsets.only(top: 12),
              //     hintText: 'Search...', // Placeholder text
              //     hintStyle: TextStyle(
              //       fontSize: 14.0, // Placeholder font size
              //       color: Colors.grey,
              //       // Placeholder text color
              //     ),
              //     prefixIcon: Icon(Icons.search),
              //     suffixIcon: IconButton(
              //       icon: Icon(
              //         Icons.list,
              //       ),
              //       onPressed: null,
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              const DateSelector(),
              // SizedBox(
              //   height: 7,
              // ),
              // // CONTENT
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
                                    data: travel,
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
                                      // if (doc["U_lk_delstat"] == "On the Way") {
                                      //   showPODDialog(context, doc["DocEntry"],
                                      //       "Delivered");
                                      // } else {
                                      //   MaterialDialog.loading(
                                      //       context); // Show loading dialog

                                      //   await Provider.of<UpdateStatusProvider>(
                                      //           context,
                                      //           listen: false)
                                      //       .updateDocumentAndStatus(
                                      //           docEntry: doc["DocEntry"],
                                      //           status: doc["U_lk_delstat"] ==
                                      //                   "Started"
                                      //               ? "On the Way"
                                      //               : "",
                                      //           remarks: "",
                                      //           context: context);
                                      //   Future.microtask(() {
                                      //     final provider =
                                      //         Provider.of<DeliveryNoteProvider>(
                                      //             context,
                                      //             listen: false);
                                      //     provider.fetchDocuments();
                                      //   });
                                      //   Navigator.of(context)
                                      //       .pop(); // Close loading dialog AFTER logout finishes
                                      // }
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
  const DateSelector({super.key});

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime _selectedDate = DateTime.now(); // Default to the current date

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the date to "Monday, January 15"
    final formattedDate = DateFormat('EEEE, MMMM d').format(_selectedDate);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(
          color: Colors.green, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(5.0), // Rounded corners
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
              formattedDate, // Display formatted date
              style: const TextStyle(fontSize: 13),
              textScaleFactor: 1.0,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: Color.fromARGB(255, 88, 89, 90),
                  ),
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(width: 3),
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_right,
                    size: 30,
                    color: Color.fromARGB(255, 88, 89, 90),
                  ),
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
