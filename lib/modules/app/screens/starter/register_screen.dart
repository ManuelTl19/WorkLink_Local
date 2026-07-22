import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/helpers/services/legal_documents_service.dart';
import 'package:worklink_local/modules/settings/screens/terms_conditions_screen.dart';
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
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final firstLastNameController = TextEditingController();
  final secondLastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final ValueNotifier<String?> _selectedRole = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _acceptTerms = ValueNotifier<bool>(false);
  bool _loadingTerms = true;
  String? _termsError;
  LegalDocumentMetadata? _termsMetadata;

  Uint8List? _photoBytes;
  XFile? _photoFile;

  @override
  void initState() {
    super.initState();
    _loadTermsMetadata();
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

  Future<void> _loadTermsMetadata() async {
    setState(() {
      _loadingTerms = true;
      _termsError = null;
    });

    try {
      final metadata =
          await LegalDocumentsService.fetchTermsAndConditionsMetadata();
      if (!mounted) return;
      setState(() {
        _termsMetadata = metadata;
        _loadingTerms = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadingTerms = false;
        _termsError = MultiLanguages.of(context)!.translate('timeout_error');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTerms = false;
        _termsError = e.toString().replaceFirst('Exception: ', '');
      });
    }
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
                SizedBox(height: 12.h),
                CustomInputField(
                  controller: emailController,
                  label: MultiLanguages.of(context)!.translate('login_email'),
                  keyboardType: TextInputType.emailAddress,
                  requiredField: true,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return MultiLanguages.of(
                        context,
                      )!.translate('enter_email');
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
                    final normalized = text.replaceAll(
                      RegExp(r'[\s\-\(\)]'),
                      '',
                    );
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
                  label: MultiLanguages.of(
                    context,
                  )!.translate('login_password'),
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
                  label: MultiLanguages.of(
                    context,
                  )!.translate('confirm_password'),
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
                SizedBox(height: 26.h),
                _sectionTitle(
                  MultiLanguages.of(
                    context,
                  )!.translate('services_account_type'),
                ),
                SizedBox(height: 14.h),
                ValueListenableBuilder<String?>(
                  valueListenable: _selectedRole,
                  builder: (context, value, child) {
                    return Column(
                      children: [
                        _roleCard(
                          title: MultiLanguages.of(
                            context,
                          )!.translate('client'),
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
                          title: MultiLanguages.of(
                            context,
                          )!.translate('company'),
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
                          title: MultiLanguages.of(
                            context,
                          )!.translate('freelancer'),
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
                SizedBox(height: 26.h),
                _sectionTitle(
                  MultiLanguages.of(
                    context,
                  )!.translate('register_policies_title'),
                ),
                _termsDocumentCard(),
                SizedBox(height: 8.h),
                _policySwitch(
                  title: MultiLanguages.of(
                    context,
                  )!.translate('terms_conditions'),
                  valueListenable: _acceptTerms,
                ),
                SizedBox(height: 26.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomWidgets.button(
                    onTap: _createAccount,
                    color: Style.getPrimaryColor(),
                    height: 50,
                    child: Text(
                      MultiLanguages.of(
                        context,
                      )!.translate('login_create_account'),
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

  Widget _termsDocumentCard() {
    final metadata = _termsMetadata;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getBorderRadius(),
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MultiLanguages.of(context)!.translate('terms_conditions'),
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          if (_loadingTerms)
            Row(
              children: [
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Style.getPrimaryColor(),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  MultiLanguages.of(context)!.translate('terms_loading'),
                  style: Style.getTextStyle(
                    color: Style.getObscureTextColor(),
                    fontSize: 9,
                  ),
                ),
              ],
            )
          else if (_termsError != null)
            Text(
              _termsError!,
              style: Style.getTextStyle(
                color: Style.getErrorColor(),
                fontSize: 9,
              ),
            )
          else if (metadata != null)
            Text(
              '${MultiLanguages.of(context)!.translate('terms_updated_at')}: '
              '${LegalDocumentsService.formatUpdatedAt(metadata.updatedAt)}  •  '
              '${MultiLanguages.of(context)!.translate('terms_file_size')}: '
              '${LegalDocumentsService.formatFileSize(metadata.fileSize)}',
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontSize: 9,
              ),
            )
          else
            Text(
              MultiLanguages.of(context)!.translate('terms_unavailable'),
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontSize: 9,
              ),
            ),
          SizedBox(height: 8.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsConditionsScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.open_in_new_rounded,
                  color: Style.getPrimaryColor(),
                  size: 16.w,
                ),
                label: Text(
                  MultiLanguages.of(context)!.translate('view_terms'),
                  style: Style.getTextStyle(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (_termsError != null)
                TextButton(
                  onPressed: _loadTermsMetadata,
                  child: Text(
                    MultiLanguages.of(context)!.translate('retry'),
                    style: Style.getTextStyle(
                      color: Style.getPrimaryColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
    if (!_formKey.currentState!.validate()) return;

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
}
