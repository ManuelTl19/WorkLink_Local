import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/helpers/services/legal_documents_service.dart';
import 'package:worklink_local/modules/users/services/user_service.dart';
import 'package:worklink_local/utils/extensions/extensions.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _maxProfilePhotoBytes = 2 * 1024 * 1024;
  final List<GlobalKey<FormState>> _stepKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final nameController = TextEditingController();
  final firstLastNameController = TextEditingController();
  final secondLastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<String?> _selectedRole = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _acceptTerms = ValueNotifier<bool>(false);
  int _currentStep = 0;
  bool _openingTermsPdf = false;

  Uint8List? _photoBytes;
  XFile? _photoFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    firstLastNameController.dispose();
    secondLastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _selectedRole.dispose();
    _acceptTerms.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiStepFormScaffold(
      title: MultiLanguages.of(context)!.translate('login_create_account'),
      stepTitles: const <String>['Perfil', 'Acceso', 'Rol'],
      currentStep: _currentStep,
      onClose: () => Navigator.pop(context),
      onBack: _currentStep == 0 ? null : () => setState(() => _currentStep--),
      onNext: _onNextStep,
      isLastStep: _currentStep == 2,
      submitLabel: MultiLanguages.of(
        context,
      )!.translate('login_create_account'),
      child: _stepContent(),
    );
  }

  Future<void> _onNextStep() async {
    if (_currentStep == 0 || _currentStep == 1) {
      final valid = _stepKeys[_currentStep].currentState?.validate() ?? true;
      if (!valid) {
        _showStepValidationDialog();
        return;
      }
    }

    if (_currentStep == 2 && _selectedRole.value == null) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(
          context,
        )!.translate('register_select_role_title'),
        message: MultiLanguages.of(
          context,
        )!.translate('register_select_role_message'),
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    await _createAccount();
  }

  void _showStepValidationDialog() {
    Dialogs.showSimpleDialog(
      context,
      title: MultiLanguages.of(context)!.translate('error'),
      message:
          'No puedes avanzar porque faltan campos requeridos por completar.',
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  Widget _stepContent() {
    if (_currentStep == 0) {
      return Form(
        key: _stepKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(),
            SizedBox(height: 20.h),
            CustomInputField(
              controller: nameController,
              label: MultiLanguages.of(context)!.translate('name'),
              requiredField: true,
            ),
            SizedBox(height: 12.h),
            CustomInputField(
              controller: firstLastNameController,
              label: MultiLanguages.of(
                context,
              )!.translate('register_last_name_p'),
              requiredField: true,
            ),
            SizedBox(height: 12.h),
            CustomInputField(
              controller: secondLastNameController,
              label: MultiLanguages.of(
                context,
              )!.translate('register_last_name_m'),
              requiredField: true,
            ),
          ],
        ),
      );
    }

    if (_currentStep == 1) {
      return Form(
        key: _stepKeys[1],
        child: Column(
          children: [
            CustomInputField(
              controller: emailController,
              label: MultiLanguages.of(context)!.translate('login_email'),
              keyboardType: TextInputType.emailAddress,
              requiredField: true,
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
            ),
            SizedBox(height: 12.h),
            CustomInputField(
              controller: phoneController,
              label: MultiLanguages.of(context)!.translate('phone'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
              ],
              requiredField: true,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) {
                  return MultiLanguages.of(
                    context,
                  )!.translate('register_enter_phone');
                }
                final normalized = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                if (!RegExp(Patterns.phone).hasMatch(normalized)) {
                  return MultiLanguages.of(
                    context,
                  )!.translate('register_phone_invalid');
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            CustomPasswordField(
              controller: passwordController,
              label: MultiLanguages.of(context)!.translate('login_password'),
              requiredField: true,
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return MultiLanguages.of(
                    context,
                  )!.translate('register_enter_password');
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            CustomPasswordField(
              controller: confirmPasswordController,
              label: MultiLanguages.of(context)!.translate('confirm_password'),
              requiredField: true,
              validator: (value) {
                if ((value?.trim() ?? '').isEmpty) {
                  return MultiLanguages.of(
                    context,
                  )!.translate('register_confirm_password_required');
                }
                if (value != passwordController.text) {
                  return MultiLanguages.of(
                    context,
                  )!.translate('passwords_do_not_match');
                }
                return null;
              },
            ),
          ],
        ),
      );
    }

    if (_currentStep == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            MultiLanguages.of(context)!.translate('services_account_type'),
          ),
          SizedBox(height: 14.h),
          ValueListenableBuilder<String?>(
            valueListenable: _selectedRole,
            builder: (context, value, child) {
              return Column(
                children: [
                  _roleCard(
                    title: MultiLanguages.of(context)!.translate('client'),
                    subtitle: MultiLanguages.of(
                      context,
                    )!.translate('register_role_client_subtitle'),
                    info: MultiLanguages.of(
                      context,
                    )!.translate('register_role_client_info'),
                    selected: value == 'cliente',
                    onTap: () => _selectedRole.value = 'cliente',
                  ),
                  SizedBox(height: 10.h),
                  _roleCard(
                    title: MultiLanguages.of(context)!.translate('company'),
                    subtitle: MultiLanguages.of(
                      context,
                    )!.translate('register_role_company_subtitle'),
                    info: MultiLanguages.of(
                      context,
                    )!.translate('register_role_company_info'),
                    selected: value == 'empresa',
                    onTap: () => _selectedRole.value = 'empresa',
                  ),
                  SizedBox(height: 10.h),
                  _roleCard(
                    title: MultiLanguages.of(context)!.translate('freelancer'),
                    subtitle: MultiLanguages.of(
                      context,
                    )!.translate('register_role_freelancer_subtitle'),
                    info: MultiLanguages.of(
                      context,
                    )!.translate('register_role_freelancer_info'),
                    selected: value == 'freelancer',
                    onTap: () => _selectedRole.value = 'freelancer',
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 18.h),
          _sectionTitle(
            MultiLanguages.of(context)!.translate('register_policies_title'),
          ),
          SizedBox(height: 10.h),
          _termsDocumentCard(),
          SizedBox(height: 8.h),
          _policySwitch(
            title: MultiLanguages.of(context)!.translate('terms_conditions'),
            valueListenable: _acceptTerms,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _hero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          MultiLanguages.of(context)!.translate('login_create_account'),
          style: Style.getHeaderOne(color: Style.getPrimaryColor()),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            MultiLanguages.of(context)!.translate('register_subtitle'),
            style: Style.getHeaderTwo(color: Style.getTextColor()),
          ),
        ),
        SizedBox(height: 18.h),
        Center(
          child: CustomAvatarPicker(
            initialBytes: _photoBytes,
            initialXFile: _photoFile,
            onBytesChanged: (bytes) {
              setState(() => _photoBytes = bytes);
            },
            onXFileChanged: (file) {
              setState(() => _photoFile = file);
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
              Checkbox(
                value: value,
                onChanged: (newValue) =>
                    valueListenable.value = newValue ?? false,
                activeColor: Style.getPrimaryColor(),
                checkColor: Style.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.r),
                ),
                side: BorderSide(
                  color: Style.getFormFieldBorderColor(),
                  width: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _termsDocumentCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Style.getPrimaryColor().withValues(alpha: .08),
              Style.getCardColor().withValues(alpha: .02),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Style.getPrimaryColor().withValues(alpha: .18),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Style.getPrimaryColor(),
                size: 17.w,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  MultiLanguages.of(context)!.translate('terms_conditions'),
                  style: Style.getTextStyle(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _openingTermsPdf ? null : _openTermsPdfDirect,
                icon: Icon(
                  Icons.open_in_new_rounded,
                  color: Style.getPrimaryColor(),
                  size: 15.w,
                ),
                label: Text(
                  _openingTermsPdf
                      ? 'Abriendo...'
                      : MultiLanguages.of(context)!.translate('view_terms'),
                  style: Style.getTextStyle(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    if (_selectedRole.value == null) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(
          context,
        )!.translate('register_select_role_title'),
        message: MultiLanguages.of(
          context,
        )!.translate('register_select_role_message'),
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    if (!_acceptTerms.value) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(
          context,
        )!.translate('register_accept_terms_title'),
        message: MultiLanguages.of(
          context,
        )!.translate('register_accept_terms_message'),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    if (_photoFile != null) {
      final photoSize = await _photoFile!.length();
      if (photoSize > _maxProfilePhotoBytes) {
        if (!mounted) return;
        Dialogs.showSimpleDialog(
          context,
          title: MultiLanguages.of(
            context,
          )!.translate('register_image_too_large_title'),
          message: MultiLanguages.of(
            context,
          )!.translate('register_image_too_large_message'),
          color: Style.getErrorColor(),
          icon: Icons.error_outline_rounded,
        );
        return;
      }
    }

    if (!mounted) return;

    try {
      Dialogs.showLoader(
        context,
        message: MultiLanguages.of(context)!.translate('register_loading'),
      );

      final user = await UserService.register(
        context,
        name: nameController.text,
        lastName: firstLastNameController.text,
        maternalLastName: secondLastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        role: _selectedRole.value!,
        profilePhoto: _photoFile,
      );

      if (!mounted) return;
      Navigator.pop(context);

      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('register_success_title'),
        message:
            '${user.nombre} ${MultiLanguages.of(context)!.translate('register_success_message')}',
        color: Style.getPrimaryColor(),
        svg: Assets.svgCheckIcon,
        duration: 1800,
      );

      await Future.delayed(const Duration(milliseconds: 1900));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);

      final errorMessage = error is TimeoutException
          ? MultiLanguages.of(context)!.translate('timeout_error')
          : error.toString().replaceFirst('Exception: ', '').trim();

      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('register_error_title'),
        message: errorMessage,
        color: Style.getErrorColor(),
        svg: Assets.svgErrorIcon,
        duration: 2600,
      );
    }
  }

  Future<void> _openTermsPdfDirect() async {
    if (_openingTermsPdf) return;

    setState(() => _openingTermsPdf = true);
    try {
      final metadata =
          await LegalDocumentsService.fetchTermsAndConditionsMetadata();
      if (!mounted) return;

      await LegalDocumentsService.openTermsAndConditionsPdf(metadata);
    } on TimeoutException {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error'),
        message: MultiLanguages.of(context)!.translate('timeout_error'),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error'),
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _openingTermsPdf = false);
      }
    }
  }
}
