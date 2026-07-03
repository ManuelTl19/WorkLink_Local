import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/modules/users/screens/biometric_security_screen.dart';
import 'package:worklink_local/modules/users/screens/change_password_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  UserModel? _user;
  bool _isLoading = true;
  static const double _reputationRating = 4.3;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString(Constants.userEmailKey);

      if (userRaw != null && userRaw.isNotEmpty) {
        final userMap = jsonDecode(userRaw) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
      }
    } catch (e) {
      logWarning('No se pudo leer el perfil local: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          color: Style.getBackgroundColor(),
          child: _isLoading
              ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
              : CustomScrollView(
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
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Style.getTextColor(),
                        ),
                      ),
                      title: Text(
                        MultiLanguages.of(context)!.translate('profile'),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),
                            _headerCard(context),
                            SizedBox(height: 18.h),
                            _sectionTitle(
                              MultiLanguages.of(
                                context,
                              )!.translate('quick_actions'),
                            ),
                            _quickActionsGrid(context),

                            _sectionTitle(
                              MultiLanguages.of(
                                context,
                              )!.translate('personal_information'),
                            ),
                            _sectionCard(
                              children: [
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('name'),
                                  subtitle: _fullName,
                                  icon: Icon(
                                    Icons.badge_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: _goToEditProfile,
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('email'),
                                  subtitle: _email,
                                  icon: Icon(
                                    Icons.alternate_email_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: _goToEditProfile,
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('phone'),
                                  subtitle: _phone,
                                  icon: Icon(
                                    Icons.phone_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: _goToEditProfile,
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('roles'),
                                  subtitle: _roleText.isEmpty
                                      ? MultiLanguages.of(
                                          context,
                                        )!.translate('not_available')
                                      : _roleText,
                                  icon: Icon(
                                    Icons.work_outline_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: _goToEditProfile,
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('department'),
                                  subtitle: _department,
                                  icon: Icon(
                                    Icons.apartment_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: _goToEditProfile,
                                ),
                              ],
                            ),
                            SizedBox(height: 18.h),
                            _sectionTitle(
                              MultiLanguages.of(context)!.translate('security'),
                            ),
                            _sectionCard(
                              children: [
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('change_password'),
                                  subtitle: MultiLanguages.of(
                                    context,
                                  )!.translate('change_password_description'),
                                  icon: Icon(
                                    Icons.lock_reset_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      Transitions.slideUpTransition(
                                        const ChangePasswordScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('biometric_authentication'),
                                  subtitle: MultiLanguages.of(context)!
                                      .translate(
                                        'biometric_authentication_description',
                                      ),
                                  icon: Icon(
                                    Icons.fingerprint_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      Transitions.slideUpTransition(
                                        const BiometricSecurityScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 18.h),
                            _sectionTitle(
                              MultiLanguages.of(
                                context,
                              )!.translate('account_information'),
                            ),
                            _sectionCard(
                              children: [
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('registration_date'),
                                  subtitle: _registrationDate,
                                  icon: Icon(
                                    Icons.event_available_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: () => _showNotImplementedInfo(
                                    title: MultiLanguages.of(
                                      context,
                                    )!.translate('registration_date'),
                                  ),
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('last_access'),
                                  subtitle: _lastAccess,
                                  icon: Icon(
                                    Icons.schedule_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: () => _showNotImplementedInfo(
                                    title: MultiLanguages.of(
                                      context,
                                    )!.translate('last_access'),
                                  ),
                                ),
                                _divider(),
                                Tiles.settingTile(
                                  dense: true,
                                  title: MultiLanguages.of(
                                    context,
                                  )!.translate('account_status'),
                                  subtitle: _accountStatus,
                                  icon: Icon(
                                    Icons.verified_user_rounded,
                                    color: Style.getSecondaryColor(),
                                    size: 18.w,
                                  ),
                                  onTap: () => _showNotImplementedInfo(
                                    title: MultiLanguages.of(
                                      context,
                                    )!.translate('account_status'),
                                  ),
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

  Widget _headerCard(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(onTap: _onAvatarTap, child: _avatarWidget()),
            SizedBox(height: 12.h),
            Text(
              _fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Style.getHeaderTwo(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
            if (_roleText.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Style.getPrimaryColor().withValues(alpha: .12),
                  borderRadius: Style.getCircularBorderRadius(100),
                ),
                child: Text(
                  _roleText,
                  style: Style.getTextStyle(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ratingPill(),
                SizedBox(width: 8.w),
                Text(
                  _reputationLabel,
                  style: Style.getTextStyle(
                    color: Style.getObscureTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: 170.w,
              child: CustomWidgets.button(
                onTap: _goToEditProfile,
                color: Style.getPrimaryColor(),
                shape: 1,
                child: Text(
                  MultiLanguages.of(context)!.translate('edit_profile'),
                  style: Style.getHeaderThree(
                    color: Style.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsGrid(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: MultiLanguages.of(context)!.translate('personal_information'),
        icon: Icons.person_outline_rounded,
        onTap: () => _showNotImplementedInfo(
          title: MultiLanguages.of(context)!.translate('personal_information'),
        ),
      ),
      _QuickActionData(
        title: MultiLanguages.of(context)!.translate('security'),
        icon: Icons.security_rounded,
        onTap: () => _showNotImplementedInfo(
          title: MultiLanguages.of(context)!.translate('security'),
        ),
      ),
      _QuickActionData(
        title: MultiLanguages.of(context)!.translate('change_password'),
        icon: Icons.lock_reset_rounded,
        onTap: () {
          Navigator.of(
            context,
          ).push(Transitions.slideUpTransition(const ChangePasswordScreen()));
        },
      ),
      _QuickActionData(
        title: MultiLanguages.of(
          context,
        )!.translate('biometric_authentication'),
        icon: Icons.fingerprint_rounded,
        onTap: () {
          Navigator.of(context).push(
            Transitions.slideUpTransition(const BiometricSecurityScreen()),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.15,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return Card(
          color: Style.getCardColor(),
          elevation: 4,
          shadowColor: Style.getShadowColor(),
          shape: RoundedRectangleBorder(
            borderRadius: Style.getCircularBorderRadius(18),
          ),
          child: InkWell(
            borderRadius: Style.getCircularBorderRadius(18),
            onTap: item.onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: Style.getPrimaryColor().withValues(alpha: .12),
                      borderRadius: Style.getCircularBorderRadius(100),
                    ),
                    child: Icon(
                      item.icon,
                      color: Style.getPrimaryColor(),
                      size: 14.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getTextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _avatarWidget() {
    final avatarUrl = _avatarUrl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (avatarUrl.isNotEmpty)
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Style.getPrimaryColor().withValues(alpha: .15),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Style.getPrimaryColor(),
                  ),
                ),
                errorWidget: (context, url, error) => _initialsAvatar(),
              ),
            ),
          )
        else
          _initialsAvatar(),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Style.getPrimaryColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Style.getShadowColor(),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.edit_rounded, color: Style.white, size: 14.w),
          ),
        ),
      ],
    );
  }

  Widget _initialsAvatar() {
    return CircleAvatar(
      radius: 40.r,
      backgroundColor: Style.getPrimaryColor().withValues(alpha: .14),
      child: Text(
        _initials,
        style: Style.getHeaderThree(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  void _onAvatarTap() {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: Style.getSecondaryColor(),
                  ),
                  title: Text(
                    MultiLanguages.of(context)!.translate('take_photo'),
                    style: Style.getTextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showNotImplementedInfo(
                      title: MultiLanguages.of(
                        context,
                      )!.translate('take_photo'),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Style.getSecondaryColor(),
                  ),
                  title: Text(
                    MultiLanguages.of(
                      context,
                    )!.translate('choose_from_gallery'),
                    style: Style.getTextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showNotImplementedInfo(
                      title: MultiLanguages.of(
                        context,
                      )!.translate('choose_from_gallery'),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Style.getErrorColor(),
                  ),
                  title: Text(
                    MultiLanguages.of(context)!.translate('remove_photo'),
                    style: Style.getTextStyle(
                      fontWeight: FontWeight.w600,
                      color: Style.getErrorColor(),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showNotImplementedInfo(
                      title: MultiLanguages.of(
                        context,
                      )!.translate('remove_photo'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToEditProfile() {
    _showNotImplementedInfo(
      title: MultiLanguages.of(context)!.translate('edit_profile'),
    );
  }

  Future<void> _onDeleteAccount() async {
    final shouldDelete = await Dialogs.showConfirmDialog(
      context,
      title: MultiLanguages.of(context)!.translate('delete_account'),
      message: MultiLanguages.of(
        context,
      )!.translate('delete_account_description'),
      svg: Assets.svgWarningIcon,
      confirmText: MultiLanguages.of(context)!.translate('delete'),
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
    );

    if (!mounted || !shouldDelete) return;

    Dialogs.showSimpleDialog(
      context,
      title: MultiLanguages.of(context)!.translate('delete_account'),
      message: MultiLanguages.of(context)!.translate('feature_coming_soon'),
      color: Style.getErrorColor(),
      icon: Icons.delete_forever_rounded,
    );
  }

  void _showNotImplementedInfo({required String title}) {
    Dialogs.showSimpleDialog(
      context,
      title: title,
      message: MultiLanguages.of(context)!.translate('feature_coming_soon'),
      color: Style.getPrimaryColor(),
      icon: Icons.info_outline_rounded,
    );
  }

  String get _avatarUrl => (_user?.fotoPerfil ?? '').trim();

  String get _fullName {
    final name = [
      _user?.nombre ?? '',
      _user?.apellidoP ?? '',
      _user?.apellidoM ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');

    if (name.isEmpty) {
      return MultiLanguages.of(context)!.translate('profile');
    }

    return name;
  }

  String get _email {
    final value = (_user?.correo ?? '').trim();
    return value.isEmpty ? 'sin-correo@worklink.local' : value;
  }

  String get _phone {
    final value = (_user?.telefono ?? '').trim();
    return value.isEmpty
        ? MultiLanguages.of(context)!.translate('not_available')
        : value;
  }

  String get _department {
    final rawDepartment = _user?.departamento.trim() ?? '';
    if (rawDepartment.isNotEmpty) return rawDepartment;

    return MultiLanguages.of(context)!.translate('not_available');
  }

  String get _registrationDate {
    final raw = AppSettings.loginDate;
    if (raw == null || raw.trim().isEmpty) {
      return MultiLanguages.of(context)!.translate('not_available');
    }

    return _formatDate(raw);
  }

  String get _lastAccess {
    final raw = AppSettings.lastEnterDate;
    if (raw == null || raw.trim().isEmpty) {
      return MultiLanguages.of(context)!.translate('not_available');
    }

    return _formatDate(raw);
  }

  String get _accountStatus {
    return AppSettings.isSignedIn
        ? MultiLanguages.of(context)!.translate('active')
        : MultiLanguages.of(context)!.translate('inactive');
  }

  String get _reputationLevel {
    if (_reputationRating >= 4.5) {
      return MultiLanguages.of(context)!.translate('excellent');
    }
    if (_reputationRating >= 3.5) {
      return MultiLanguages.of(context)!.translate('good');
    }
    return MultiLanguages.of(context)!.translate('standard');
  }

  String get _reputationLabel {
    final value = _reputationRating.toStringAsFixed(1);
    return '${MultiLanguages.of(context)!.translate('reputation')}: $value';
  }

  String get _roleText {
    final roles = _user?.roles ?? [];
    if (roles.isNotEmpty) {
      return roles.first;
    }

    final type = (_user?.tipoCuenta ?? '').trim();
    return type;
  }

  String get _initials {
    final parts = _fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'WL';

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts[1].substring(0, 1).toUpperCase()
        : '';

    return '$first$second';
  }

  Widget _ratingPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.getPrimaryColor().withValues(alpha: .08),
        borderRadius: Style.getCircularBorderRadius(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            final filled = index < _reputationRating.floor();
            final partial =
                index == _reputationRating.floor() &&
                _reputationRating % 1 >= 0.3;
            return Padding(
              padding: EdgeInsets.only(right: index == 4 ? 0 : 2.w),
              child: Icon(
                partial ? Icons.star_half_rounded : Icons.star_rounded,
                size: 13.w,
                color: filled || partial
                    ? Style.getPrimaryColor()
                    : Style.getObscureTextColor().withValues(alpha: .35),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _ratingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.floor();
        final partial = index == rating.floor() && rating % 1 >= 0.3;
        return Icon(
          partial ? Icons.star_half_rounded : Icons.star_rounded,
          size: 16.w,
          color: filled || partial
              ? Style.getPrimaryColor()
              : Style.getObscureTextColor().withValues(alpha: .28),
        );
      }),
    );
  }

  String _formatDate(String raw) {
    try {
      final locale = Localizations.localeOf(context).toString();
      return DateFormat('dd/MM/yyyy HH:mm', locale).format(raw.toDateTime());
    } catch (e) {
      return raw;
    }
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
