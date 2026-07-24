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
      final userRaw = prefs.getString(Constants.userEmailKey);

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

  Future<void> _saveProfile() async {
    if (_saving) return;
    if (!(_canEdit || _canCreate)) return;
    if (!_formKey.currentState!.validate()) return;

    final isNewProfile = _company == null;

    setState(() => _saving = true);

    try {
      final companyName = _companyNameCtrl.text.trim();
      final description = _descriptionCtrl.text.trim();
      final industry = _industryCtrl.text.trim();
      final location = _locationCtrl.text.trim();

      final saved = isNewProfile
          ? await _service.createCompanyProfile(
              companyName: companyName,
              description: description,
              industry: industry,
              location: location,
              userId: widget.userId,
            )
          : await _service.updateCompanyProfile(
              _company!.copyWith(
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
        _saving = false;
        _syncForm(saved);
      });

      Dialogs.showSimpleDialog(
        context,
        title: isNewProfile ? 'Perfil creado' : 'Perfil actualizado',
        message: 'La información empresarial se guardó correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deleteProfile() async {
    final company = _company;
    if (company == null || !_canEdit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Style.getCardColor(),
        title: Text(
          'Eliminar perfil',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Este cambio eliminará lógicamente el perfil empresarial.',
          style: Style.getTextStyle(color: Style.getTextColor()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: Style.getTextStyle(color: Style.getObscureTextColor()),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Eliminar',
              style: Style.getTextStyle(color: Style.getErrorColor()),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);

    try {
      await _service.deleteCompanyProfile(company.id);
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
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

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Style.getTextColor(),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
              ),
              if (company != null && _canEdit)
                IconButton(
                  onPressed: _saving ? null : _deleteProfile,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Style.getErrorColor(),
                  ),
                ),
            ],
            title: Text(
              'Perfil de empresa',
              style: Style.getHeaderTwo(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CustomWidgets.mProgress(Style.getPrimaryColor()),
              ),
            )
          else if (company == null && !(_canCreate || _canEdit))
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Style.horizontalPadding.w,
                  ),
                  child: Text(
                    'No se encontró información empresarial para mostrar.',
                    textAlign: TextAlign.center,
                    style: Style.getTextStyle(
                      color: Style.getObscureTextColor(),
                    ),
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  10.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _headerCard(company),
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
                child: _overviewCard(company),
              ),
            ),
            if (company != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    16.h,
                    Style.horizontalPadding.w,
                    0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomWidgets.button(
                      onTap: _contactCompany,
                      color: Style.getPrimaryColor(),
                      child: Text(
                        'Contactar empresa',
                        style: Style.getHeaderThree(
                          color: Style.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_canEdit || _canCreate)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    18.h,
                    Style.horizontalPadding.w,
                    24.h,
                  ),
                  child: _formCard(company),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _headerCard(CompanyProfileModel? company) {
    final displayName = company?.companyName.isNotEmpty == true
        ? company!.companyName
        : 'Perfil empresarial';
    final ownerName = company?.ownerName.trim().isNotEmpty == true
        ? company!.ownerName
        : 'Empresa';

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          colors: [
            Style.getPrimaryColor(),
            Style.getPrimaryColor().darken(.18),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Style.getPrimaryColor().withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32.w,
            backgroundColor: Style.white.withValues(alpha: .16),
            child: Text(
              company?.initials ?? 'WL',
              style: Style.getHeaderTwo(
                color: Style.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  company?.industry.isNotEmpty == true
                      ? company!.industry
                      : 'Industria por definir',
                  style: Style.getTextStyle(
                    color: Style.white.withValues(alpha: .88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _headerChip(
                      Icons.location_on_rounded,
                      company?.location.isNotEmpty == true
                          ? company!.location
                          : 'Sin ubicación',
                    ),
                    _headerChip(
                      Icons.star_rounded,
                      company == null
                          ? '0.0'
                          : company.averageRate.toStringAsFixed(1),
                    ),
                    _headerChip(Icons.person_rounded, ownerName),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: Style.white.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: Style.white),
          SizedBox(width: 5.w),
          Text(
            label,
            style: Style.getTextStyle(
              color: Style.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(CompanyProfileModel? company) {
    final description = company?.description.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor().withValues(alpha: .12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identidad pública',
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            description.isNotEmpty
                ? description
                : 'Este perfil es la identidad pública de la empresa dentro de WorkLink y sirve como base para vacantes y reputación.',
            style: Style.getTextStyle(
              color: Style.getTextColor(),
            ).copyWith(height: 1.5),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _infoPill(
                'Industria',
                company?.industry.isNotEmpty == true
                    ? company!.industry
                    : 'Sin definir',
              ),
              _infoPill(
                'Ubicación',
                company?.location.isNotEmpty == true
                    ? company!.location
                    : 'Sin definir',
              ),
              _infoPill(
                'Promedio',
                company == null
                    ? '0.0'
                    : company.averageRate.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Style.getPrimaryColor().withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Style.getTextStyle(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            style: Style.getTextStyle(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(CompanyProfileModel? company) {
    final isNewProfile = company == null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor().withValues(alpha: .12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNewProfile
                  ? 'Crear perfil empresarial'
                  : 'Editar perfil empresarial',
              style: Style.getHeaderThree(
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
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: CustomWidgets.button(
                    onTap: _saving ? () {} : _saveProfile,
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
                            isNewProfile ? 'Crear perfil' : 'Guardar cambios',
                            style: Style.getHeaderThree(
                              color: Style.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (_isAdmin && widget.userId != null)
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  'Administrando perfil para el usuario ID ${widget.userId}.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
