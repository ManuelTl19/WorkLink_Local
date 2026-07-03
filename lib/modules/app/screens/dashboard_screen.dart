import 'dart:ui';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
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
          bottomNavigationBar: _floatingNavigationBar(),
        ),
      ),
    );
  }

  void _buttonPress(int index) {
    setState(() {
      screenIndex = index;
    });
    dashController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _floatingNavigationBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.r),
          child: AnimatedBottomNavigationBar.builder(
            itemCount: 3,
            activeIndex: screenIndex,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            height: 78.h,
            gapLocation: GapLocation.none,
            blurEffect: true,
            imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            backgroundColor: Style.getBackgroundColor().withValues(alpha: .01),
            borderColor: Style.getPrimaryColor().withValues(alpha: .08),
            borderWidth: 1.0,
            elevation: 18,
            splashColor: Style.getPrimaryColor().withValues(alpha: .18),
            shadow: Shadow(
              color: Style.getShadowColor().withValues(alpha: .18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            tabBuilder: (index, isActive) => _navTab(index, isActive),
            onTap: _buttonPress,
          ),
        ),
      ),
    );
  }

  Widget _navTab(int index, bool isActive) {
    final label = index == 0
        ? 'Chat'
        : index == 1
        ? 'Inicio'
        : 'Configuración';
    final icon = index == 0
        ? Icons.chat_bubble_outline_rounded
        : index == 1
        ? Icons.home_outlined
        : Icons.settings_outlined;
    final activeIcon = index == 0
        ? Icons.chat_bubble_rounded
        : index == 1
        ? Icons.home_rounded
        : Icons.settings_rounded;

    if (!isActive) {
      return SizedBox(
        key: ValueKey('inactive-$index'),
        height: 86.h,
        child: Center(
          child: Icon(
            icon,
            size: 24.w,
            color: Style.getTextColor(),
          ),
        ),
      );
    }

    return SizedBox(
      key: ValueKey('active-$index'),
      height: 78.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Style.getPrimaryColor().withValues(alpha: .18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Style.getPrimaryColor().withValues(alpha: .24),
                ),
              ),
              child: Icon(
                activeIcon,
                size: 18.w,
                color: Style.getPrimaryColor(),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Style.getTextStyle(
                color: Style.getPrimaryColor(),
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
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
