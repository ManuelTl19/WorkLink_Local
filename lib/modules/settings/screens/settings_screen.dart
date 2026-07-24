import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/reports/screens/reports_screen.dart';
import 'package:worklink_local/modules/settings/screens/terms_conditions_screen.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/modules/users/services/user_service.dart';
import 'package:worklink_local/main.dart';

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
                            title:
                                MultiLanguages.of(
                                  context,
                                )?.translate('report_problem') ??
                                'Mis reportes',
                            subtitle:
                                MultiLanguages.of(
                                  context,
                                )?.translate('report_problem_description') ??
                                'Consulta los reportes que has enviado.',
                            icon: Icon(
                              Icons.report_problem_rounded,
                              color: Style.getSecondaryColor(),
                              size: 18.w,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReportsScreen(),
                                ),
                              );
                            },
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
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TermsConditionsScreen(),
                                ),
                              );
                            },
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
                            onTap: _deleteAccount,
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

  Future<void> _deleteAccount() async {
    final controller = TextEditingController();
    var obscureText = true;
    String? fieldError;
    var isDeleting = false;
    var successState = false;
    String? successMessage;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Style.getCardColor(),
              title: Text(
                successState ? 'Cuenta eliminada' : 'Confirmar contraseña',
                style: Style.getHeaderThree(
                  color: successState
                      ? Style.getPrimaryColor()
                      : Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: successState
                  ? Text(
                      successMessage ?? 'Tu cuenta se eliminó correctamente.',
                      style: Style.getTextStyle(color: Style.getTextColor()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Para eliminar tu cuenta, ingresa tu contraseña actual.',
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextField(
                          controller: controller,
                          obscureText: obscureText,
                          enabled: !isDeleting,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            errorText: fieldError,
                            filled: true,
                            fillColor: Style.getBackgroundColor(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            suffixIcon: IconButton(
                              onPressed: isDeleting
                                  ? null
                                  : () {
                                      setDialogState(() {
                                        obscureText = !obscureText;
                                      });
                                    },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              actions: successState
                  ? [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Style.getPrimaryColor(),
                          foregroundColor: Style.white,
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Continuar'),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.pop(dialogContext),
                        child: Text(
                          MultiLanguages.of(context)!.translate('cancel'),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Style.getErrorColor(),
                          foregroundColor: Style.white,
                        ),
                        onPressed: isDeleting
                            ? null
                            : () async {
                                final value = controller.text.trim();
                                if (value.isEmpty) {
                                  setDialogState(() {
                                    fieldError = 'Ingresa tu contraseña';
                                  });
                                  return;
                                }

                                setDialogState(() {
                                  fieldError = null;
                                  isDeleting = true;
                                });

                                try {
                                  final prefsLocal =
                                      await SharedPreferences.getInstance();
                                  final userRaw = prefsLocal.getString(
                                    Constants.userEmailKey,
                                  );

                                  if (userRaw == null || userRaw.isEmpty) {
                                    throw Exception(
                                      'No hay sesión activa para eliminar.',
                                    );
                                  }

                                  final user = UserModel.fromJson(
                                    (jsonDecode(userRaw)
                                        as Map<String, dynamic>),
                                  );

                                  await UserService.deleteUser(
                                    userId: user.id,
                                    password: value,
                                  );

                                  if (!mounted) return;

                                  setDialogState(() {
                                    successState = true;
                                    successMessage =
                                        'Tu cuenta se eliminó correctamente.';
                                    isDeleting = false;
                                  });

                                  await AuthService.logout();
                                } catch (error) {
                                  if (!mounted) return;
                                  setDialogState(() {
                                    fieldError = error.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    );
                                    isDeleting = false;
                                  });
                                }
                              },
                        child: isDeleting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Style.white,
                                ),
                              )
                            : Text(
                                MultiLanguages.of(context)!.translate('delete'),
                              ),
                      ),
                    ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (!mounted) return;

    if (successState) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
