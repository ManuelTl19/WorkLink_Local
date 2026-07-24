import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/components/freelancer_profile_form_dialog.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/portfolio/screens/portfolio_screen.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class FreelancerServiceProfileScreen extends StatefulWidget {
  const FreelancerServiceProfileScreen({
    super.key,
    required this.freelancerId,
    this.ownerPreview = false,
  });

  final int? freelancerId;
  final bool ownerPreview;

  @override
  State<FreelancerServiceProfileScreen> createState() =>
      _FreelancerServiceProfileScreenState();
}

class _FreelancerServiceProfileScreenState
    extends State<FreelancerServiceProfileScreen> {
  bool _loading = true;
  bool _actionLoading = false;
  FreelancerModel? _profile;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw =
        prefs.getString(Constants.userEmailKey) ?? prefs.getString('user');
    if (userRaw == null || userRaw.isEmpty) return;
    _currentUser = UserModel.fromJson(jsonDecode(userRaw));
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      await _loadCurrentUser();

      FreelancerModel? profile;
      if (widget.ownerPreview) {
        final userId = _currentUser?.id;
        if (userId != null) {
          profile = await FreelancersService.getProfileByUserId(userId);
        }
      } else if (widget.freelancerId != null) {
        profile = await FreelancersService.getFreelancerById(
          widget.freelancerId!,
        );
      }

      if (profile != null && _currentUser != null) {
        final userName = [
          _currentUser!.nombre,
          _currentUser!.apellidoP,
          _currentUser!.apellidoM,
        ].where((part) => part.trim().isNotEmpty).join(' ');

        profile = profile.copyWith(
          fullName: profile.fullName.trim().isNotEmpty
              ? profile.fullName
              : userName,
          avatarUrl: profile.avatarUrl.trim().isNotEmpty
              ? profile.avatarUrl
              : _currentUser!.fotoPerfil,
        );
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openProfileForm() async {
    if (_currentUser == null) {
      await _loadCurrentUser();
    }
    if (!mounted) return;

    final result = await Navigator.of(context).push(
      Transitions.slideUpTransition(
        FreelancerProfileFormDialog(
          initialProfile: _profile,
          isEditing: _profile != null,
        ),
      ),
    );

    if (result == null) return;

    setState(() => _actionLoading = true);
    try {
      if (_profile?.id != null) {
        await FreelancersService.updateProfile(_profile!.id!, result);
        if (mounted) {
          Dialogs.showSimpleDialog(
            context,
            title: MultiLanguages.of(context)?.translate('success') ?? 'Éxito',
            message: MultiLanguages.of(
              context,
            )!.translate('profile_updated_successfully'),
            color: Style.getPrimaryColor(),
            icon: Icons.check_circle_rounded,
          );
        }
      } else {
        if (_currentUser?.id == null) {
          throw Exception(
            MultiLanguages.of(context)?.translate('session_not_found') ??
                'No se encontro sesion activa. Vuelve a iniciar sesion.',
          );
        }
        final userId = _currentUser!.id;
        final payload = result.copyWith(userId: userId);
        final existingProfile = await FreelancersService.getProfileByUserId(
          userId,
        );

        if (existingProfile?.id != null) {
          await FreelancersService.updateProfile(existingProfile!.id!, payload);
        } else {
          await FreelancersService.createProfile(payload);
        }
        if (mounted) {
          Dialogs.showSimpleDialog(
            context,
            title: MultiLanguages.of(context)?.translate('success') ?? 'Éxito',
            message: MultiLanguages.of(
              context,
            )!.translate('profile_created_successfully'),
            color: Style.getPrimaryColor(),
            icon: Icons.check_circle_rounded,
          );
        }
      }
      await _loadProfile();
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
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _deleteProfile() async {
    if (_currentUser == null) {
      await _loadCurrentUser();
    }

    int? profileId = _profile?.id;
    if (profileId == null && _currentUser?.id != null) {
      final existing = await FreelancersService.getProfileByUserId(
        _currentUser!.id,
      );
      if (existing != null) {
        profileId = existing.id;
        _profile = existing;
      }
    }

    if (profileId == null) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error'),
        message:
            MultiLanguages.of(context)?.translate('profile_id_not_found') ??
            'No se encontro el id del perfil para eliminar.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: MultiLanguages.of(context)!.translate('delete_profile'),
      message: MultiLanguages.of(context)!.translate('confirm_delete_profile'),
      confirmText: MultiLanguages.of(context)!.translate('delete'),
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
      icon: Icons.delete_outline_rounded,
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );
    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    try {
      await FreelancersService.deleteProfile(profileId);
      if (!mounted) return;
      setState(() {
        _profile = null;
      });
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)?.translate('success') ?? 'Éxito',
        message: MultiLanguages.of(
          context,
        )!.translate('profile_deleted_successfully'),
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error_deleting_profile'),
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())),
      );
    }

    if (_profile != null) {
      return Stack(
        children: [
          PortfolioScreen(
            freelancer: _profile!,
            forceOwner: widget.ownerPreview,
            onEditProfile: widget.ownerPreview ? _openProfileForm : null,
            onDeleteProfile: widget.ownerPreview ? _deleteProfile : null,
          ),
          if (_actionLoading)
            Positioned.fill(
              child: Container(
                color: Style.black.withValues(alpha: .14),
                child: Center(
                  child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Style.getTextColor(),
          ),
        ),
        title: Text(
          MultiLanguages.of(context)?.translate('professional_profile') ??
              'Perfil profesional',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.ownerPreview
                    ? (MultiLanguages.of(
                            context,
                          )?.translate('no_profile_yet') ??
                          'Aun no tienes perfil profesional.')
                    : (MultiLanguages.of(
                            context,
                          )?.translate('freelancer_profile_not_found') ??
                          'No se encontro el perfil del freelancer.'),
                textAlign: TextAlign.center,
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.ownerPreview) ...[
                SizedBox(height: 14.h),
                CustomWidgets.button(
                  onTap: _openProfileForm,
                  color: Style.getPrimaryColor(),
                  child: Text(
                    MultiLanguages.of(context)?.translate('create_now') ??
                        'Crear perfil',
                    style: Style.getHeaderThree(
                      color: Style.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
