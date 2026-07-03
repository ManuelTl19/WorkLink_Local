import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';

import '../../app/screens/dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _biometricSupported = true;

  @override
  void initState() {
    super.initState();
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _loadBiometricSupport();
  }

  Future<void> _loadBiometricSupport() async {
    final biometricService = BiometricService();
    final supported = await biometricService.isSupported();
    if (!mounted) return;
    setState(() {
      _biometricSupported = supported;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                pinned: true,
                elevation: 0,
                titleSpacing: 0,
                toolbarHeight: 58.h,
                leading: IconButton(
                  onPressed: showDrawer,
                  icon: Icon(Icons.menu_rounded, color: Style.getTextColor()),
                ),
                title: Text(
                  MultiLanguages.of(context)!.translate('settings'),
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Style.horizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        MultiLanguages.of(context)!.translate('general'),
                      ),
                      _sectionCard(
                        children: [
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('theme'),
                            subtitle: AppSettings.isDarkModeOn
                                ? MultiLanguages.of(
                                    context,
                                  )!.translate('on_dark_mode')
                                : MultiLanguages.of(
                                    context,
                                  )!.translate('on_light_mode'),
                            icon: ThemeIcon(
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () => app.changeTheme(),
                          ),
                          _divider(),
                          Tiles.switchTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('notifications'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('notifications_settings'),
                            icon: Icons.notifications_rounded,
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                          ),
                          _divider(),
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('language'),
                            subtitle: _languageName(context),
                            icon: Icon(
                              Icons.language_rounded,
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () => app.changeLanguage(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _sectionTitle(
                        MultiLanguages.of(context)!.translate('security'),
                      ),
                      _sectionCard(
                        children: [
                          if (_biometricSupported)
                            Tiles.switchTile(
                              dense: true,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('biometric_authentication'),
                              subtitle: MultiLanguages.of(context)!.translate(
                                'biometric_authentication_description',
                              ),
                              icon: Icons.fingerprint_rounded,
                              value: _biometricEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _biometricEnabled = value;
                                });

                                AppSettings.isBiometricEnabled = value;
                              },
                            )
                          else
                            Tiles.settingTile(
                              dense: true,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('biometric_authentication'),
                              subtitle: 'Este dispositivo no soporta biometría',
                              icon: Icon(
                                Icons.fingerprint_rounded,
                                color: Style.getSecondaryColor(),
                                size: 18.w,
                              ),
                              onTap: () {},
                            ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _sectionTitle(
                        MultiLanguages.of(context)!.translate('support'),
                      ),
                      _sectionCard(
                        children: [
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('report_problem'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('report_problem_description'),
                            icon: Icon(
                              Icons.bug_report_rounded,
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () => _showSimpleInfo(
                              context: context,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('report_problem'),
                              message: MultiLanguages.of(
                                context,
                              )!.translate('report_problem_description'),
                              color: Style.getSecondaryColor(),
                              icon: Icons.bug_report_rounded,
                            ),
                          ),
                          _divider(),
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('privacy_policy'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('privacy_policy_description'),
                            icon: Icon(
                              Icons.privacy_tip_rounded,
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () => _showSimpleInfo(
                              context: context,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('privacy_policy'),
                              message: MultiLanguages.of(
                                context,
                              )!.translate('privacy_policy_description'),
                              color: Style.getSecondaryColor(),
                              icon: Icons.privacy_tip_rounded,
                            ),
                          ),
                          _divider(),
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('terms_conditions'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('terms_conditions_description'),
                            icon: Icon(
                              Icons.gavel_rounded,
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () => _showSimpleInfo(
                              context: context,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('terms_conditions'),
                              message: MultiLanguages.of(
                                context,
                              )!.translate('terms_conditions_description'),
                              color: Style.getSecondaryColor(),
                              icon: Icons.gavel_rounded,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _sectionTitle(
                        MultiLanguages.of(context)!.translate('account'),
                      ),
                      _sectionCard(
                        children: [
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('log_out'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('log_out_description'),
                            titleColor: Style.getErrorColor(),
                            subtitleColor: Style.getErrorColor().withValues(
                              alpha: .8,
                            ),
                            iconColor: Style.getErrorColor(),
                            trailingColor: Style.getErrorColor(),
                            iconBackgroundColor: Style.getErrorColor()
                                .withValues(alpha: .12),
                            icon: Icon(
                              Icons.logout_rounded,
                              color: Style.getErrorColor(),
                              size: 18.w,
                            ),
                            onTap: () => Dialogs.showLogOutDialog(context),
                          ),
                          _divider(),
                          Tiles.settingTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('delete_account'),
                            subtitle: MultiLanguages.of(
                              context,
                            )!.translate('delete_account_description'),
                            titleColor: Style.getErrorColor(),
                            subtitleColor: Style.getErrorColor().withValues(
                              alpha: .8,
                            ),
                            iconColor: Style.getErrorColor(),
                            trailingColor: Style.getErrorColor(),
                            iconBackgroundColor: Style.getErrorColor()
                                .withValues(alpha: .12),
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: Style.getErrorColor(),
                              size: 18.w,
                            ),
                            onTap: () => _showSimpleInfo(
                              context: context,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('delete_account'),
                              message: MultiLanguages.of(
                                context,
                              )!.translate('delete_account_description'),
                              color: Style.getErrorColor(),
                              icon: Icons.delete_forever_rounded,
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: Style.getHeaderThree(
          color: Style.getObscureTextColor(),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Style.getObscureTextColor().withValues(alpha: .12),
      ),
    );
  }

  String _languageName(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es'
        ? 'Español'
        : 'English';
  }

  void _showSimpleInfo({
    required BuildContext context,
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Dialogs.showSimpleDialog(
      context,
      title: title,
      message: message,
      icon: icon,
      color: color,
    );
  }
}
