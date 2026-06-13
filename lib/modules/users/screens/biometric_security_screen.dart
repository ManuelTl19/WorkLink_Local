import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class BiometricSecurityScreen extends StatefulWidget {
  const BiometricSecurityScreen({super.key});

  @override
  State<BiometricSecurityScreen> createState() =>
      _BiometricSecurityScreenState();
}

class _BiometricSecurityScreenState extends State<BiometricSecurityScreen> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: CustomScrollView(
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
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
                ),
              ),
              title: Text(
                MultiLanguages.of(
                  context,
                )!.translate('biometric_authentication'),
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    _sectionCard(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 14.w,
                            right: 14.w,
                            top: 12.h,
                          ),
                          child: Tiles.switchTile(
                            dense: true,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('biometric_authentication'),
                            subtitle: MultiLanguages.of(context)!.translate(
                              'biometric_authentication_description',
                            ),
                            icon: Icons.fingerprint_rounded,
                            value: _enabled,
                            onChanged: (value) {
                              setState(() {
                                _enabled = value;
                              });

                              Dialogs.showSimpleDialog(
                                context,
                                title: MultiLanguages.of(
                                  context,
                                )!.translate('biometric_authentication'),
                                message: MultiLanguages.of(
                                  context,
                                )!.translate('feature_coming_soon'),
                                color: Style.getPrimaryColor(),
                                icon: Icons.fingerprint_rounded,
                              );
                            },
                          ),
                        ),
                        _divider(),
                        Tiles.settingTile(
                          dense: true,
                          title: MultiLanguages.of(
                            context,
                          )!.translate('supported_methods'),
                          subtitle: MultiLanguages.of(
                            context,
                          )!.translate('supported_methods_description'),
                          icon: Icon(
                            Icons.security_rounded,
                            color: Style.getSecondaryColor(),
                            size: 18.w,
                          ),
                          onTap: () {
                            Dialogs.showSimpleDialog(
                              context,
                              title: MultiLanguages.of(
                                context,
                              )!.translate('supported_methods'),
                              message: MultiLanguages.of(
                                context,
                              )!.translate('feature_coming_soon'),
                              color: Style.getPrimaryColor(),
                              icon: Icons.security_rounded,
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
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
}
