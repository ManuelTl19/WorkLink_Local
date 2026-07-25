import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/companies/models/company_profile_model.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class CompanyProfileScreen extends StatefulWidget {
  final int? companyId;
  final int? userId;

  const CompanyProfileScreen({super.key, this.companyId, this.userId});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final CompaniesService _service = CompaniesService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _industryCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _actionLoading = false;
  bool _canEdit = false;
  bool _canCreate = false;
  bool _isAdmin = false;
  int? _viewerId;
  UserModel? _viewer;
  CompanyProfileModel? _company;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _industryCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  bool get _hasCompanyRole {
    return _viewerRoles.contains('empresa') || _viewerRoles.contains('company');
  }

  bool get _hasFreelancerRole {
    final accountType = (_viewer?.tipoCuenta ?? '').toLowerCase().trim();
    return _viewerRoles.contains('freelancer') || accountType == 'freelancer';
  }

  List<String> get _viewerRoles {
    final user = _viewer;
    if (user == null) return const <String>[];

    return user.roles
        .map((role) => role.toLowerCase().trim())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw =
          prefs.getString(Constants.userEmailKey) ?? prefs.getString('user');

      if (userRaw != null && userRaw.isNotEmpty) {
        _viewer = UserModel.fromJson(
          jsonDecode(userRaw) as Map<String, dynamic>,
        );
        _viewerId = _viewer?.id;

        final normalizedRoles = _viewerRoles;
        final currentType = (_viewer?.tipoCuenta ?? '').toLowerCase().trim();
        _isAdmin =
            normalizedRoles.contains('admin') ||
            normalizedRoles.contains('administrador') ||
            currentType == 'admin' ||
            currentType == 'administrador';
      }

      CompanyProfileModel? profile;

      if (widget.companyId != null) {
        profile = await _service.getPublicCompanyById(widget.companyId!);

        if (_hasCompanyRole || _isAdmin) {
          final myProfile = await _service.getMyCompanyProfile();
          _canEdit =
              profile != null &&
              (_isAdmin ||
                  myProfile?.id == profile.id ||
                  profile.userId == _viewerId);
        } else {
          _canEdit = false;
        }

        _canCreate = false;
      } else if (_hasCompanyRole || _isAdmin) {
        profile = await _service.getMyCompanyProfile();

        if (profile == null) {
          _canCreate = _hasCompanyRole || (_isAdmin && widget.userId != null);
          _canEdit = false;
        } else {
          _canEdit = true;
          _canCreate = false;
        }
      }

      if (!mounted) return;

      setState(() {
        _company = profile;
        _syncForm(profile);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showError('No se pudo cargar el perfil empresarial.');
    }
  }

  void _syncForm(CompanyProfileModel? profile) {
    _companyNameCtrl.text = profile?.companyName ?? '';
    _descriptionCtrl.text = profile?.description ?? '';
    _industryCtrl.text = profile?.industry ?? '';
    _locationCtrl.text = profile?.location ?? '';
  }

  void _showError(String message) {
    if (!mounted) return;

    Dialogs.showSimpleDialog(
      context,
      title: 'Error',
      message: message,
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  Future<void> _openProfileForm() async {
    _syncForm(_company);
    final companyBeforeOpen = _company;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> saveFromModal() async {
              if (_saving) return;
              if (!_formKey.currentState!.validate()) return;

              setModalState(() => _saving = true);

              try {
                final companyName = _companyNameCtrl.text.trim();
                final description = _descriptionCtrl.text.trim();
                final industry = _industryCtrl.text.trim();
                final location = _locationCtrl.text.trim();

                final saved = companyBeforeOpen == null
                    ? await _service.createCompanyProfile(
                        companyName: companyName,
                        description: description,
                        industry: industry,
                        location: location,
                        userId: widget.userId,
                      )
                    : await _service.updateCompanyProfile(
                        companyBeforeOpen.copyWith(
                          companyName: companyName,
                          description: description,
                          industry: industry,
                          location: location,
                        ),
                      );

                if (!mounted) return;
                setState(() {
                  _company = saved;
                  _canEdit = true;
                  _canCreate = false;
                });

                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }

                Dialogs.showSimpleDialog(
                  this.context,
                  title:
                      companyBeforeOpen == null
                          ? 'Perfil creado'
                          : 'Perfil actualizado',
                  message: 'La información empresarial se guardó correctamente.',
                  color: Style.getPrimaryColor(),
                  icon: Icons.check_circle_outline_rounded,
                );

                await _loadData();
              } catch (e) {
                if (!mounted) return;
                setModalState(() => _saving = false);
                _showError(e.toString().replaceFirst('Exception: ', ''));
              } finally {
                if (mounted) {
                  setState(() => _saving = false);
                }
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyBeforeOpen == null
                              ? 'Crear perfil empresarial'
                              : 'Editar perfil empresarial',
                          style: Style.getHeaderTwo(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          controller: _companyNameCtrl,
                          label: 'Nombre comercial',
                          enabled: !_saving,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'Ingresa el nombre comercial';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10.h),
                        CustomInputField(
                          controller: _industryCtrl,
                          label: 'Industria',
                          enabled: !_saving,
                        ),
                        SizedBox(height: 10.h),
                        CustomInputField(
                          controller: _locationCtrl,
                          label: 'Ubicación',
                          enabled: !_saving,
                        ),
                        SizedBox(height: 10.h),
                        CustomInputField(
                          controller: _descriptionCtrl,
                          label: 'Descripción',
                          maxLines: 4,
                          enabled: !_saving,
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          child: CustomWidgets.button(
                            onTap: _saving ? () {} : saveFromModal,
                            color: Style.getPrimaryColor(),
                            child: _saving
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Style.white,
                                    ),
                                  )
                                : Text(
                                    companyBeforeOpen == null
                                        ? 'Crear perfil'
                                        : 'Guardar cambios',
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProfile() async {
    final company = _company;
    if (company == null || !_canEdit) return;

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
      await _service.deleteCompanyProfile(company.id);
      if (!mounted) return;
      setState(() {
        _company = null;
        _canEdit = false;
        _canCreate = _hasCompanyRole || (_isAdmin && widget.userId != null);
      });
      Dialogs.showSimpleDialog(
        context,
        title: 'Perfil eliminado',
        message: 'El perfil empresarial fue eliminado correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _contactCompany() async {
    final company = _company;
    if (company == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: company.companyName,
      avatarSeed: company.companyName,
      subtitle: company.location,
      relatedEntityId: company.id,
      relatedEntityType: 'company',
    );

    if (!mounted) return;

    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  @override
  Widget build(BuildContext context) {
    final company = _company;
    final canShowFloatingContact =
        !_loading && company != null && _hasFreelancerRole && !_canEdit;

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      floatingActionButton: canShowFloatingContact
          ? FloatingActionButton.extended(
              onPressed: _contactCompany,
              backgroundColor: Style.getPrimaryColor(),
              icon: Icon(Icons.chat_bubble_rounded, color: Style.white),
              label: Text(
                'Contactar',
                style: Style.getTextStyle(
                  color: Style.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          if (_loading)
            Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          else if (company != null)
            RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 300.h,
                    backgroundColor: Style.getBackgroundColor(),
                    surfaceTintColor: Style.transparent,
                    elevation: 0,
                    titleSpacing: 0,
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Style.white,
                      ),
                    ),
                    title: Text(
                      'Perfil empresarial',
                      style: Style.getHeaderTwo(
                        color: Style.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: _buildHeader(company),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        Style.horizontalPadding.w,
                        16.h,
                        Style.horizontalPadding.w,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_canEdit) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomWidgets.button(
                                    onTap: _openProfileForm,
                                    color: Style.getPrimaryColor(),
                                    child: Text(
                                      'Editar perfil',
                                      style: Style.getHeaderThree(
                                        color: Style.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: CustomWidgets.button(
                                    onTap:
                                        _actionLoading ? () {} : _deleteProfile,
                                    color: Style.getErrorColor(),
                                    backgroundColor: Style.getErrorColor()
                                        .withValues(alpha: .08),
                                    isFilled: false,
                                    withBorder: true,
                                    elevation: false,
                                    child: Text(
                                      'Eliminar perfil',
                                      style: Style.getHeaderThree(
                                        color: Style.getErrorColor(),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18.h),
                          ],
                          _sectionCard(
                            title: 'Información principal',
                            subtitle:
                                'Resumen comercial y operativo de la empresa.',
                            child: _mainInfo(company),
                          ),
                          SizedBox(height: 18.h),
                          _sectionCard(
                            title: 'Descripción',
                            subtitle:
                                'Contexto empresarial y propuesta de valor.',
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                _textOrFallback(
                                  company.description,
                                  'Esta empresa aún no agregó una descripción.',
                                ),
                                style: Style.getTextStyle(
                                  color: Style.getTextColor(),
                                ).copyWith(height: 1.45),
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          _sectionCard(
                            title: 'Datos de la cuenta',
                            subtitle:
                                'Información del propietario y trazabilidad del perfil.',
                            child: Column(
                              children: [
                                _infoRow(
                                  icon: Icons.person_rounded,
                                  title: 'Propietario',
                                  value: _textOrFallback(
                                    company.ownerName,
                                    'Sin definir',
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                _infoRow(
                                  icon: Icons.email_rounded,
                                  title: 'Correo',
                                  value: _textOrFallback(
                                    company.ownerEmail,
                                    'Sin definir',
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                _infoRow(
                                  icon: Icons.phone_rounded,
                                  title: 'Teléfono',
                                  value: _textOrFallback(
                                    company.ownerPhone,
                                    'Sin definir',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height:
                                (_hasFreelancerRole && !_canEdit) ? 92.h : 24.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * .18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 42.w,
                          color: Style.getPrimaryColor(),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _canCreate
                              ? 'Aún no tienes perfil empresarial.'
                              : 'No se encontró información empresarial para mostrar.',
                          textAlign: TextAlign.center,
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_canCreate) ...[
                          SizedBox(height: 14.h),
                          CustomWidgets.button(
                            onTap: _openProfileForm,
                            color: Style.getPrimaryColor(),
                            child: Text(
                              'Crear perfil empresarial',
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
                ],
              ),
            ),
          if (!_loading && company == null)
            Positioned(
              left: 8.w,
              top: MediaQuery.of(context).padding.top + 4.h,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
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
      ),
    );
  }

  Widget _buildHeader(CompanyProfileModel company) {
    final avatarUrl = company.photoUrl.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (avatarUrl.isNotEmpty)
          CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover)
        else
          Image.asset(Assets.profileBg, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Style.getBackgroundColor().withValues(alpha: .06),
                Style.getPrimaryColor().withValues(alpha: .55),
                Style.getBackgroundColor().withValues(alpha: .96),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _avatar(company),
                SizedBox(height: 14.h),
                Text(
                  _textOrFallback(company.companyName, 'Empresa'),
                  textAlign: TextAlign.center,
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _textOrFallback(company.industry, 'Industria por definir'),
                  textAlign: TextAlign.center,
                  style: Style.getTextStyle(
                    color: Style.white.withValues(alpha: .92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _topBadge(
                      Icons.star_rounded,
                      company.averageRate.toStringAsFixed(1),
                    ),
                    _topBadge(
                      Icons.place_rounded,
                      _textOrFallback(company.location, 'Sin ubicación'),
                    ),
                    _topBadge(
                      Icons.verified_user_rounded,
                      _textOrFallback(company.ownerRole, 'empresa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(CompanyProfileModel company) {
    final avatarUrl = company.photoUrl.trim();
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Style.white.withValues(alpha: .2),
        boxShadow: [
          BoxShadow(
            color: Style.black.withValues(alpha: .2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 46.r,
        backgroundColor: Style.getPrimaryColor().withValues(alpha: .14),
        child: ClipOval(
          child: avatarUrl.isEmpty
              ? Center(
                  child: Text(
                    company.initials,
                    style: Style.getHeaderTwo(
                      color: Style.getPrimaryColor(),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 92.w,
                  height: 92.w,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _topBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .12),
        borderRadius: Style.getCircularBorderRadius(100),
        border: Border.all(color: Style.white.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Style.white, size: 15.w),
          SizedBox(width: 6.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 160.w),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Style.getTextStyle(
                color: Style.white,
                fontWeight: FontWeight.w600,
                fontSize: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Style.getCardColor(),
        elevation: 5,
        shadowColor: Style.getShadowColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                ).copyWith(height: 1.4),
              ),
              SizedBox(height: 16.h),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainInfo(CompanyProfileModel company) {
    return Column(
      children: [
        _infoRow(
          icon: Icons.business_rounded,
          title: 'Empresa',
          value: _textOrFallback(company.companyName, 'Sin definir'),
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.category_rounded,
          title: 'Industria',
          value: _textOrFallback(company.industry, 'Sin definir'),
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.place_rounded,
          title: 'Ubicación',
          value: _textOrFallback(company.location, 'Sin definir'),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Style.getObscureTextColor().withValues(alpha: .15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  title,
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
        ],
      ),
    );
  }

  String _textOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value.trim();
  }

}
