import 'package:bizd_tech_service/screens/equipment/equipment_list.dart';
import 'package:bizd_tech_service/screens/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key, this.fromNotification = false});
  final bool fromNotification;
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(title, style: TextStyle(color: Colors.black87)),
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
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer
          },
        ),
        title: Center(
          child: Text(
            'Bizd Service Mobile',
            style: TextStyle(fontSize: 17),
            textScaleFactor: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Row(
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
          preferredSize: Size.fromHeight(55.0),
          child: Container(
            color: Colors.white, // Background color of the TabBar
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(
                        255, 56, 56, 61), // Active border color
                    width: 2.0, // Border width
                  ),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Ticket",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 62, 62, 67)),
                      textScaleFactor: 1.0,
                    )),
                Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "KPI",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 62, 62, 67)),
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
              decoration: BoxDecoration(color: Color.fromARGB(255, 66, 83, 100)),
              currentAccountPicture: SvgPicture.asset(
                color: const Color.fromARGB(255, 102, 103, 104),
                'images/svg/reply.svg',
                width: 15,
              ),
              accountName: Text(
                'Sandra Adams',
                style:
                    TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                'sandra_a88@gmail.com',
                style: TextStyle(color: const Color.fromARGB(137, 255, 255, 255)),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.settings, "Service", 0, ServiceScreen()),
                  _buildDrawerItem(
                      Icons.build, "Equipment", 1, EquipmentListScreen()),
                  // _buildDrawerItem(
                  //     Icons.star_border, "Starred", 2, SomeOtherScreen()),
                ],
              ),
            ),

            Divider(),

            // Bottom Settings
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black54),
              title: Text("Log out"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Container(
              child: Text("Content for Ticket"),
            ),
          ),
          Center(
            child: Container(
              child: Text("Content for KPI"),
            ),
          ),
        ],
      ),
    );
  }
}
