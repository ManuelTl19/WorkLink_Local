import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../app/screens/dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  // _packageInfo() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   setState(() {
  //     appName = packageInfo.appName;
  //     packageName = packageInfo.packageName;
  //     version = packageInfo.version;
  //     buildNumber = packageInfo.buildNumber;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // _packageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: Style.getBackgroundColor(),
          width: double.infinity,
          height: double.infinity,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Style.getBackgroundColor(),
                surfaceTintColor: Style.transparent,
                toolbarHeight: 10.h,
                pinned: true,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: CustomSliverAppBar(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: Style.horizontalPadding),

                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap: () => showDrawer(),
                          child: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Style.getPrimaryColor(),
                          ),
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Jose manuel",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Style.getHeaderTwo(
                                color: Style.getSecondaryColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "jose.manuel@example.com",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Style.getTextStyle(
                                color: Style.getObscureTextColor(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: CustomWidgets.button(
                          onTap: () {},
                          color: Style.getPrimaryColor(),
                          backgroundColor: Style.getBackgroundColor(),
                          isFilled: false,
                          //border: true,
                          child: Text(
                            MultiLanguages.of(
                              context,
                            )!.translate('edit_profile'),
                            style: Style.getHeaderThree(
                              color: Style.getPrimaryColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: Style.horizontalPadding),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: Style.getPadding(),
                  child: Column(
                    children: [
                      _title(
                        title: MultiLanguages.of(context)!.translate('general'),
                      ),

                      _card(
                        child: Tiles.settingTile(
                          title: MultiLanguages.of(context)!.translate('theme'),
                          icon: ThemeIcon(
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () => app.changeTheme(),
                        ),
                      ),

                      SizedBox(height: 5.h),

                      _card(
                        child: Tiles.settingTile(
                          title: MultiLanguages.of(
                            context,
                          )!.translate('notifications'),
                          icon: Icon(
                            Icons.notifications_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () {},
                        ),
                      ),

                      SizedBox(height: 5.h),

                      _title(
                        title: MultiLanguages.of(context)!.translate('admin'),
                      ),

                      _card(
                        child: Tiles.settingTile(
                          title: "Autenticación biométrica",
                          icon: Icon(
                            Icons.fingerprint_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () => {},
                        ),
                      ),

                      SizedBox(height: 5.h),

                      _card(
                        child: Tiles.settingTile(
                          title: "Eliminar cuenta",
                          icon: Icon(
                            Icons.delete_forever_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () => {},
                        ),
                      ),

                      SizedBox(height: 5.h),

                      _card(
                        child: Tiles.settingTile(
                          title: "Política de privacidad",
                          icon: Icon(
                            Icons.privacy_tip_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () {},
                        ),
                      ),

                      SizedBox(height: 5.h),

                      _card(
                        child: Tiles.settingTile(
                          title: "Términos y condiciones",
                          icon: Icon(
                            Icons.gavel_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () {},
                        ),
                      ),
                      _card(
                        child: Tiles.settingTile(
                          title: "Idioma",
                          icon: Icon(
                            Icons.language_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () {},
                        ),
                      ),
                      _card(
                        child: Tiles.settingTile(
                          title: "Reportar problema",
                          icon: Icon(
                            Icons.bug_report_rounded,
                            color: Style.getSecondaryColor(),
                            size: 20.w,
                          ),
                          onTap: () {},
                        ),
                      ),

                      // log out start
                      SizedBox(height: 10.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomWidgets.button(
                            onTap: () => Dialogs.showLogOutDialog(context),
                            color: Style.getErrorColor(),
                            backgroundColor: Style.getBackgroundColor()
                                .lighten(),
                            isFilled: false,
                            child: Text(
                              MultiLanguages.of(context)!.translate('log_out'),
                              style: Style.getHeaderThree(
                                color: Style.getErrorColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 110.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title({required String title}) {
    return Padding(
      padding: Style.getPadding(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: Style.getHeaderTwo(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      child: child,
    );
  }
}

class CustomSliverAppBar extends SliverPersistentHeaderDelegate {
  final Widget child;

  CustomSliverAppBar({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: Style.getBackgroundColor(),
      child: child,
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
