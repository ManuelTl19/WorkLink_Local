import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/components/freelancer_profile_form_dialog.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_availability_model.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancer_availability_service.dart';
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
  int _portfolioRefreshVersion = 0;

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
            title: MultiLanguages.of(context)?.translate('success') ?? 'Exito',
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
            title: MultiLanguages.of(context)?.translate('success') ?? 'Exito',
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
      setState(() => _profile = null);
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)?.translate('success') ?? 'Exito',
        message: MultiLanguages.of(
          context,
        )!.translate('profile_deleted_successfully'),
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _openAvailabilityManager() async {
    final profileId = _profile?.id;
    if (profileId == null || profileId <= 0) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)?.translate('error') ?? 'Error',
        message:
            MultiLanguages.of(context)?.translate('no_profile_yet') ??
            'Aun no tienes perfil profesional.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _AvailabilityManagerSheet(freelancerProfileId: profileId),
    );

    if (!mounted) return;
    setState(() {
      _portfolioRefreshVersion++;
    });
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
            key: ValueKey(
              'portfolio-${_profile!.id}-$_portfolioRefreshVersion',
            ),
            freelancer: _profile!,
            forceOwner: widget.ownerPreview,
            onEditProfile: widget.ownerPreview ? _openProfileForm : null,
            onDeleteProfile: widget.ownerPreview ? _deleteProfile : null,
          ),
          if (widget.ownerPreview && _profile?.id != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              right: 14.w,
              child: Material(
                color: Style.getCardColor().withValues(alpha: .92),
                shape: const CircleBorder(),
                elevation: 5,
                shadowColor: Style.getShadowColor(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openAvailabilityManager,
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.event_available_rounded,
                      color: Style.getPrimaryColor(),
                      size: 20.w,
                    ),
                  ),
                ),
              ),
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

class _AvailabilityManagerSheet extends StatefulWidget {
  const _AvailabilityManagerSheet({required this.freelancerProfileId});

  final int freelancerProfileId;

  @override
  State<_AvailabilityManagerSheet> createState() =>
      _AvailabilityManagerSheetState();
}

class _AvailabilityManagerSheetState extends State<_AvailabilityManagerSheet> {
  static const List<String> _allowedStatuses = [
    'available',
    'busy',
    'vacation',
  ];

  bool _loading = true;
  bool _saving = false;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _status = 'available';

  List<FreelancerAvailabilityModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _rangesOverlap({
    required DateTime aStart,
    required DateTime aEnd,
    required DateTime bStart,
    required DateTime bEnd,
  }) {
    return !aEnd.isBefore(bStart) && !bEnd.isBefore(aStart);
  }

