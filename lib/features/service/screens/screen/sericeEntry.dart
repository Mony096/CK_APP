import 'package:bizd_tech_service/core/utils/helper_utils.dart';
import 'package:bizd_tech_service/features/auth/screens/login_screen.dart';
import 'package:bizd_tech_service/features/auth/provider/auth_provider.dart';
import 'package:bizd_tech_service/features/service/provider/completed_service_provider.dart';
import 'package:bizd_tech_service/features/customer/provider/customer_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:bizd_tech_service/core/providers/helper_provider.dart';
import 'package:bizd_tech_service/features/item/provider/item_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/site/provider/site_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/screen/image.dart';
import 'package:bizd_tech_service/features/service/screens/screen/materialReserve.dart';
import 'package:bizd_tech_service/features/service/screens/screen/openIssue.dart';
import 'package:bizd_tech_service/features/service/screens/screen/serviceCheckList.dart';
import 'package:bizd_tech_service/features/service/screens/screen/signature.dart';
import 'package:bizd_tech_service/features/service/screens/screen/time.dart';
import 'package:bizd_tech_service/core/utils/dialog_utils.dart';
import 'package:bizd_tech_service/features/service/screens/component/status_stepper.dart';
import 'package:bizd_tech_service/features/service/screens/component/service_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServiceEntryScreen extends StatefulWidget {
  const ServiceEntryScreen({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  __ServiceEntryScreenState createState() => __ServiceEntryScreenState();
}

class __ServiceEntryScreenState extends State<ServiceEntryScreen> {
  void onCompletedService() async {
    // final res =
    //     await Provider.of<CompletedServiceProvider>(context, listen: false)
    //         .onCompletedService(
    //             context: context,
    //             attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
    //             docEntry: widget.data["DocEntry"]);
    // setState(() {
    //   print("asasa");
    // });
    final res =
        await Provider.of<CompletedServiceProvider>(context, listen: false)
            .onCompletedServiceOffline(
      context: context,
      attachmentEntryExisting: widget.data["U_CK_AttachmentEntry"],
      docEntry: widget.data["DocEntry"],
      startTime: widget.data["U_CK_Time"],
      endTime: widget.data["U_CK_EndTime"],
    );
    if (res) {
      Navigator.of(context).pop(true); // Return true to previous screen
    }
  }

  Future<void> clearOfflineDataWithLogout(BuildContext context) async {
    final offlineProviderService =
        Provider.of<ServiceListProviderOffline>(context, listen: false);
    final offlineProviderServiceCustomer =
        Provider.of<CustomerListProviderOffline>(context, listen: false);
    final offlineProviderServiceItem =
        Provider.of<ItemListProviderOffline>(context, listen: false);
    final offlineProviderEquipment =
        Provider.of<EquipmentOfflineProvider>(context, listen: false);
    final offlineProviderSite =
        Provider.of<SiteListProviderOffline>(context, listen: false);

    try {
      // Clear service data
      await offlineProviderService.clearDocuments();
      await offlineProviderServiceCustomer.clearDocuments();
      await offlineProviderServiceItem.clearDocuments();
      await offlineProviderEquipment.clearEquipments();
      await offlineProviderSite.clearDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear data: $e")),
      );
    }
    // Show loading popup
  }

  void onBackScreen() {
    MaterialDialog.warningBackScreen(
      context,
      title: '',
      body: "Are you sure you want to go back without completing?",
      confirmLabel: "Yes",
      cancelLabel: "No",
      onConfirm: () {
        context.read<CompletedServiceProvider>().clearData();
        Navigator.of(context).pop(); // Close warning dialog first
      },

      onCancel: () {},
      icon: Icons.question_mark, // 👈 Pass the icon here
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          context.read<CompletedServiceProvider>().clearData();
          return true; // Allow navigation to pop
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF425364),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                onBackScreen();
              },
            ),
            title: Text(
              'Service Entry',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              IconButton(
                onPressed: () async {
                  MaterialDialog.loading(context);
                  await clearOfflineDataWithLogout(context);
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreenV2()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                // Status Stepper
                StatusStepper(status: widget.data["U_CK_Status"] ?? "Open"),
                
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    children: [
                      // Service Info Card
                      ServiceInfoCard(data: widget.data),
                      const SizedBox(height: 16),
                        //////Enddddddddddddddddddddddddddddddddddddddddddddd
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                ServiceCheckListScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Checklist',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/activity.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                MaterialReserveScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Material Reserve',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/material.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(
                                context,
                                ImageScreen(
                                  data: widget.data,
                                ));
                          },
                          child: Menu(
                            title: 'Image',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/image.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, TimeScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Time Entry',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/clock.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, SignatureScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Signature',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/signature.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            goTo(context, OpenIssueScreen(data: widget.data));
                          },
                          child: Menu(
                            title: 'Open Issue',
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: SvgPicture.asset(
                                color: Colors.green,
                                'images/svg/report.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        /////do somthing
                        const SizedBox(
                          height: 7,
                        ),
                      ]),
                    ),
                  ],
                )),
          ),
          bottomNavigationBar: Container(
            color: Colors.white,
            height: 105,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            child: Row(
              children: [
                Expanded(flex: 2, child: Container()),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onCompletedService();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Complete",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ));
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key, this.icon, required this.title});
  final Widget? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800),
            ),
          ),
          Icon(Icons.navigate_next, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
