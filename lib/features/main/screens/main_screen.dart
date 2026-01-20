import 'dart:io';

import 'package:bizd_tech_service/core/widgets/drawer.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/service/screens/service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/core/core.dart';
import 'package:bizd_tech_service/features/dashboard/screens/dashboard_screen.dart';
import 'package:bizd_tech_service/features/equipment/screens/equipment_list.dart';
import 'package:bizd_tech_service/features/main/screens/sync_screen.dart';
import 'package:bizd_tech_service/features/main/screens/account_screen.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bizd_tech_service/core/utils/local_storage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  dynamic _userName;
  dynamic _userEmail;
  bool _isSyncingFromMain = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await LocalStorageManger.getString('FullName');
    final email = await LocalStorageManger.getString('UserName');
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  final List<Widget> _screens = [
    const Dashboard(),
    const ServiceScreen(),
    const EquipmentListScreen(),
    const SyncScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Auto-sync services when screen loads (if online)
  Future<void> _autoSyncServices() async {
    if (_isSyncingFromMain) return;

    final offlineProvider =
        Provider.of<ServiceListProviderOffline>(context, listen: false);

    try {
      setState(() => _isSyncingFromMain = true);
      offlineProvider.setSyncing(true);

      // Check internet connectivity
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        debugPrint("📴 No internet connection - skipping sync");
        return;
      }

      debugPrint("📡 Internet available - starting auto-sync...");

      // Get providers
      final onlineProvider =
          Provider.of<ServiceListProvider>(context, listen: false);

      // Get existing DocEntries from offline storage
      final existingDocEntries = await offlineProvider.getExistingDocEntries();
      debugPrint(
          "📦 Found ${existingDocEntries.length} existing offline records");

      // Fetch only NEW services from API
      final newServices = await onlineProvider.fetchNewServicesForSync(
        existingDocEntries: existingDocEntries,
      );

      if (newServices.isNotEmpty) {
        // Merge new services with existing offline data
        await offlineProvider.mergeNewDocuments(newServices);
        debugPrint(
            "✅ Auto-sync complete: ${newServices.length} new services added");
      } else {
        debugPrint("✅ Auto-sync complete: No new services to add");
        // Still load documents to refresh the view
        await offlineProvider.loadDocuments();
      }
    } catch (e) {
      debugPrint("❌ Auto-sync error: $e");
    } finally {
      if (mounted) {
        setState(() => _isSyncingFromMain = false);
        offlineProvider.setSyncing(false);
      }
    }
  }

  /// Check if device has internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: Consumer2<ServiceListProviderOffline, EquipmentOfflineProvider>(
          builder: (context, serviceOffline, equipmentOffline, child) {
            final totalPending = serviceOffline.pendingSyncCount +
                equipmentOffline.pendingSyncCount;

            return ModernDrawer(
              selectedIndex: _selectedIndex,
              // userName: "Reaksmey Kunmony",
              // userEmail: "Example12@gmail.com",
              userName: _userName,
              userEmail: _userEmail,
              onItemSelected: _onItemTapped,
              items: [
                const DrawerItem(
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                ),
                const DrawerItem(
                  label: 'Service',
                  icon: Icons.miscellaneous_services_outlined,
                  activeIcon: Icons.miscellaneous_services_rounded,
                ),
                const DrawerItem(
                  label: 'Equipment',
                  icon: Icons.build_outlined,
                  activeIcon: Icons.build_rounded,
                ),
                DrawerItem(
                  label: 'Sync',
                  icon: Icons.sync_outlined,
                  activeIcon: Icons.sync_rounded,
                  badgeCount: totalPending,
                ),
                const DrawerItem(
                  label: 'Account',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                ),
              ],
            );
          },
        ),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            _selectedIndex == 0
                ? 'Dashboard'
                : _selectedIndex == 1
                    ? 'Services'
                    : _selectedIndex == 2
                        ? 'Equipments'
                        : _selectedIndex == 3
                            ? 'Sync Data'
                            : 'Account Settings',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Consumer2<ServiceListProviderOffline, EquipmentOfflineProvider>(
              builder: (context, serviceOffline, equipmentOffline, child) {
                final isSyncing =
                    serviceOffline.isSyncing || equipmentOffline.isSyncing;

                if (!isSyncing) return const SizedBox.shrink();
                if (_selectedIndex > 1) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent,
                          ),
                        ),
                      ),
                      // const SizedBox(width: 8),
                      // Text(
                      //   "Syncing...",
                      //   style: GoogleFonts.inter(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w500,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
            _selectedIndex == 0 || _selectedIndex == 1 ?
             IconButton(onPressed: _autoSyncServices, icon: const Icon(Icons.sync_rounded)) : const SizedBox.shrink(),
          ],
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Use a simple fade for maximum stability
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(_selectedIndex),
            child: _screens[_selectedIndex],
          ),
        ),
        // bottomNavigationBar: Container(
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     border: Border(
        //       top: BorderSide(
        //         color: const Color.fromARGB(255, 234, 234, 237),
        //         width: 1,
        //       ),
        //     ),
        //   ),
        //   padding: const EdgeInsets.symmetric(
        //     horizontal: 8,
        //   ),
        //   child:
        //       Consumer2<ServiceListProviderOffline, EquipmentOfflineProvider>(
        //     builder: (context, serviceOffline, equipmentOffline, child) {
        //       final totalPending = serviceOffline.pendingSyncCount +
        //           equipmentOffline.pendingSyncCount;

        //       return AdaptiveBottomNavBar(
        //         selectedIndex: _selectedIndex,
        //         onItemTapped: _onItemTapped,
        //         items: [
        //           const AdaptiveNavItem(
        //             label: 'Dashboard',
        //             icon: Icons.dashboard_outlined,
        //             activeIcon: Icons.dashboard,
        //           ),
        //           const AdaptiveNavItem(
        //             label: 'Service',
        //             icon: Icons.miscellaneous_services_outlined,
        //             activeIcon: Icons.miscellaneous_services,
        //           ),
        //           const AdaptiveNavItem(
        //             label: 'Equipment',
        //             icon: Icons.build_outlined,
        //             activeIcon: Icons.build,
        //           ),
        //           AdaptiveNavItem(
        //             label: 'Sync',
        //             icon: Icons.sync_outlined,
        //             activeIcon: Icons.sync,
        //             badgeCount: totalPending,
        //           ),
        //           const AdaptiveNavItem(
        //             label: 'Account',
        //             icon: Icons.person_outline,
        //             activeIcon: Icons.person,
        //           ),
        //         ],
        //       );
        //     },
        //   ),
        // ),
      ),
    );
  }
}
