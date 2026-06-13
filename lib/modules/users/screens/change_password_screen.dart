import 'package:worklink_local/helpers/helpers.dart';
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

  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

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
                            obscure: !_currentVisible,
                            onToggle: () {
                              setState(() {
                                _currentVisible = !_currentVisible;
                              });
                            },
                          ),
                          _divider(),
                          _passwordField(
                            controller: _newPasswordController,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('new_password'),
                            hint: '********',
                            obscure: !_newVisible,
                            onToggle: () {
                              setState(() {
                                _newVisible = !_newVisible;
                              });
                            },
                          ),
                          _divider(),
                          _passwordField(
                            controller: _confirmPasswordController,
                            title: MultiLanguages.of(
                              context,
                            )!.translate('confirm_password'),
                            hint: '********',
                            obscure: !_confirmVisible,
                            onToggle: () {
                              setState(() {
                                _confirmVisible = !_confirmVisible;
                              });
                            },
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
                          onTap: _onSave,
                          color: Style.getPrimaryColor(),
                          shape: 1,
                          child: Text(
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
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            style: Style.getTextStyle(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Style.getHintStyle(color: Style.getObscureTextColor()),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide(color: Style.getBorderColor(), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide(
                  color: Style.getPrimaryColor(),
                  width: 1,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Style.getPrimaryColor(),
                  size: 18.w,
                ),
              ),
            ),
            validator:
                validator ??
                (value) => (value ?? '').isEmpty
                    ? MultiLanguages.of(context)!.translate('field_required')
                    : null,
          ),
        ],
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    Dialogs.showSimpleDialog(
      context,
      title: MultiLanguages.of(context)!.translate('change_password'),
      message: MultiLanguages.of(context)!.translate('feature_coming_soon'),
      color: Style.getPrimaryColor(),
      icon: Icons.lock_outline_rounded,
    );
  }
}
