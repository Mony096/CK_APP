import 'package:bizd_tech_service/helper/helper.dart';
import 'package:bizd_tech_service/screens/equipment/equipment_list.dart';
import 'package:bizd_tech_service/screens/recently/recently_list.dart';
import 'package:bizd_tech_service/screens/service/service.dart';
import 'package:flutter/material.dart';

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
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 33, 107, 243),
              ),
              child: Text(
                'Bizd Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
                textScaleFactor: 1.0,
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.settings,
                      color: const Color.fromARGB(255, 64, 65, 67)),
                  SizedBox(width: 10),
                  Text(
                    'Service',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                ],
              ),
              onTap: () {
                goTo(context, ServiceScreen());
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.build,
                      color: const Color.fromARGB(255, 64, 65, 67)),
                  SizedBox(width: 10),
                  Text(
                    'Equipment',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                ],
              ),
              onTap: () {
                goTo(context, EquipmentListScreen());
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.logout,
                      color: const Color.fromARGB(255, 64, 65, 67)),
                  SizedBox(width: 10),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textScaleFactor: 1.0,
                  ),
                ],
              ),
              onTap: () {
                // _logout(context);
                // goTo(context, LoginScreen());
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
