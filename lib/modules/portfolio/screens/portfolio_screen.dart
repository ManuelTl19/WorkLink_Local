import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_availability_model.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancer_availability_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/portfolio/portfolio.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class PortfolioScreen extends StatefulWidget {
  final FreelancerModel freelancer;
  final bool forceOwner;
  final VoidCallback? onEditProfile;
  final VoidCallback? onDeleteProfile;
  final bool showContactFab;
  final VoidCallback? onContact;

  const PortfolioScreen({
    super.key,
    required this.freelancer,
    this.forceOwner = false,
    this.onEditProfile,
    this.onDeleteProfile,
    this.showContactFab = false,
    this.onContact,
  });

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioService _service = PortfolioService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isActionLoading = false;
  bool _isOwner = false;
  PortfolioModel? _portfolio;
  String? _activeAvailabilityLabel;

  @override
  void initState() {
    super.initState();
    _loadViewerAndPortfolio();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadViewerAndPortfolio() async {
    await _loadViewer();
    await Future.wait([_loadPortfolio(), _loadAvailabilityStatus()]);
  }

  Future<void> _loadViewer() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(Constants.userEmailKey);
    if (userRaw == null || userRaw.isEmpty) return;

    final user = UserModel.fromJson(jsonDecode(userRaw));
    _isOwner =
        widget.forceOwner ||
        (widget.freelancer.userId != null &&
            widget.freelancer.userId == user.id);
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    final portfolio = await _service.getPortfolioByFreelancerId(
      widget.freelancer.id,
    );
    if (!mounted) return;
    setState(() {
      _portfolio = portfolio;
      _isLoading = false;
    });
  }

  Future<void> _loadAvailabilityStatus() async {
    final freelancerId = widget.freelancer.id;
    if (freelancerId == null || freelancerId <= 0) return;

    try {
      final items = await FreelancerAvailabilityService.getByFreelancer(
        freelancerId,
      );
      if (!mounted) return;
      setState(() {
        _activeAvailabilityLabel = _resolveAvailabilityLabel(items);
      });
    } catch (_) {
      // Keep current fallback values when availability endpoint is unavailable.
    }
  }

  Future<void> _openContactChat() async {
    final freelancerId = widget.freelancer.id;
    if (freelancerId == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: widget.freelancer.fullName,
      avatarSeed: widget.freelancer.fullName,
      subtitle: widget.freelancer.specialty,
      avatarUrl: widget.freelancer.avatarUrl,
      relatedEntityId: freelancerId,
      relatedEntityType: 'freelancer',
    );

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  String? _resolveAvailabilityLabel(List<FreelancerAvailabilityModel> items) {
    if (items.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeItems = items.where((item) {
      final start = DateTime(
        item.startDate.year,
        item.startDate.month,
        item.startDate.day,
      );
      final end = DateTime(
        item.endDate.year,
        item.endDate.month,
        item.endDate.day,
      );
      return !today.isBefore(start) && !today.isAfter(end);
    }).toList();

    if (activeItems.isEmpty) return null;

    int priority(String status) {
      switch (status.toLowerCase()) {
        case 'vacation':
          return 3;
        case 'busy':
          return 2;
        case 'available':
          return 1;
        default:
          return 0;
      }
    }

    activeItems.sort(
      (a, b) => priority(b.status).compareTo(priority(a.status)),
    );

    final selectedStatus = activeItems.first.status.toLowerCase();
    if (selectedStatus == 'vacation') return 'Vacaciones';
    if (selectedStatus == 'busy') return 'Ocupado';
    return 'Disponible';
  }

  String get _availabilityLabel {
    if (_hasText(_activeAvailabilityLabel)) {
      return _activeAvailabilityLabel!.trim();
    }

    if (_hasText(widget.freelancer.availability)) {
      return widget.freelancer.availability!.trim();
    }

    if (_hasText(_portfolio?.availabilityNote)) {
      return _portfolio!.availabilityNote.trim();
    }

    return widget.freelancer.available ? 'Disponible' : 'No disponible';
  }

  @override
  Widget build(BuildContext context) {
    final canShowContactFab = widget.showContactFab && !_isOwner;
    final contactAction = widget.onContact ?? _openContactChat;

    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        floatingActionButton: canShowContactFab
            ? FloatingActionButton.extended(
                onPressed: contactAction,
                backgroundColor: Style.getPrimaryColor(),
                icon: Icon(Icons.chat_bubble_rounded, color: Style.white),
                label: Text(
                  MultiLanguages.of(context)?.translate('contact') ?? 'Contactar',
                  style: Style.getTextStyle(
                    color: Style.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: RefreshIndicator(
          onRefresh: _loadViewerAndPortfolio,
          child: CustomScrollView(
            controller: _scrollController,
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
                  'Perfil profesional',
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeader(context),
                ),
              ),
              if (_isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                  ),
                )
              else if (_portfolio == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No se encontró el portafolio.',
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    16.h,
                    Style.horizontalPadding.w,
                    canShowContactFab ? 96.h : 24.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_isOwner &&
                          (widget.onEditProfile != null ||
                              widget.onDeleteProfile != null)) ...[
                        Row(
                          children: [
                            if (widget.onEditProfile != null)
                              Expanded(
                                child: CustomWidgets.button(
                                  onTap: widget.onEditProfile!,
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
                            if (widget.onEditProfile != null &&
                                widget.onDeleteProfile != null)
                              SizedBox(width: 10.w),
                            if (widget.onDeleteProfile != null)
                              Expanded(
                                child: CustomWidgets.button(
                                  onTap: widget.onDeleteProfile!,
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
                            'Resumen del freelancer y su contexto profesional.',
                        child: _mainInfo(),
                      ),
                      SizedBox(height: 18.h),
                      _sectionCard(
                        title: 'Acerca de mí',
                        subtitle:
                            'Descripción profesional y enfoque de trabajo.',
                        child: Text(
                          _portfolio!.about,
                          style: Style.getTextStyle(
                            color: Style.getTextColor(),
                          ).copyWith(height: 1.45),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _sectionCard(
                        title: 'Habilidades',
                        subtitle: 'Tecnologías y capacidades destacadas.',
                        child: Builder(
                          builder: (context) {
                            final filteredSkills = _skillsWithoutLanguages(
                              _portfolio!.skills,
                              widget.freelancer.languages,
                            );
                            final skillsToShow = filteredSkills.isNotEmpty
                                ? filteredSkills
                                : _portfolio!.skills;

                            return Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: skillsToShow
                                  .map((skill) => _skillChip(skill))
                                  .toList(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 18.h),
                      _sectionCard(
                        title: 'Información profesional',
                        subtitle:
                            'Datos relevantes para contratación y contexto laboral.',
                        child: Column(
                          children: [
                            _infoRow(
                              icon: Icons.sell_rounded,
                              title: 'Tipo de tarifa',
                              value: _rateTypeLabel(widget.freelancer.rateType),
                            ),
                            SizedBox(height: 10.h),
                            if (!_isNegotiableRateType(
                              widget.freelancer.rateType,
                            )) ...[
                              _infoRow(
                                icon: Icons.schedule_rounded,
                                title: _rateTitleByType(
                                  widget.freelancer.rateType,
                                ),
                                value: _formattedRate(widget.freelancer),
                              ),
                              SizedBox(height: 10.h),
                            ],
                            if (_hasText(widget.freelancer.workMode)) ...[
                              _infoRow(
                                icon: Icons.lan_rounded,
                                title: 'Modalidad',
                                value: _workModeLabel(
                                  widget.freelancer.workMode,
                                ),
                              ),
                              SizedBox(height: 10.h),
                            ],
                            if (_hasText(widget.freelancer.serviceArea)) ...[
                              _infoRow(
                                icon: Icons.map_outlined,
                                title: 'Area de servicio',
                                value: widget.freelancer.serviceArea!.trim(),
                              ),
                              SizedBox(height: 10.h),
                            ],
                            _infoRow(
                              icon: Icons.work_history_rounded,
                              title: 'Experiencia',
                              value: _hasText(widget.freelancer.experience)
                                  ? widget.freelancer.experience!.trim()
                                  : _portfolio!.experience,
                            ),
                            SizedBox(height: 10.h),
                            _infoRow(
                              icon: Icons.event_available_rounded,
                              title: 'Disponibilidad',
                              value: _availabilityLabel,
                            ),
                          ],
                        ),
                      ),
                      if (widget.freelancer.languages.isNotEmpty) ...[
                        SizedBox(height: 18.h),
                        _sectionCard(
                          title: 'Idiomas',
                          subtitle: 'Idiomas de comunicación del freelancer.',
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: widget.freelancer.languages
                                .where((lang) => lang.trim().isNotEmpty)
                                .map((lang) => _skillChip(lang.trim()))
                                .toList(),
                          ),
                        ),
                      ],
                      if (_hasProfessionalLinks(widget.freelancer)) ...[
                        SizedBox(height: 18.h),
                        _sectionCard(
                          title: 'Enlaces profesionales',
                          subtitle:
                              'Canales y portafolios para conocer más trabajo.',
                          child: Column(
                            children: [
                              if (_hasText(widget.freelancer.website)) ...[
                                _infoRow(
                                  icon: Icons.language_rounded,
                                  title: 'Website',
                                  value: widget.freelancer.website!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.website!,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                              if (_hasText(widget.freelancer.portfolioUrl)) ...[
                                _infoRow(
                                  icon: Icons.folder_open_rounded,
                                  title: 'Portafolio',
                                  value: widget.freelancer.portfolioUrl!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.portfolioUrl!,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                              if (_hasText(widget.freelancer.linkedin)) ...[
                                _infoRow(
                                  icon: Icons.business_center_rounded,
                                  title: 'LinkedIn',
                                  value: widget.freelancer.linkedin!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.linkedin!,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                              if (_hasText(widget.freelancer.github)) ...[
                                _infoRow(
                                  icon: Icons.code_rounded,
                                  title: 'GitHub',
                                  value: widget.freelancer.github!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.github!,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                              if (_hasText(widget.freelancer.facebook)) ...[
                                _infoRow(
                                  icon: Icons.facebook_rounded,
                                  title: 'Facebook',
                                  value: widget.freelancer.facebook!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.facebook!,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                              if (_hasText(widget.freelancer.instagram))
                                _infoRow(
                                  icon: Icons.camera_alt_rounded,
                                  title: 'Instagram',
                                  value: widget.freelancer.instagram!.trim(),
                                  onTap: () => _openExternalLink(
                                    widget.freelancer.instagram!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),
                      _sectionCard(
                        title: 'Portafolio',
                        subtitle: 'Proyectos recientes del freelancer.',
                        trailing: _isOwner
                            ? TextButton.icon(
                                onPressed: _isActionLoading
                                    ? null
                                    : () => _openProjectForm(),
                                icon: Icon(
                                  Icons.add_rounded,
                                  color: Style.getPrimaryColor(),
                                  size: 16.w,
                                ),
                                label: Text(
                                  'Agregar',
                                  style: Style.getTextStyle(
                                    color: Style.getPrimaryColor(),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                        child: SizedBox(
                          height: 255.h,
                          child: _portfolio!.projects.isEmpty
                              ? Center(
                                  child: Text(
                                    _isOwner
                                        ? 'Aún no tienes proyectos. Agrega el primero.'
                                        : 'Este freelancer aún no ha publicado proyectos.',
                                    textAlign: TextAlign.center,
                                    style: Style.getTextStyle(
                                      color: Style.getObscureTextColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _portfolio!.projects.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(width: 12.w),
                                  itemBuilder: (context, index) {
                                    final project = _portfolio!.projects[index];
                                    return PortfolioProjectCard(
                                      project: project,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          Transitions.slideUpTransition(
                                            PortfolioProjectDetailScreen(
                                              freelancer: widget.freelancer,
                                              portfolio: _portfolio!,
                                              project: project,
                                            ),
                                          ),
                                        );
                                      },
                                      onEdit: _isOwner
                                          ? () => _openProjectForm(
                                              project: project,
                                            )
                                          : null,
                                      onDelete: _isOwner
                                          ? () => _deleteProject(project)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ),
                      SizedBox(height: 22.h),
                    ]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final freelancer = widget.freelancer;
    final avatarUrl = freelancer.avatarUrl.trim();

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
                _avatar(),
                SizedBox(height: 14.h),
                Text(
                  freelancer.fullName,
                  textAlign: TextAlign.center,
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  freelancer.specialty,
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
                      (freelancer.rating ?? 0).toStringAsFixed(1),
                    ),
                    _topBadge(Icons.place_rounded, freelancer.location),
                    _topBadge(
                      Icons.event_available_rounded,
                      _availabilityLabel,
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

  Widget _avatar() {
    final avatarUrl = widget.freelancer.avatarUrl.trim();
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
                    widget.freelancer.fullName
                        .split(' ')
                        .where((part) => part.trim().isNotEmpty)
                        .map((part) => part[0])
                        .take(2)
                        .join()
                        .toUpperCase(),
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
    Widget? trailing,
  }) {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

  String _normalizeToken(String value) => value.trim().toLowerCase();

  List<String> _skillsWithoutLanguages(
    List<String> skills,
    List<String> languages,
  ) {
    final languageSet = languages
        .where((item) => item.trim().isNotEmpty)
        .map(_normalizeToken)
        .toSet();

    return skills
        .where((item) => item.trim().isNotEmpty)
        .where((item) => !languageSet.contains(_normalizeToken(item)))
        .toList();
  }

  bool _isNegotiableRateType(String? rateType) {
    final value = (rateType ?? '').trim().toLowerCase();
    return value == 'negotiable' || value == 'negociable';
  }

  String _rateTypeLabel(String? rateType) {
    final value = (rateType ?? '').trim().toLowerCase();
    if (value == 'hourly' || value == 'por hora') return 'Por hora';
    if (value == 'project' || value == 'por proyecto') return 'Por proyecto';
    return 'Negociable';
  }

  String _rateTitleByType(String? rateType) {
    final value = (rateType ?? '').trim().toLowerCase();
    if (value == 'project' || value == 'por proyecto') {
      return 'Tarifa por proyecto';
    }
    return 'Tarifa por hora';
  }

  String _formattedRate(FreelancerModel freelancer) {
    if (freelancer.hourlyRate <= 0) return 'No especificada';

    final value = freelancer.hourlyRate.toStringAsFixed(
      freelancer.hourlyRate % 1 == 0 ? 0 : 2,
    );
    if ((freelancer.rateType ?? '').trim().toLowerCase() == 'project') {
      return '4$value / proyecto';
    }
    return '4$value / h';
  }

  String _workModeLabel(String? workMode) {
    final value = (workMode ?? '').trim().toLowerCase();
    if (value == 'remote' || value == 'remoto') return 'Remoto';
    if (value == 'on_site' || value == 'onsite' || value == 'presencial') {
      return 'Presencial';
    }
    if (value == 'hybrid' || value == 'hibrido' || value == 'hibrida') {
      return 'Hibrido';
    }
    if (value == 'home_service' || value == 'servicio a domicilio') {
      return 'Servicio a domicilio';
    }
    return workMode?.trim().isNotEmpty == true
        ? workMode!.trim()
        : 'No especificada';
  }

  bool _hasProfessionalLinks(FreelancerModel freelancer) {
    return _hasText(freelancer.website) ||
        _hasText(freelancer.portfolioUrl) ||
        _hasText(freelancer.linkedin) ||
        _hasText(freelancer.github) ||
        _hasText(freelancer.facebook) ||
        _hasText(freelancer.instagram);
  }

  Uri? _normalizeExternalUri(String rawUrl) {
    final text = rawUrl.trim();
    if (text.isEmpty) return null;

    final parsed = Uri.tryParse(text);
    if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
      return parsed;
    }

    final withHttps = Uri.tryParse('https://$text');
    if (withHttps != null && withHttps.host.isNotEmpty) {
      return withHttps;
    }

    return null;
  }

  Future<void> _openExternalLink(String rawUrl) async {
    final uri = _normalizeExternalUri(rawUrl);
    if (uri == null) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Enlace inválido',
        message: 'No se puede abrir este enlace.',
        color: Style.getErrorColor(),
        icon: Icons.link_off_rounded,
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !mounted) return;

    Dialogs.showSimpleDialog(
      context,
      title: 'No se pudo abrir',
      message: 'No fue posible abrir el enlace en este dispositivo.',
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  Widget _mainInfo() {
    return Column(
      children: [
        _infoRow(
          icon: Icons.badge_rounded,
          title: 'Nombre',
          value: widget.freelancer.fullName,
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.work_outline_rounded,
          title: 'Especialidad',
          value: widget.freelancer.specialty,
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.star_rounded,
          title: 'Calificación',
          value: (widget.freelancer.rating ?? 0).toStringAsFixed(1),
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.place_rounded,
          title: 'Ubicación',
          value: widget.freelancer.location,
        ),
        SizedBox(height: 10.h),
        _infoRow(
          icon: Icons.event_available_rounded,
          title: 'Disponibilidad',
          value: _availabilityLabel,
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: Style.getCircularBorderRadius(18),
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Style.getPrimaryColor().withValues(alpha: .12),
              borderRadius: Style.getCircularBorderRadius(100),
            ),
            child: Icon(icon, color: Style.getPrimaryColor(), size: 16.w),
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
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: Style.getTextStyle(
                    color: onTap != null
                        ? Style.getPrimaryColor()
                        : Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 8.w),
            Icon(
              Icons.open_in_new_rounded,
              size: 16.w,
              color: Style.getPrimaryColor(),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: Style.getCircularBorderRadius(18),
      child: card,
    );
  }

  Widget _skillChip(String skill) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: Style.getPrimaryColor().withValues(alpha: .1),
        borderRadius: Style.getCircularBorderRadius(100),
        border: Border.all(
          color: Style.getPrimaryColor().withValues(alpha: .18),
        ),
      ),
      child: Text(
        skill,
        style: Style.getTextStyle(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _openProjectForm({ProjectModel? project}) async {
    if (!_isOwner || _portfolio == null) {
      return;
    }

    final pushedResult = await Navigator.of(context).push(
      Transitions.slideUpTransition(
        _ProjectFormDialog(initialProject: project),
      ),
    );
    final result = pushedResult is ProjectModel ? pushedResult : null;

    if (result == null) {
      return;
    }

    final freelancerId = widget.freelancer.id ?? _portfolio!.freelancerId;

    setState(() => _isActionLoading = true);
    try {
      String successMessage = 'Proyecto creado correctamente.';

      if (project == null) {
        await _service.createProject(
          freelancerId: freelancerId > 0 ? freelancerId : null,
          project: result,
        );
      } else {
        final originalImage = project.imageUrl.trim();
        final updatedImage = result.imageUrl.trim();
        final titleChanged = project.title.trim() != result.title.trim();
        final descriptionChanged =
            project.description.trim() != result.description.trim();
        final projectUrlChanged =
            project.projectUrl.trim() != result.projectUrl.trim();
        final textChanged =
            titleChanged || descriptionChanged || projectUrlChanged;

        var imageRemoved = false;
        var imageUpdated = false;

        await _service.updateProject(projectId: project.id, project: result);

        if (updatedImage.isEmpty && originalImage.isNotEmpty) {
          await _service.deleteProjectImage(project.id);
          imageRemoved = true;
        } else if (updatedImage.isNotEmpty &&
            !updatedImage.toLowerCase().startsWith('http')) {
          await _service.updateProjectImage(
            projectId: project.id,
            imagePath: updatedImage,
          );
          imageUpdated = true;
        }

        if (textChanged && (imageUpdated || imageRemoved)) {
          successMessage = 'Proyecto e imagen actualizados correctamente.';
        } else if (imageRemoved) {
          successMessage = 'Imagen del proyecto eliminada correctamente.';
        } else if (imageUpdated) {
          successMessage = 'Imagen del proyecto actualizada correctamente.';
        } else {
          successMessage = 'Proyecto actualizado correctamente.';
        }
      }

      await _loadPortfolio();
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Éxito',
        message: successMessage,
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'No se pudo guardar',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    if (!_isOwner) {
      return;
    }

    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: 'Eliminar proyecto',
      message:
          '¿Deseas eliminar ${project.title}? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      icon: Icons.delete_outline_rounded,
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await _service.deleteProject(project.id);
      await _loadPortfolio();
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Proyecto eliminado',
        message: 'El proyecto se eliminó correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'No se pudo eliminar',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final ProjectModel? initialProject;

  const _ProjectFormDialog({this.initialProject});

  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  static const int _maxImageBytes = 2 * 1024 * 1024;
  static const List<int> _compressionQualities = <int>[85, 75, 65, 55, 45, 35];

  final _detailsFormKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _projectUrlController;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialProject?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialProject?.description ?? '',
    );
    _projectUrlController = TextEditingController(
      text: widget.initialProject?.projectUrl ?? '',
    );

    final initialImage = widget.initialProject?.imageUrl.trim() ?? '';
    if (initialImage.isNotEmpty) {
      _selectedImagePath = initialImage;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialProject != null;
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Style.getTextColor(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      isEditing ? 'Editar proyecto' : 'Nuevo proyecto',
                      textAlign: TextAlign.center,
                      style: Style.getHeaderThree(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 12.h),
                child: Form(
                  key: _detailsFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildField(
                        controller: _titleController,
                        label: 'Titulo',
                        hint: 'Ej. App para gestión de inventario',
                        requiredField: true,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'Campo requerido';
                          if (text.length < 3) return 'Minimo 3 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Descripcion',
                        hint:
                            'Describe el problema, solución y resultado del proyecto.',
                        minLines: 3,
                        maxLines: 5,
                        requiredField: true,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'Campo requerido';
                          if (text.length < 10) return 'Minimo 10 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      _buildField(
                        controller: _projectUrlController,
                        label: 'URL de proyecto',
                        hint: 'https://mi-proyecto.com (opcional)',
                        keyboardType: TextInputType.url,
                        validator: (_) => null,
                      ),
                      SizedBox(height: 14.h),
                      _buildImagePicker(),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
              color: Style.getBackgroundColor(),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(
                          color: Style.getPrimaryColor().withValues(alpha: .45),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: Style.getTextStyle(
                          color: Style.getPrimaryColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final valid =
                            _detailsFormKey.currentState?.validate() ?? false;
                        if (!valid) return;

                        Navigator.pop(
                          context,
                          ProjectModel(
                            id: widget.initialProject?.id ?? 0,
                            freelancerId: widget.initialProject?.freelancerId,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            imageUrl:
                                _selectedImagePath ??
                                widget.initialProject?.imageUrl ??
                                '',
                            projectUrl: _projectUrlController.text.trim(),
                            dateLabel: widget.initialProject?.dateLabel ?? '',
                            fullDescription: _descriptionController.text.trim(),
                            technologies:
                                widget.initialProject?.technologies ?? const [],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Style.getPrimaryColor(),
                        foregroundColor: Style.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Guardar' : 'Crear',
                        style: Style.getTextStyle(
                          color: Style.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
    bool requiredField = false,
  }) {
    return CustomInputField(
      controller: controller,
      label: label,
      hintText: hint,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      requiredField: requiredField,
    );
  }

  Widget _buildImagePicker() {
    final imagePath = _selectedImagePath ?? '';
    final hasLocalImage =
        imagePath.isNotEmpty && !imagePath.toLowerCase().startsWith('http');
    final hasRemoteImage =
        imagePath.isNotEmpty && imagePath.toLowerCase().startsWith('http');
    final hasSelectedImage = imagePath.isNotEmpty;

    Widget preview;
    if (_selectedImageBytes != null) {
      preview = Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (hasLocalImage && File(imagePath).existsSync()) {
      preview = Image.file(File(imagePath), fit: BoxFit.cover);
    } else if (hasRemoteImage) {
      preview = CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _emptyImageState(),
      );
    } else {
      preview = _emptyImageState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Style.getHeaderThree(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(text: 'Imagen del proyecto '),
              TextSpan(
                text: '(opcional, max 2MB)',
                style: Style.getTextStyle(color: Style.getObscureTextColor()),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  color: Style.getCardColor().withValues(alpha: .16),
                  border: Border.all(color: Style.getFormFieldBorderColor()),
                ),
                child: preview,
              ),
            ),
            if (hasSelectedImage)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Style.getPrimaryColor(),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Style.white,
                        size: 12.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Imagen lista',
                        style: Style.getTextStyle(
                          color: Style.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: CustomWidgets.button(
                onTap: _openImageSourceSheet,
                color: Style.getPrimaryColor(),
                isFilled: false,
                withBorder: true,
                elevation: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      color: Style.getPrimaryColor(),
                      size: 16.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Elegir imagen',
                      style: Style.getHeaderThree(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedImagePath != null &&
                _selectedImagePath!.trim().isNotEmpty) ...[
              SizedBox(width: 8.w),
              IconButton(
                tooltip: 'Quitar imagen',
                onPressed: () {
                  setState(() {
                    _selectedImagePath = '';
                    _selectedImageBytes = null;
                  });
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Style.getErrorColor(),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _emptyImageState() {
    return Container(
      alignment: Alignment.center,
      color: Style.getPrimaryColor().withValues(alpha: .06),
      child: Icon(
        Icons.image_outlined,
        size: 40.w,
        color: Style.getObscureTextColor(),
      ),
    );
  }

  Future<void> _openImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Style.getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_camera_rounded,
                  color: Style.getPrimaryColor(),
                ),
                title: const Text('Tomar foto'),
                onTap: () =>
                    _pickProjectImage(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: Style.getPrimaryColor(),
                ),
                title: const Text('Elegir de galería'),
                onTap: () =>
                    _pickProjectImage(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProjectImage(
    BuildContext sheetContext,
    ImageSource source,
  ) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) {
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      return;
    }

    final prepared = await _prepareProjectImage(picked);
    if (prepared == null) {
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      if (!mounted) return;

      Dialogs.showSimpleDialog(
        context,
        title: 'Imagen muy pesada',
        message: 'No se pudo ajustar la imagen por debajo de 2MB.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    setState(() {
      _selectedImagePath = prepared.path;
      _selectedImageBytes = prepared.bytes;
    });

    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }

  Future<_PreparedProjectImage?> _prepareProjectImage(XFile picked) async {
    final originalBytes = await picked.readAsBytes();
    if (originalBytes.length <= _maxImageBytes) {
      return _PreparedProjectImage(path: picked.path, bytes: originalBytes);
    }

    for (final quality in _compressionQualities) {
      Uint8List? compressed;
      try {
        compressed = await FlutterImageCompress.compressWithFile(
          picked.path,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
      } catch (_) {
        compressed = await FlutterImageCompress.compressWithList(
          originalBytes,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
      }

      if (compressed == null || compressed.isEmpty) continue;
      if (compressed.length > _maxImageBytes) continue;

      final tempFile = await _writeTempProjectImage(compressed);
      return _PreparedProjectImage(path: tempFile.path, bytes: compressed);
    }

    return null;
  }

  Future<File> _writeTempProjectImage(Uint8List bytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File(
      '${Directory.systemTemp.path}/worklink_portfolio_$timestamp.jpg',
    );
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
}

class _PreparedProjectImage {
  final String path;
  final Uint8List bytes;

  const _PreparedProjectImage({required this.path, required this.bytes});
}