  String? _validateAvailabilityRange({
    required DateTime start,
    required DateTime end,
    int? excludeAvailabilityId,
  }) {
    final today = _dateOnly(DateTime.now());
    final normalizedStart = _dateOnly(start);
    final normalizedEnd = _dateOnly(end);

    if (normalizedStart.isBefore(today)) {
      return 'La fecha de inicio debe ser hoy o una fecha futura.';
    }
    if (normalizedEnd.isBefore(normalizedStart)) {
      return 'La fecha final debe ser mayor o igual a la fecha inicial.';
    }

    for (final item in _items) {
      if (excludeAvailabilityId != null && item.id == excludeAvailabilityId) {
        continue;
      }
      final existingStart = _dateOnly(item.startDate);
      final existingEnd = _dateOnly(item.endDate);
      if (_rangesOverlap(
        aStart: normalizedStart,
        aEnd: normalizedEnd,
        bStart: existingStart,
        bEnd: existingEnd,
      )) {
        return 'No se permiten rangos superpuestos para la disponibilidad.';
      }
    }

    return null;
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final items = await FreelancerAvailabilityService.getByFreelancer(
        widget.freelancerProfileId,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Fecha de inicio' : 'Fecha final',
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
      confirmText: MultiLanguages.of(context)!.translate('save'),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }

  Future<void> _saveAvailability() async {
    if (_saving) return;

    final validationMessage = _validateAvailabilityRange(
      start: _startDate,
      end: _endDate,
    );
    if (validationMessage != null) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Rango invalido',
        message: validationMessage,
        color: Style.getErrorColor(),
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final request = FreelancerAvailabilityModel(
        freelancerId: widget.freelancerProfileId,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
      );

      await FreelancerAvailabilityService.create(request);
      if (!mounted) return;

      setState(() {
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 7));
        _status = 'available';
        _saving = false;
      });

      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _openEditModal(FreelancerAvailabilityModel item) async {
    if (item.id == null) return;

    DateTime modalStartDate = item.startDate;
    DateTime modalEndDate = item.endDate;
    String modalStatus = item.status;
    bool modalIsSaving = false;

    await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate({required bool isStart}) async {
              final selected = await showDatePicker(
                context: context,
                initialDate: isStart ? modalStartDate : modalEndDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: isStart ? 'Fecha de inicio' : 'Fecha final',
                cancelText: MultiLanguages.of(context)!.translate('cancel'),
                confirmText: MultiLanguages.of(context)!.translate('save'),
              );

              if (selected == null) return;

              setModalState(() {
                if (isStart) {
                  modalStartDate = DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
                  if (modalEndDate.isBefore(modalStartDate)) {
                    modalEndDate = modalStartDate;
                  }
                } else {
                  modalEndDate = DateTime(
                    selected.year,
                    selected.month,
                    selected.day,
                  );
                }
              });
            }

            Future<void> saveEdit() async {
              final validationMessage = _validateAvailabilityRange(
                start: modalStartDate,
                end: modalEndDate,
                excludeAvailabilityId: item.id,
              );
              if (validationMessage != null) {
                Dialogs.showSimpleDialog(
                  context,
                  title: 'Rango invalido',
                  message: validationMessage,
                  color: Style.getErrorColor(),
                  icon: Icons.warning_amber_rounded,
                );
                return;
              }

              setModalState(() => modalIsSaving = true);

              try {
                await FreelancerAvailabilityService.update(
                  item.id!,
                  item.copyWith(
                    startDate: modalStartDate,
                    endDate: modalEndDate,
                    status: modalStatus,
                  ),
                );

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }

                if (!mounted) return;
                await _loadItems();
              } catch (e) {
                if (!mounted) return;
                setModalState(() => modalIsSaving = false);
                Dialogs.showSimpleDialog(
                  context,
                  title: 'Error',
                  message: e.toString().replaceFirst('Exception: ', ''),
                  color: Style.getErrorColor(),
                  icon: Icons.error_outline_rounded,
                );
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  14.h,
                  16.w,
                  MediaQuery.of(context).viewInsets.bottom + 14.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar disponibilidad',
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _dateField(
                      label: 'Fecha inicio',
                      value: _formatDate(modalStartDate),
                      icon: Icons.event_available_rounded,
                      onTap: () => pickDate(isStart: true),
                    ),
                    SizedBox(height: 10.h),
                    _dateField(
                      label: 'Fecha fin',
                      value: _formatDate(modalEndDate),
                      icon: Icons.event_rounded,
                      onTap: () => pickDate(isStart: false),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Estado',
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _statusSelector(
                      value: modalStatus,
                      onChanged: (value) {
                        setModalState(() => modalStatus = value);
                      },
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: () {
                          if (modalIsSaving) return;
                          saveEdit();
                        },
                        color: Style.getPrimaryColor(),
                        shape: 1,
                        child: modalIsSaving
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Style.white,
                                ),
                              )
                            : Text(
                                'Guardar cambios',
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
          },
        );
      },
    );
  }

  Future<void> _deleteAvailability(FreelancerAvailabilityModel item) async {
    if (item.id == null) return;

    final confirmed = await Dialogs.showConfirmDialog(
      context,
      title: 'Eliminar disponibilidad',
      message: 'Esta accion quitara este rango de fechas. Deseas continuar?',
      svg: Assets.svgWarningIcon,
      confirmText: MultiLanguages.of(context)!.translate('delete'),
      cancelText: MultiLanguages.of(context)!.translate('cancel'),
    );

    if (!confirmed || !mounted) return;

    try {
      await FreelancerAvailabilityService.delete(item.id!);
      if (!mounted) return;
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .86,
        child: Column(
          children: [
            _sheetHeader(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _formCard(),
                    SizedBox(height: 14.h),
                    _sectionLabel(
                      title: 'Registros de disponibilidad',
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: _loading
                          ? Center(
                              child: CustomWidgets.mProgress(
                                Style.getPrimaryColor(),
                              ),
                            )
                          : _items.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                return _availabilityCard(_items[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Style.getPrimaryColor().withValues(alpha: .18),
            Style.getCardColor(),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Style.getObscureTextColor().withValues(alpha: .14),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Style.getObscureTextColor().withValues(alpha: .28),
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Style.getPrimaryColor().withValues(alpha: .14),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: Style.getPrimaryColor(),
                  size: 19.w,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disponibilidad',
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: Style.getObscureTextColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel({required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Card(
      color: Style.getCardColor(),
      elevation: 6,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(
        borderRadius: Style.getCircularBorderRadius(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(
              title: 'Nueva disponibilidad',
            ),
            _dateField(
              label: 'Fecha inicio',
              value: _formatDate(_startDate),
              icon: Icons.event_available_rounded,
              onTap: () => _selectDate(isStart: true),
            ),
            SizedBox(height: 10.h),
            _dateField(
              label: 'Fecha fin',
              value: _formatDate(_endDate),
              icon: Icons.event_rounded,
              onTap: () => _selectDate(isStart: false),
            ),
            SizedBox(height: 6.h),
            _statusSelector(
              value: _status,
              onChanged: (value) => setState(() => _status = value),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: CustomWidgets.button(
                onTap: () {
                  if (_saving) return;
                  _saveAvailability();
                },
                color: Style.getPrimaryColor(),
                shape: 1,
                child: _saving
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Style.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_task_rounded,
                            color: Style.white,
                            size: 16.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Guardar disponibilidad',
                            style: Style.getHeaderThree(
                              color: Style.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusSelector({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Style.getObscureTextColor().withValues(alpha: .22),
        ),
      ),
      child: Row(
        children: _allowedStatuses.map((status) {
          final selected = value == status;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected
                      ? _statusColor(status).withValues(alpha: .18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _statusLabel(status),
                  textAlign: TextAlign.center,
                  style: Style.getTextStyle(
                    color: selected
                        ? _statusColor(status)
                        : Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Style.getBackgroundColor(),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: Style.getObscureTextColor().withValues(alpha: .22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Style.getPrimaryColor().withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15.w, color: Style.getPrimaryColor()),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.w,
                color: Style.getObscureTextColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Style.getObscureTextColor().withValues(alpha: .16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: Style.getPrimaryColor().withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: Style.getPrimaryColor(),
              size: 22.w,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Aun no tienes disponibilidades registradas.',
            textAlign: TextAlign.center,
            style: Style.getTextStyle(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Completa el formulario superior para crear tu primer rango.',
            textAlign: TextAlign.center,
            style: Style.getTextStyle(
              color: Style.getObscureTextColor(),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard(FreelancerAvailabilityModel item) {
    final statusColor = _statusColor(item.status);
    final rangeDays = item.endDate.difference(item.startDate).inDays + 1;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor().withValues(alpha: .12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    textAlign: TextAlign.center,
                    style: Style.getTextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              PopupMenuButton<String>(
                tooltip: 'Acciones',
                color: Style.getCardColor(),
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Style.getObscureTextColor(),
                  size: 20.w,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _openEditModal(item);
                    return;
                  }
                  if (value == 'delete') {
                    _deleteAvailability(item);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: Style.getPrimaryColor(),
                          size: 18.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Editar',
                          style: Style.getTextStyle(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Style.getErrorColor(),
                          size: 18.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Eliminar',
                          style: Style.getTextStyle(
                            color: Style.getErrorColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Style.getBackgroundColor(),
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(
                color: Style.getObscureTextColor().withValues(alpha: .16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 15.w,
                      color: Style.getPrimaryColor(),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Inicio: ${_formatDate(item.startDate)}',
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.h),
                Row(
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 15.w,
                      color: Style.getObscureTextColor(),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Fin: ${_formatDate(item.endDate)}',
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              Icon(
                Icons.timelapse_rounded,
                size: 14.w,
                color: Style.getObscureTextColor(),
              ),
              SizedBox(width: 6.w),
              Text(
                _rangeDaysLabel(rangeDays),
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _rangeDaysLabel(int days) {
    if (days <= 1) return 'Duracion: 1 dia';
    return 'Duracion: $days dias';
  }

  String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'busy':
        return 'Ocupado';
      case 'vacation':
        return 'Vacaciones';
      default:
        return 'Disponible';
    }
  }

  Color _statusColor(String value) {
    switch (value.toLowerCase()) {
      case 'busy':
        return Colors.orange;
      case 'vacation':
        return Colors.blue;
      default:
        return Style.getPrimaryColor();
    }
  }

  String _formatDate(DateTime value) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}
