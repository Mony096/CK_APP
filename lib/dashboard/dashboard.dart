import 'package:bizd_tech_service/middleware/LoginScreen.dart';
import 'package:bizd_tech_service/provider/auth_provider.dart';
import 'package:bizd_tech_service/screens/equipment/equipment_list.dart';
import 'package:bizd_tech_service/screens/service/service.dart';
import 'package:bizd_tech_service/utilities/dialog/dialog.dart';
import 'package:bizd_tech_service/utilities/storage/locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.fromNotification = false});
  final bool fromNotification;
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // void init(BuildContext context) async {
  //   // Initialization logic here
  // }
  Widget _buildDrawerItem(
      IconData icon, String title, int index, Widget screen) {
    return Container(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Attach the GlobalKey to the Scaffold
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 115, 117, 122),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
        title: const Center(
          child: Text(
            'Bizd Service Mobile',
            style: TextStyle(fontSize: 17),
            textScaleFactor: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Row(
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white),
              ],
            ),
            onPressed: () {
              // Handle scan barcode action
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55.0),
          child: Container(
            color: Colors.white, // Background color of the TabBar
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        Color.fromARGB(255, 56, 56, 61), // Active border color
                    width: 2.0, // Border width
                  ),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Ticket",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 62, 62, 67)),
                      textScaleFactor: 1.0,
                    )),
                Container(
                    padding: const EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "KPI",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Color.fromARGB(255, 62, 62, 67)),
                      textScaleFactor: 1.0,
                    )),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Profile Section
            UserAccountsDrawerHeader(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 66, 83, 100)),
              currentAccountPicture: SizedBox(
                width: 20, // control size here
                height: 20,
                child: SvgPicture.asset(
                  'images/svg/key.svg',
                  color: const Color.fromARGB(255, 49, 134, 69),
                  fit: BoxFit.contain,
                ),
              ),
              accountName: Text(
                userName ?? '...',
                style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text(
                'George_Keeng88@gmail.com',
                style: TextStyle(color: Color.fromARGB(137, 255, 255, 255)),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                      Icons.settings, "Service", 0, const ServiceScreen()),
                  _buildDrawerItem(
                      Icons.build, "Equipment", 1, const EquipmentListScreen()),
                  // _buildDrawerItem(
                  //     Icons.star_border, "Starred", 2, SomeOtherScreen()),
                ],
              ),
            ),

            const Divider(),

            // Bottom Settings
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black54),
              title: const Text("Log out"),
              onTap: () async {
                MaterialDialog.loading(context);
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                Navigator.of(context).pop(); // Close loading
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Container(
              child: const Text("Content for Ticket"),
            ),
          ),
          Center(
            child: Container(
              child: const Text("Content for KPI"),
            ),
          ),
        ],
      ),
    );
  }
}
