import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:walkzero/constwidget/thememode.dart';
import 'package:walkzero/models/drawermodels.dart';
import 'package:walkzero/screens/constants.dart';
import 'package:walkzero/screens/loginpage/loginpage.dart';
//import 'package:walkzero/screens/meetingzone.dart';
import 'package:walkzero/screens/walkzeromeet/trailmeetingzone.dart';
import 'package:walkzero/screens/walkzeromeet/web_rtc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Signaling signaling = Signaling();
  //final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    //_localRenderer.initialize();
    //_remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ListTile(
          title: Text('Home'),
          subtitle: Text('walkzero'),
        ),
      ),
      drawer: drawer(),
      //drawerScrimColor: Colors.transparent,
      body: Container(),
    );
  }

  Widget drawer() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Drawer(
      width: 250,
      child: ListView(
        children: [
          DrawerHeader(
              child: Row(
            children: [
              walkzeroLogo(30),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Walkzero',
                  style: TextStyle(fontSize: titleSize),
                ),
              ),
            ],
          )),
          drawerList(Icons.video_camera_front_rounded, 'Walkzero Meet', () {
            //signaling.openUserMedia(_localRenderer, _remoteRenderer);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MeetingHomePage()));
          }),
          const Divider(),
          drawerList(Icons.language, 'Language', () => null),
          drawerList(Icons.key_rounded, 'Password Change', () => null),
          const Divider(),
          drawerList(
            Icons.brightness_medium_outlined,
            'DarkMode',
            () => null,
            trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  setState(() {
                    final provider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    provider.toggleTheme(value);
                  });
                }),
          ),
          const Divider(),
          drawerList(
              Icons.logout_outlined,
              'LogOut',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()))),
        ],
      ),
    );
  }

  Widget drawerList(IconData icon, String title, Function() onTap,
      {Widget? trailing}) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: const TextStyle(color: textColor, fontSize: subtitleSize),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget walkzeroLogo(double size) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: size,
      width: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage("assets/images/walkzero_logo3.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

//coomplex Drawer code....

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  int selectedIndex = -1; //dont set it to 0

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: row(),
    );
  }

  Widget row() {
    return Row(children: [
      isExpanded ? blackIconTiles() : blackIconMenu(),
      invisibleSubMenus(),
    ]);
  }

  Widget blackIconTiles() {
    return Container(
      width: 200,
      color: complexDrawerBlack,
      child: Column(
        children: [
          controlTile(),
          Expanded(
            child: ListView.builder(
              itemCount: cdms.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                DrawerModel cdm = cdms[index];
                bool selected = selectedIndex == index;
                return ExpansionTile(
                    onExpansionChanged: (z) {
                      setState(() {
                        selectedIndex = z ? index : -1;
                      });
                    },
                    leading: Icon(cdm.icon, color: Colors.white),
                    title: Text(cdm.title!),
                    // Txt(
                    //   text: cdm.title,
                    //   color: Colors.white,
                    // ),
                    trailing: cdm.submenu!.isEmpty
                        ? null
                        : Icon(
                            selected
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    children: cdm.submenu!.map((subMenu) {
                      return sMenuButton(subMenu, false);
                    }).toList());
              },
            ),
          ),
          accountTile(),
        ],
      ),
    );
  }

  Widget controlTile() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: ListTile(
        leading: walkzeroLogo(30),
        //FlutterLogo(),
        title: const Text(
          'Walkzero',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Txt(
        //   text: "FlutterShip",
        //   fontSize: 18,
        //   color: Colors.white,
        //   fontWeight: FontWeight.bold,
        // ),
        onTap: expandOrShrinkDrawer,
      ),
    );
  }

  Widget blackIconMenu() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 70,
      color: complexDrawerBlack,
      child: Column(
        children: [
          controlButton(),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child:
                          Icon(cdms[index].icon, color: Colors.orange.shade700),
                    ),
                  );
                }),
          ),
          accountButton(),
        ],
      ),
    );
  }

  Widget invisibleSubMenus() {
    // List<CDM> _cmds = cdms..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      color: compexDrawerCanvasColor,
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (context, index) {
                  DrawerModel cmd = cdms[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  bool selected = selectedIndex == index;
                  bool isValidSubMenu = selected && cmd.submenu!.isNotEmpty;
                  return subMenuWidget(
                      [cmd.title!, ...cmd.submenu!], isValidSubMenu);
                }),
          ),
        ],
      ),
    );
  }

  Widget controlButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: walkzeroLogo(40),
        ),
      ),
    );
  }

  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 37.5 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isValidSubMenu ? complexDrawerBlueGrey : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: isValidSubMenu ? submenus.length : 0,
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return sMenuButton(subMenu, index == 0);
          }),
    );
  }

  Widget sMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () {
        //handle the function
        //if index==0? donothing: doyourlogic here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          subMenu,
          style: TextStyle(
            fontSize: isTitle ? 17 : 14,
            color: isTitle ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Txt(
        //   text: subMenu,
        //   fontSize: isTitle ? 17 : 14,
        //   color: isTitle ? Colors.white : Colors.grey,
        //   fontWeight: FontWeight.bold,
        // ),
      ),
    );
  }

  Widget accountButton({bool usePadding = true}) {
    return Padding(
      padding: EdgeInsets.all(usePadding ? 8 : 0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          // color: Colors.white70,
          image: const DecorationImage(
            image: AssetImage("assets/images/thinq24_logo_unbg.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget walkzeroLogo(double size) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: size,
      width: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage("assets/images/walkzero_logo3.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget accountTile() {
    return Container(
      color: complexDrawerBlueGrey,
      child: ListTile(
        leading: accountButton(usePadding: false),
        title: const Text('Thinq24'),
        // Txt(
        //   text: "Prem Shanhi",
        //   color: Colors.white,
        // ),
        subtitle: const Text(
          'www.thinq24.com',
          style: TextStyle(fontSize: subtitleSize),
        ),
        // Txt(
        //   text: "Web Designer",
        //   color: Colors.white70,
        // ),
      ),
    );
  }

  static List<DrawerModel> cdms = [
    // CDM(Icons.grid_view, "Control", []),

    DrawerModel(
      icon: Icons.grid_view,
      title: "Home",
      submenu: [],
    ),
    DrawerModel(
        icon: Icons.people,
        title: "Employees",
        submenu: ["Add Employee", "Remove Employee"]),
    DrawerModel(
        icon: Icons.markunread_mailbox,
        title: "Vendors",
        submenu: ["Add", "Edit", "Delete"]),
    DrawerModel(
        icon: Icons.pie_chart,
        title: "Analytics",
        submenu: ["Company Performance"]),
    DrawerModel(
        icon: Icons.calendar_month_outlined,
        title: "Attendance",
        submenu: ["Log", "Apply Leaves"]),
    DrawerModel(
        icon: Icons.power,
        title: "Plugins",
        submenu: ["Ad Blocker", "Everything Https", "Dark Mode"]),
    DrawerModel(
        icon: Icons.smart_screen_outlined, title: "Meeting Zone", submenu: []),
    DrawerModel(
        icon: Icons.settings,
        title: "Setting",
        submenu: ["Language", "Password change", "Dark Mode"]),
    DrawerModel(icon: Icons.logout_outlined, title: "Exit", submenu: []),
  ];

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}
