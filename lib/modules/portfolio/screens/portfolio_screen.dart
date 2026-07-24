import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/screens/freelancer_availability_screen.dart';
import 'package:worklink_local/modules/portfolio/portfolio.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';

class PortfolioScreen extends StatefulWidget {
  final FreelancerModel freelancer;
  final bool forceOwner;
  final VoidCallback? onEditProfile;
  final VoidCallback? onDeleteProfile;

  const PortfolioScreen({
    super.key,
    required this.freelancer,
    this.forceOwner = false,
    this.onEditProfile,
    this.onDeleteProfile,
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
    await _loadPortfolio();
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

  Future<void> _openAvailability() async {
    final freelancerProfileId = widget.freelancer.id;
    if (freelancerProfileId == null) return;

    await Navigator.of(context).push(
      Transitions.slideUpTransition(
        FreelancerAvailabilityScreen(freelancerProfileId: freelancerProfileId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
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
              actions: [
                IconButton(
                  onPressed: _loadPortfolio,
                  icon: Icon(Icons.refresh_rounded, color: Style.white),
                ),
                if (widget.freelancer.id != null)
                  IconButton(
                    onPressed: _isActionLoading ? null : _openAvailability,
                    icon: Icon(
                      Icons.event_available_rounded,
                      color: Style.white,
                    ),
                  ),
                if (_isOwner)
                  IconButton(
                    onPressed: _isActionLoading
                        ? null
                        : () => _openProjectForm(),
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Style.white,
                    ),
                  ),
              ],
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
                  24.h,
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
                      subtitle: 'Descripción profesional y enfoque de trabajo.',
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
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _portfolio!.skills
                            .map((skill) => _skillChip(skill))
                            .toList(),
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
                            icon: Icons.work_history_rounded,
                            title: 'Experiencia',
                            value: _portfolio!.experience,
                          ),
                          SizedBox(height: 10.h),
                          _infoRow(
                            icon: Icons.schedule_rounded,
                            title: 'Tarifa por hora',
                            value: _portfolio!.hourlyRate,
                          ),
                          SizedBox(height: 10.h),
                          _infoRow(
                            icon: Icons.event_available_rounded,
                            title: 'Disponibilidad',
                            value: _portfolio!.availabilityNote,
                          ),
                        ],
                      ),
                    ),
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
                                        ? () =>
                                              _openProjectForm(project: project)
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
                    if (_isOwner)
                      SizedBox(
                        width: double.infinity,
                        child: CustomWidgets.button(
                          onTap: _isActionLoading
                              ? () {}
                              : () => _openProjectForm(),
                          color: Style.getPrimaryColor(),
                          shape: 1,
                          child: Text(
                            'Agregar proyecto',
                            style: Style.getHeaderThree(
                              color: Style.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
          ],
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
                    if (freelancer.availability != null)
                      _topBadge(
                        Icons.event_available_rounded,
                        freelancer.availability!,
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
        if (widget.freelancer.availability != null)
          _infoRow(
            icon: Icons.event_available_rounded,
            title: 'Disponibilidad',
            value: widget.freelancer.availability!,
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

    final result = await showDialog<ProjectModel>(
      context: context,
      builder: (context) => _ProjectFormDialog(initialProject: project),
    );

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

    final confirmed = await Dialogs.showConfirmDialog(
      context,
      title: 'Eliminar proyecto',
      message:
          '¿Deseas eliminar ${project.title}? Esta acción no se puede deshacer.',
      svg: Assets.svgTrashIcon,
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );

    if (!confirmed) {
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
  int _currentStep = 0;

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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: Style.getCardColor(),
          borderRadius: BorderRadius.circular(22.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar proyecto' : 'Nuevo proyecto',
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              _projectSteps(),
              SizedBox(height: 14.h),
              if (_currentStep == 0)
                Form(
                  key: _detailsFormKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _titleController,
                        label: 'Titulo',
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'Campo requerido';
                          if (text.length < 3) return 'Minimo 3 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 10.h),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Descripcion',
                        minLines: 3,
                        maxLines: 5,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return 'Campo requerido';
                          if (text.length < 10) return 'Minimo 10 caracteres';
                          return null;
                        },
                      ),
                      SizedBox(height: 10.h),
                      _buildField(
                        controller: _projectUrlController,
                        label: 'URL de proyecto (opcional)',
                        keyboardType: TextInputType.url,
                        validator: (_) => null,
                      ),
                    ],
                  ),
                )
              else
                _buildImagePicker(),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: CustomWidgets.button(
                      onTap: () {
                        if (_currentStep == 0) {
                          Navigator.pop(context);
                          return;
                        }
                        setState(() => _currentStep--);
                      },
                      color: Style.getCardColor(),
                      withBorder: true,
                      isFilled: false,
                      child: Text(
                        _currentStep == 0 ? 'Cancelar' : 'Atras',
                        style: Style.getHeaderThree(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomWidgets.button(
                      onTap: () {
                        if (_currentStep == 0) {
                          final valid =
                              _detailsFormKey.currentState?.validate() ?? false;
                          if (!valid) return;
                          setState(() => _currentStep = 1);
                          return;
                        }

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
                      color: Style.getPrimaryColor(),
                      child: Text(
                        _currentStep == 0
                            ? 'Siguiente'
                            : (isEditing ? 'Guardar' : 'Crear'),
                        style: Style.getHeaderThree(
                          color: Style.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _projectSteps() {
    Widget item(int index, String label) {
      final active = _currentStep == index;
      final done = _currentStep > index;
      final color = active || done
          ? Style.getPrimaryColor()
          : Style.getBorderColor().withValues(alpha: .35);

      return Expanded(
        child: Column(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? color : Style.getBackgroundColor(),
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? Icon(Icons.check_rounded, color: Style.white, size: 12.w)
                  : null,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Style.getTextStyle(
                color: active
                    ? Style.getTextColor()
                    : Style.getObscureTextColor(),
                fontSize: 7,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        item(0, 'Datos'),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 2.h,
            color: _currentStep > 0
                ? Style.getPrimaryColor()
                : Style.getBorderColor().withValues(alpha: .3),
          ),
        ),
        item(1, 'Imagen'),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      style: Style.getTextStyle(color: Style.getTextColor()),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Style.getTextStyle(color: Style.getObscureTextColor()),
      ),
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
        Text(
          'Imagen del proyecto (opcional, max 2MB)',
          style: Style.getTextStyle(
            color: Style.getObscureTextColor(),
            fontWeight: FontWeight.w600,
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
                color: Style.getBackgroundColor(),
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
              child: OutlinedButton.icon(
                onPressed: () => _openImageSourceSheet(),
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Elegir imagen'),
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
