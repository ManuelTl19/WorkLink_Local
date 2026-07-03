import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/portfolio/portfolio.dart';
import 'package:worklink_local/utils/utils.dart';

class PortfolioScreen extends StatefulWidget {
  final FreelancerModel freelancer;

  const PortfolioScreen({super.key, required this.freelancer});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioService _service = PortfolioService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  PortfolioModel? _portfolio;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    final portfolio = await _service.getPortfolioByFreelancerId(widget.freelancer.id);
    if (!mounted) return;
    setState(() {
      _portfolio = portfolio;
      _isLoading = false;
    });
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
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeader(context),
              ),
            ),
            if (_isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())),
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
                  delegate: SliverChildListDelegate(
                    [
                      _sectionCard(
                        title: 'Información principal',
                        subtitle: 'Resumen del freelancer y su contexto profesional.',
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
                        subtitle: 'Datos relevantes para contratación y contexto laboral.',
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
                        trailing: TextButton(
                          onPressed: () => _showComingSoon(),
                          child: Text(
                            'Ver más proyectos',
                            style: Style.getTextStyle(
                              color: Style.getPrimaryColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          height: 255.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _portfolio!.projects.length,
                            separatorBuilder: (context, index) => SizedBox(width: 12.w),
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
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 22.h),
                      SizedBox(
                        width: double.infinity,
                        child: CustomWidgets.button(
                          onTap: _showComingSoon,
                          color: Style.getPrimaryColor(),
                          shape: 1,
                          child: Text(
                            'Ver perfil completo',
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
                    _topBadge(Icons.star_rounded, freelancer.rating.toStringAsFixed(1)),
                    _topBadge(Icons.place_rounded, freelancer.location),
                    _topBadge(Icons.event_available_rounded, freelancer.availability),
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
          value: widget.freelancer.rating.toStringAsFixed(1),
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
          value: widget.freelancer.availability,
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
        border: Border.all(color: Style.getBorderColor().withValues(alpha: .32)),
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
        border: Border.all(color: Style.getPrimaryColor().withValues(alpha: .18)),
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

  void _showComingSoon() {
    Dialogs.showSimpleDialog(
      context,
      title: 'Próximamente',
      message: 'Esta acción quedará conectada a portafolios y perfiles reales.',
      color: Style.getPrimaryColor(),
      icon: Icons.info_outline_rounded,
    );
  }
}