import 'dart:async';

import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/forgot_password_content.dart';
import 'package:worklink_local/modules/app/components/biometric_login_button.dart';
import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/app/screens/starter/register_screen.dart';
import 'package:worklink_local/modules/users/services/user_service.dart';
import 'package:worklink_local/utils/extensions/extensions.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  final bool showByeMesssage;

  const LoginScreen({super.key, this.showByeMesssage = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  // ignore: unused_field
  bool _showPassword = false;
  bool _loading = false;
  bool _biometricEnabled = false;
  bool _biometricSupported = false;
  bool _biometricAvailable = false;
  bool _hasValidStoredToken = false;
  bool _biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = BiometricService();
    final hasValidToken = await SecureStorageService.hasValidToken();
    final supported = await biometricService.isSupported();
    final available = await biometricService.hasEnrolledBiometrics();
    final enabled = await AppSettings.getBiometricEnabled();

    if (!mounted) return;
    setState(() {
      _hasValidStoredToken = hasValidToken;
      _biometricSupported = supported;
      _biometricAvailable = available;
      _biometricEnabled = enabled;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showByeMesssage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs.showSimpleDialog(
          context,
          icon: Icons.waving_hand_rounded,
          title: MultiLanguages.of(context)!.translate('login_bye_title'),
          message: MultiLanguages.of(context)!.translate('login_bye_message'),
          color: Style.getPrimaryColor(),
          duration: 1500,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Style.getBackgroundColor(),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Style.getPrimaryColor().withValues(alpha: .12),
                      Style.getBackgroundColor(),
                      Style.getBackgroundColor(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -36.h,
              right: -28.w,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Style.getPrimaryColor().withValues(alpha: .12),
                ),
              ),
            ),
            Positioned(
              bottom: -44.h,
              left: -24.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Style.getPrimaryColor().withValues(alpha: .08),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _topRow(app),
                    SizedBox(height: 20.h),
                    _header(),
                    SizedBox(height: 30.h),
                    _loginFields(context),
                    SizedBox(height: 8.h),
                    _forgotPassword(context),
                    SizedBox(height: 16.h),
                    _loginButton(),
                    if (_showBiometricButton) ...[
                      SizedBox(height: 18.h),
                      BiometricLoginButton(
                        onPressed: _authenticateWithBiometrics,
                        enabled: !_biometricLoading,
                      ),
                    ],
                    SizedBox(height: 20.h),
                    _separator(),
                    SizedBox(height: 18.h),
                    _createAccountButton(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRow(AppSettings app) {
    return Row(
      children: [
        _iconButton(
          icon: Icons.bolt_rounded,
          onTap: () {
            emailController.text = 'admin@worklink.com';
            passwordController.text = 'admin123';
          },
        ),
        const Spacer(),
        _iconButton(
          icon: AppSettings.isDarkModeOn
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          onTap: () {
            app.changeTheme();
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Style.getCardColor().withValues(alpha: .14),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      child: InkWell(
        borderRadius: Style.getBorderRadius(),
        onTap: onTap,
        child: Container(
          width: 42.w,
          height: 42.w,
          alignment: Alignment.center,
          child: Icon(icon, color: Style.getPrimaryColor(), size: 16.w),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 68.w,
          height: 68.w,
          child: Image.asset(
            AppSettings.isDarkModeOn
                ? Assets.companyHorDarkLogo
                : Assets.companyHorLightLogo,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Worklink Local',
          style: Style.getHeaderTwo(
            color: Style.getPrimaryColor(),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }

  Widget _loginFields(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            controller: emailController,
            label: MultiLanguages.of(context)!.translate('login_email'),
            hintText: MultiLanguages.of(context)!.translate('login_email_hint'),
            focusNode: emailNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return MultiLanguages.of(context)!.translate('enter_email');
              }
              if (!text.isEmail) {
                return MultiLanguages.of(
                  context,
                )!.translate('enter_valid_email');
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordNode),
          ),
          SizedBox(height: 16.h),
          CustomPasswordField(
            label: MultiLanguages.of(context)!.translate('login_password'),
            controller: passwordController,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return MultiLanguages.of(context)!.translate('enter_password');
              }
              return null;
            },
            onSubmitted: (_) => login(),
          ),
        ],
      ),
    );
  }

  bool get _showBiometricButton =>
      _hasValidStoredToken &&
      _biometricEnabled &&
      _biometricSupported &&
      _biometricAvailable;

  Widget _forgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const ForgotPasswordDialog(),
        ),
        child: Text(
          MultiLanguages.of(context)!.translate('login_forgot'),
          style: Style.getHeaderThree(
            color: Style.getPrimaryColor(),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomWidgets.button(
        onTap: login,
        color: Style.getPrimaryColor(),
        height: 50,
        child: _loading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Style.white,
                ),
              )
            : Text(
                MultiLanguages.of(context)!.translate('login_sign_in'),
                style: Style.getHeaderTwo(
                  color: Style.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _separator() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Style.getObscureTextColor().withValues(alpha: .20),
            height: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            MultiLanguages.of(context)!.translate('or'),
            style: Style.getTextStyle(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Style.getObscureTextColor().withValues(alpha: .20),
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _createAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _openRegister,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Style.getPrimaryColor().withValues(alpha: .45),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: Style.getButtonBorderRadius(),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          MultiLanguages.of(context)!.translate('login_create_account'),
          style: Style.getHeaderThree(
            color: Style.getPrimaryColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _loading = true);

      final result = await UserService.login(
        context,
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      Dialogs.showSimpleDialog(
        context,
        title: result.message,
        message: '${result.user.nombre} ${result.user.apellidoP}'.trim(),
        color: Style.getPrimaryColor(),
        svg: Assets.svgCheckIcon,
        duration: 1600,
      );

      await Future.delayed(const Duration(milliseconds: 1700));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      final errorMessage = error is TimeoutException
          ? MultiLanguages.of(context)!.translate('timeout_error')
          : error.toString().replaceFirst('Exception: ', '').trim();

      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error'),
        message: errorMessage,
        color: Style.getErrorColor(),
        svg: Assets.svgErrorIcon,
        duration: 2200,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // ignore: unused_element
  Future<void> _askToEnableBiometrics() async {
    if (!mounted) return;

    final biometricService = BiometricService();
    final supported = await biometricService.isSupported();
    if (!supported) return;

    final enableBiometric = await Dialogs.showConfirmDialog(
      context,
      title: MultiLanguages.of(context)!.translate('biometric_enable_title'),
      message: MultiLanguages.of(
        context,
      )!.translate('biometric_enable_message'),
      svg: Assets.svgInfoIcon,
      confirmText: MultiLanguages.of(context)!.translate('activate'),
      cancelText: MultiLanguages.of(context)!.translate('not_now'),
    );

    if (enableBiometric) {
      AppSettings.isBiometricEnabled = true;
      if (mounted) {
        setState(() {
          _biometricEnabled = true;
          _biometricSupported = true;
          _hasValidStoredToken = true;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_biometricLoading) return;

    final biometricService = BiometricService();
    setState(() {
      _biometricLoading = true;
    });

    try {
      final supported = await biometricService.isSupported();
      if (!supported) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: MultiLanguages.of(
            context,
          )!.translate('biometric_not_available_title'),
          message: MultiLanguages.of(
            context,
          )!.translate('biometric_not_available_message'),
          color: Style.getErrorColor(),
          icon: Icons.fingerprint_rounded,
        );
        return;
      }

      final available = await biometricService.hasEnrolledBiometrics();
      if (!available) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: MultiLanguages.of(
            context,
          )!.translate('biometric_not_enrolled_title'),
          message: MultiLanguages.of(
            context,
          )!.translate('biometric_not_enrolled_message'),
          color: Style.getErrorColor(),
          icon: Icons.fingerprint_rounded,
        );
        return;
      }

      final authenticated = await biometricService.authenticate(
        reason: MultiLanguages.of(context)!.translate('biometric_login_reason'),
      );

      if (!authenticated) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: MultiLanguages.of(
            context,
          )!.translate('biometric_failed_title'),
          message: MultiLanguages.of(
            context,
          )!.translate('biometric_failed_message'),
          color: Style.getErrorColor(),
          icon: Icons.fingerprint_rounded,
        );
        return;
      }

      if (!mounted) return;

      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('biometric_success_title'),
        message: MultiLanguages.of(
          context,
        )!.translate('biometric_success_message'),
        color: Style.getPrimaryColor(),
        svg: Assets.svgCheckIcon,
        duration: 1300,
      );

      await Future.delayed(const Duration(milliseconds: 1300));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _biometricLoading = false;
        });
      }
    }
  }
}
