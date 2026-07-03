import 'dart:typed_data';

import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/extensions/extensions.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final firstLastNameController = TextEditingController();
  final secondLastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<String?> _selectedRole = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _acceptTerms = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _acceptPrivacy = ValueNotifier<bool>(false);

  Uint8List? _photoBytes;

  @override
  void dispose() {
    nameController.dispose();
    firstLastNameController.dispose();
    secondLastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _selectedRole.dispose();
    _acceptTerms.dispose();
    _acceptPrivacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                SizedBox(height: 20.h),
                _hero(),
                SizedBox(height: 26.h),
                CustomInputField(
                  controller: nameController,
                  label: 'Nombre',
                  requiredField: true,
                ),
                SizedBox(height: 12.h),
                CustomInputField(
                  controller: firstLastNameController,
                  label: 'Apellido paterno',
                  requiredField: true,
                ),
                SizedBox(height: 12.h),
                CustomInputField(
                  controller: secondLastNameController,
                  label: 'Apellido materno',
                  requiredField: true,
                ),
                SizedBox(height: 12.h),
                CustomInputField(
                  controller: emailController,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Ingresa tu correo';
                    if (!text.isEmail) return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                CustomPasswordField(
                  controller: passwordController,
                  label: 'Contraseña',
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Ingresa una contraseña';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                CustomPasswordField(
                  controller: confirmPasswordController,
                  label: 'Confirmar contraseña',
                  validator: (value) {
                    if ((value?.trim() ?? '').isEmpty) {
                      return 'Confirma la contraseña';
                    }
                    if (value != passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 26.h),
                _sectionTitle('Tipo de cuenta'),
                SizedBox(height: 14.h),
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedRole,
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        _roleCard(
                          title: 'Cliente',
                          subtitle:
                              'Gestiona solicitudes, pagos y proveedores.',
                          info:
                              'Puede revisar actividad, pagos y solicitudes dentro de la plataforma.',
                          selected: value == 'cliente',
                          onTap: () => _selectedRole.value = 'cliente',
                        ),
                        SizedBox(height: 10.h),
                        _roleCard(
                          title: 'Empresa',
                          subtitle:
                              'Administra leads, equipo y operación comercial.',
                          info:
                              'Puede administrar procesos, relaciones comerciales y gestión interna.',
                          selected: value == 'empresa',
                          onTap: () => _selectedRole.value = 'empresa',
                        ),
                        SizedBox(height: 10.h),
                        _roleCard(
                          title: 'Freelancer',
                          subtitle:
                              'Controla servicios, oportunidades y entregables.',
                          info:
                              'Puede publicar servicios, revisar oportunidades y dar seguimiento a proyectos.',
                          selected: value == 'freelancer',
                          onTap: () => _selectedRole.value = 'freelancer',
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 26.h),
                _sectionTitle('Políticas y términos'),
                _policySwitch(
                  title: 'Términos y condiciones',
                  valueListenable: _acceptTerms,
                ),
                _policySwitch(
                  title: 'Política de privacidad',
                  valueListenable: _acceptPrivacy,
                ),
                SizedBox(height: 26.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomWidgets.button(
                    onTap: _createAccount,
                    color: Style.getPrimaryColor(),
                    height: 50,
                    child: Text(
                      'Crear cuenta',
                      style: Style.getHeaderTwo(
                        color: Style.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Style.getCardColor().withValues(alpha: .12),
          shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
          child: InkWell(
            borderRadius: Style.getBorderRadius(),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.w,
                color: Style.getTextColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Crear cuenta',
          style: Style.getHeaderOne(
            color: Style.getPrimaryColor(),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'Regístrate para acceder a la plataforma',
            style: Style.getHeaderTwo(
              color: Style.getTextColor(),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Center(
          child: CustomAvatarPicker(
            initialBytes: _photoBytes,
            onBytesChanged: (bytes) {
              setState(() => _photoBytes = bytes);
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Style.getPrimaryColor(),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: Style.getHeaderThree(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required String info,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Style.getCardColor().withValues(alpha: .12),
      borderRadius: Style.getBorderRadius(),
      child: InkWell(
        borderRadius: Style.getBorderRadius(),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: Style.getBorderRadius(),
            gradient: selected
                ? LinearGradient(
                    colors: [
                      Style.getPrimaryColor().withValues(alpha: .14),
                      Style.getCardColor().withValues(alpha: .14),
                    ],
                  )
                : null,
            border: Border.all(
              color: selected
                  ? Style.getPrimaryColor().withValues(alpha: .40)
                  : Style.getObscureTextColor().withValues(alpha: .08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? Style.getPrimaryColor()
                    : Style.getObscureTextColor(),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Style.getPrimaryColor().withValues(alpha: .12),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () => _showRoleInfo(title, info),
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: Style.getPrimaryColor(),
                    size: 18.w,
                  ),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _policySwitch({
    required String title,
    required ValueNotifier<bool> valueListenable,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Style.getTextStyle(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: (newValue) => valueListenable.value = newValue,
                activeColor: Style.getPrimaryColor(),

              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoleInfo(String title, String info) {
    Dialogs.showSimpleDialog(
      context,
      title: title,
      message: info,
      color: Style.getPrimaryColor(),
      icon: Icons.info_outline_rounded,
    );
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole.value == null) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Selecciona un tipo de cuenta',
        message: 'Elige Cliente, Empresa o Freelancer para continuar.',
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    if (!(_acceptTerms.value && _acceptPrivacy.value)) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Acepta los términos',
        message: 'Debes aceptar los términos y la política de privacidad.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    Dialogs.showSimpleDialog(
      context,
      title: 'Registro listo',
      message: 'Tu cuenta quedó preparada para continuar.',
      color: Style.getPrimaryColor(),
      svg: Assets.svgCheckIcon,
      duration: 1500,
    );

    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) Navigator.pop(context);
  }
}
