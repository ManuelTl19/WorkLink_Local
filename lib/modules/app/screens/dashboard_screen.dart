import 'package:worklink_local/utils/logger.dart';

import '../../../utils/widgets/widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';

// Screens
import 'package:worklink_local/modules/app/screens/starter/home_screen.dart';
import 'package:worklink_local/modules/settings/screens/settings_screen.dart';

import '../components/drawer_content.dart';

int screenIndex = 1;
final dashController = PageController(initialPage: 1);

GlobalKey<ScaffoldState> dashboardKey = GlobalKey<ScaffoldState>();

void showDrawer() {
  logInfo('Opening drawer');
  try {
    dashboardKey.currentState?.openDrawer();
  } catch (e) {
    logError('Error opening drawer: $e');
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _screens = [
    const MessagesScreen(),
    const HomeScreen(),
    const SettingsScreen(),
  ];

  List notifications = [];

  @override
  void initState() {
    dashController.addListener(() {
      setState(() {
        screenIndex = dashController.page!.round();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => Dialogs.exitDialog(context),
        child: Scaffold(
          key: dashboardKey,
          extendBody: true,
          extendBodyBehindAppBar: true,
          // floatingActionButton: FloatingActionButton(
          //   heroTag: 'home-button',
          //   onPressed: () => showQuickActionsBottomSheet(context),
          //   backgroundColor: Style.getPrimaryColor(),
          //   shape: const CircleBorder(),
          //   child: Icon(Icons.add, color: Style.white, size: 20.w),
          // ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            backgroundColor: Style.getBackgroundColor(),
            elevation: 0,
            toolbarHeight: 0,
          ),
          drawer: Drawer(
            backgroundColor: Style.getBackgroundColor(),
            width: 300.w,
            child: DrawerContent(),
          ),
          body: SafeArea(
            bottom: false,
            child: PageView.builder(
              controller: dashController,
              itemCount: _screens.length,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              onPageChanged: (index) {
                setState(() {
                  screenIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return _screens[index];
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Style.transparent,
              boxShadow: [
                BoxShadow(
                  color: Style.getShadowColor(),
                  blurRadius: 8,
                  spreadRadius: 3,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.shifting,
                backgroundColor: Style.getCardColor(),
                selectedItemColor: Style.getPrimaryColor(),
                unselectedItemColor: AppSettings.isDarkModeOn
                    ? Style.white
                    : Style.kingBlue,
                showUnselectedLabels: false,
                showSelectedLabels: true,
                currentIndex: screenIndex,
                onTap: (index) => _buttonPress(index),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    activeIcon: Icon(Icons.chat_bubble_rounded),
                    label: 'Mensajes',
                    backgroundColor: Style.getCardColor(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Inicio',
                    backgroundColor: Style.getCardColor(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings_rounded),
                    label: 'Configuración',
                    backgroundColor: Style.getCardColor(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _buttonPress(int index) {
    setState(() {
      screenIndex = index;
    });
    dashController.jumpToPage(index);
  }

  String greating() {
    var nowTime = TimeOfDay.now();
    var doubleNowTime =
        nowTime.hour.toDouble() + (nowTime.minute.toDouble() / 60);
    return doubleNowTime >= 7 && doubleNowTime <= 12
        ? MultiLanguages.of(context)!.translate('good_morning')
        : doubleNowTime >= 12 && doubleNowTime <= 19
        ? MultiLanguages.of(context)!.translate('good_afternoon')
        : MultiLanguages.of(context)!.translate('good_night');
  }
}
