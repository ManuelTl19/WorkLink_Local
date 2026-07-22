import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/users/services/user_service.dart';
import 'package:worklink_local/utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
                MultiLanguages.of(context)!.translate('change_password'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      _sectionCard(
                        children: [
                          _passwordField(
                            controller: _currentPasswordController,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('current_password'),
                            hint: '********',
                          ),
                          _divider(),
                          _passwordField(
                            controller: _newPasswordController,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('new_password'),
                            hint: '********',
                          ),
                          _divider(),
                          _passwordField(
                            controller: _confirmPasswordController,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('confirm_password'),
                            hint: '********',
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return MultiLanguages.of(
                                  context,
                                )!.translate('field_required');
                              }

                              if (value != _newPasswordController.text) {
                                return MultiLanguages.of(
                                  context,
                                )!.translate('passwords_do_not_match');
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: CustomWidgets.button(
                          onTap: _isSaving ? () {} : _onSave,
                          color: Style.getPrimaryColor(),
                          shape: 1,
                          child: _isSaving
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Style.white,
                                  ),
                                )
                              : Text(
                                  MultiLanguages.of(context)!.translate('save'),
                                  style: Style.getHeaderTwo(
                                    color: Style.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String title,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: CustomPasswordField(
        controller: controller,
        label: title,
        hintText: hint,
        validator:
            validator ??
            (value) => (value ?? '').isEmpty
                ? MultiLanguages.of(context)!.translate('field_required')
                : null,
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();

    if (next.length < 6) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('change_password'),
        message: 'La nueva contrasena debe tener al menos 6 caracteres.',
        color: Style.getErrorColor(),
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (current == next) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('change_password'),
        message: 'La nueva contrasena debe ser distinta a la actual.',
        color: Style.getErrorColor(),
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await UserService.changePassword(
        currentPassword: current,
        newPassword: next,
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('change_password'),
        message: 'Contrasena actualizada correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.lock_open_rounded,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
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
        setState(() => _isSaving = false);
      }
    }
  }
}
