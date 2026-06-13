import 'dart:async';
import 'dart:io';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/users/services/user_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:worklink_local/modules/app/components/forgot_password_content.dart';

class LoginScreen extends StatefulWidget {
  final bool showByeMesssage; // Used to show the buyer login screen
  const LoginScreen({super.key, this.showByeMesssage = true});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passVisible = false;
  bool showSpinner = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();

  TextEditingController passwordController = TextEditingController();
  FocusNode passNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Secure that the user is loged out when the LoginScreen is opened
    // CollaboratorService.logOut(context);
  }

  @override
  void dispose() {
    super.dispose();
    passNode.dispose();
    emailNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    _formKey.currentState?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showByeMesssage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs.showSimpleDialog(
          context,
          icon: Icons.waving_hand,
          title: MultiLanguages.of(context)!.translate('login_bye_title'),
          message: MultiLanguages.of(context)!.translate('login_bye_message'),
          color: Style.getPrimaryColor(),
          duration: 2000,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Style.getBackgroundColor(),
        appBar: AppBar(
          toolbarHeight: 80.h,
          elevation: 0,
          backgroundColor: Style.transparent,
          automaticallyImplyLeading: false,
          title: SizedBox(
            width: 120.w,
            height: 55.h,
            child: Image.asset(
              AppSettings.isDarkModeOn
                  ? Assets.companyHorDarkLogo
                  : Assets.companyHorLightLogo,
              fit: BoxFit.fitWidth,
            ),
          ),
          actions: [
            FloatingActionButton(
              heroTag: 'puppy!!',
              mini: true,
              onPressed: () => setState(() {
                emailController.text = 'admin@worklink.com';
                passwordController.text = 'admin123';
              }),
              backgroundColor: Style.getBackgroundColor(),
              elevation: 0,
              child: FaIcon(
                FontAwesomeIcons.dog,
                color: Style.getPrimaryColor(),
                size: Style.smallIconSize,
              ),
            ),

            const SizedBox(width: 10),

            FloatingActionButton(
              mini: true,
              onPressed: () {
                app.changeTheme();
                setState(() {});
              },
              backgroundColor: Style.getCardColor(),
              elevation: 0,
              child: ThemeIcon(size: 18.w, color: Style.getTextColor()),
            ),

            const SizedBox(width: 10),

            /* Language Selector not in use yet
            FloatingActionButton(
              heroTag: 'something-3',
              mini: true,
              onPressed: () async {
                await MultiLanguages.of(context)!.selectLanguageBottomSheet(context);
                setState(() {});
              },
              backgroundColor: Style.getCardColor(),
              elevation: 0,
              child: Icon(
                FontAwesomeIcons.globe,
                color: Style.getTextColor(),
                size: 18.w,
              ),
            ),
            */
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // background
            // VideoItemWidget(
            //   pageIndex: 0,
            //   currentPageIndex: 0,
            //   isPaused: false,
            //   video: Assets.onboardingVideo4,
            // ),
            Image.asset(Assets.loginBg, fit: BoxFit.cover),

            CustomWidgets.blurEffect(child: SizedBox(), sigma: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: Alignment.center,
              color: Style.getBackgroundColor().withValues(alpha: 0.9),
            ),
            // background end

            // content
            Padding(
              padding: Style.getPaddingAll(15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),

                    Text(
                      "Worklink Local",
                      style: Style.getHeaderTwo(
                        color: Style.getPrimaryColor(),
                        fontSize: 24.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Bienvenido",
                      style: Style.getHeaderThree(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Correo electrónico",
                          style: Style.getHeaderThree(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: emailController,
                      focusNode: emailNode,
                      style: Style.getTextStyle(),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                        FocusScope.of(context).requestFocus(passNode);
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "ejemplo@gmail.com",
                        hintStyle: Style.getHintStyle(
                          color: Style.getObscureTextColor(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: const BorderSide(color: Style.grey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: const BorderSide(color: Style.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: BorderSide(color: Style.getAccentColor()),
                        ),
                        prefixIcon: Icon(
                          Icons.mail_rounded,
                          color: Style.getPrimaryColor(),
                          size: Style.smallIconSize,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Ingrese su correo electrónico";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Contraseña",
                          style: Style.getHeaderThree(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      focusNode: passNode,
                      controller: passwordController,
                      obscureText: !passVisible,
                      textInputAction: TextInputAction.done,
                      style: Style.getTextStyle(),
                      decoration: InputDecoration(
                        hintText: "**********",
                        hintStyle: Style.getHintStyle(
                          color: Style.getObscureTextColor(),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: const BorderSide(color: Style.grey),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: const BorderSide(color: Style.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Style.circularBorderRadius,
                          ),
                          borderSide: BorderSide(color: Style.getAccentColor()),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Style.getPrimaryColor(),
                          size: Style.smallIconSize,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            passVisible = !passVisible;
                          }),
                          icon: Icon(
                            !passVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Style.getPrimaryColor(),
                          ),
                        ),
                      ),
                      onFieldSubmitted: (value) async {
                        FocusScope.of(context).unfocus();

                        await login();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Por favor, ingrese su contraseña";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => const ForgotPasswordDialog(),
                          ),
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: Style.getHeaderThree(
                              color: Style.getPrimaryColor(),
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    InkWell(
                      onTap: () async => await login(),
                      borderRadius: Style.getBorderRadius(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: 40.h,
                        width: showSpinner
                            ? 40.h
                            : MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Style.getPrimaryColor(),
                          borderRadius: showSpinner
                              ? Style.getCircularBorderRadius(100)
                              : Style.getBorderRadius(),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: showSpinner
                                ? SizedBox(
                                    height: 20.w,
                                    width: 20.w,
                                    child: const CircularProgressIndicator(
                                      key: Key('circularProgressIndicator'),
                                      color: Style.white,
                                    ),
                                  )
                                : Text(
                                    "Iniciar sesión",
                                    key: const Key('loginButton'),
                                    style: Style.getHeaderTwo(
                                      color: Style.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

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

  login() async {
    if (showSpinner) return;

    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          showSpinner = true;
        });

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
          duration: 1800,
        );

        await Future.delayed(const Duration(milliseconds: 1900));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } catch (e) {
        if (!mounted) return;

        final errorMessage = e is TimeoutException
            ? 'Tiempo de espera agotado. Verifica tu conexión e inténtalo de nuevo'
            : _extractErrorMessage(e.toString());

        Dialogs.showSimpleDialog(
          context,
          title: 'Error',
          message: errorMessage,
          color: Style.getErrorColor(),
          svg: Assets.svgErrorIcon,
          duration: 2200,
        );
      } finally {
        if (mounted) {
          setState(() {
            showSpinner = false;
          });
        }
      }
    }
  }

  String _extractErrorMessage(String rawError) {
    return rawError.replaceFirst('Exception: ', '').trim();
  }
}
