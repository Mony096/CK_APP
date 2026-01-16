import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizd_tech_service/core/core.dart';
import 'package:bizd_tech_service/features/dashboard/screens/dashboard_screen.dart';
import 'package:bizd_tech_service/features/service/screens/service.dart';
import 'package:bizd_tech_service/features/equipment/screens/equipment_list.dart';
import 'package:bizd_tech_service/features/main/screens/sync_screen.dart';
import 'package:bizd_tech_service/features/main/screens/account_screen.dart';
import 'package:bizd_tech_service/features/service/provider/service_list_provider_offline.dart';
import 'package:bizd_tech_service/features/equipment/provider/equipment_offline_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: const Color.fromARGB(255, 234, 234, 237),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child:
              Consumer2<ServiceListProviderOffline, EquipmentOfflineProvider>(
            builder: (context, serviceOffline, equipmentOffline, child) {
              final totalPending = serviceOffline.pendingSyncCount +
                  equipmentOffline.pendingSyncCount;

              return AdaptiveBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                items: [
                  const AdaptiveNavItem(
                    label: 'Dashboard',
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                  ),
                  const AdaptiveNavItem(
                    label: 'Service',
                    icon: Icons.miscellaneous_services_outlined,
                    activeIcon: Icons.miscellaneous_services,
                  ),
                  const AdaptiveNavItem(
                    label: 'Equipment',
                    icon: Icons.build_outlined,
                    activeIcon: Icons.build,
                  ),
                  AdaptiveNavItem(
                    label: 'Sync',
                    icon: Icons.sync_outlined,
                    activeIcon: Icons.sync,
                    badgeCount: totalPending,
                  ),
                  const AdaptiveNavItem(
                    label: 'Account',
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
