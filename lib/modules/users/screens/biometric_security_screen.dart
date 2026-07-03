import 'package:local_auth/local_auth.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class BiometricSecurityScreen extends StatefulWidget {
  const BiometricSecurityScreen({super.key});

  @override
  State<BiometricSecurityScreen> createState() =>
      _BiometricSecurityScreenState();
}

class _BiometricSecurityScreenState extends State<BiometricSecurityScreen> {
  final BiometricService _biometricService = BiometricService();

  bool _enabled = false;
  bool _supported = false;
  List<BiometricType> _availableBiometrics = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final supported = await _biometricService.isSupported();
    final biometrics = supported
        ? await _biometricService.getAvailableBiometrics()
        : <BiometricType>[];
    final enabled = await AppSettings.getBiometricEnabled();

    if (!mounted) return;
    setState(() {
      _supported = supported;
      _availableBiometrics = biometrics;
      _enabled = enabled;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (!_supported) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(
          context,
        )!.translate('biometric_authentication'),
        message: 'Este dispositivo no soporta biometría',
        color: Style.getErrorColor(),
        icon: Icons.fingerprint_rounded,
      );
      return;
    }

    if (value) {
      final authenticated = await _biometricService.authenticate(
        reason: 'Confirma tu identidad para activar el acceso biométrico',
      );

      if (!authenticated || !mounted) return;
    }

    if (!mounted) return;
    setState(() {
      _enabled = value;
    });

    AppSettings.isBiometricEnabled = value;

    Dialogs.showSimpleDialog(
      context,
      title: MultiLanguages.of(context)!.translate('biometric_authentication'),
      message: value
          ? 'La autenticación biométrica quedó activada'
          : 'La autenticación biométrica quedó desactivada',
      color: Style.getPrimaryColor(),
      icon: Icons.fingerprint_rounded,
    );
  }

  String _biometricLabels() {
    if (_availableBiometrics.isEmpty) {
      return 'Huella, Face ID o método compatible del sistema';
    }

    return _availableBiometrics
        .map((item) => item.toString().split('.').last)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: _isLoading
            ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
            : CustomScrollView(
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
                                  subtitle: MultiLanguages.of(context)!
                                      .translate(
                                        'biometric_authentication_description',
                                      ),
                                  icon: Icons.fingerprint_rounded,
                                  value: _enabled,
                                  onChanged: _toggleBiometrics,
                                ),
                              ),
                              _divider(),
                              Tiles.settingTile(
                                dense: true,
                                title: MultiLanguages.of(
                                  context,
                                )!.translate('supported_methods'),
                                subtitle: _supported
                                    ? (_availableBiometrics.isEmpty
                                          ? 'Método biométrico disponible'
                                          : _biometricLabels())
                                    : 'Este dispositivo no soporta biometría',
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
                                    message: _supported
                                        ? (_availableBiometrics.isEmpty
                                              ? 'El sistema no reportó biometrías disponibles.'
                                              : _biometricLabels())
                                        : 'Este dispositivo no soporta biometría',
                                    color: Style.getPrimaryColor(),
                                    icon: Icons.security_rounded,
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 18.h),
                          _sectionCard(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(14.w),
                                child: Text(
                                  _supported
                                      ? 'Puedes usar esta opción para volver a ingresar a una sesión ya autenticada.'
                                      : 'La autenticación biométrica no está disponible en este dispositivo.',
                                  style: Style.getTextStyle(
                                    color: Style.getObscureTextColor(),
                                  ),
                                ),
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
