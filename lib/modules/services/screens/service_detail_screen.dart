import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/services/screens/freelancer_service_profile_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServicesService _service = ServicesService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  ServiceModel? _serviceModel;
  FreelancerModel? _freelancer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final serviceModel = await _service.getServiceById(widget.serviceId);
    if (serviceModel == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    final freelancer = await FreelancersService.getFreelancerById(
      serviceModel.freelancerId,
    );
    if (!mounted) return;
    setState(() {
      _serviceModel = serviceModel;
      _freelancer = freelancer;
      _loading = false;
    });
  }

  Future<void> _contactFreelancer() async {
    final freelancer = _freelancer;
    if (freelancer == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: freelancer.fullName,
      avatarSeed: freelancer.fullName,
      subtitle: freelancer.specialty,
      avatarUrl: freelancer.avatarUrl,
      relatedEntityId: freelancer.id,
      relatedEntityType: 'freelancer',
    );

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.white),
            ),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: Icon(Icons.refresh_rounded, color: Style.white),
              ),
            ],
            title: Text(
              MultiLanguages.of(context)?.translate('services_detail_title') ??
                  'Detalle del servicio',
              style: Style.getHeaderTwo(
                color: Style.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _loading
                  ? Center(
                      child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                    )
                  : _hero(),
            ),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_serviceModel == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('services_not_found') ??
                      'El servicio no existe.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  16.h,
                  Style.horizontalPadding.w,
                  12.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: _contactFreelancer,
                        color: Style.getPrimaryColor(),
                        child: Text(
                          MultiLanguages.of(context)?.translate('contact') ??
                              'Contactar',
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
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding.w,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(
                        context,
                      )?.translate('services_full_description') ??
                      'Descripción completa',
                  child: Text(
                    _serviceModel!.description,
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                    ).copyWith(height: 1.5),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(
                        context,
                      )?.translate('services_information') ??
                      'Información del servicio',
                  child: Column(
                    children: [
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_category') ??
                            'Categoría',
                        _serviceModel!.category,
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('location') ??
                            'Ubicación',
                        _serviceModel!.location.isEmpty
                            ? (MultiLanguages.of(
                                    context,
                                  )?.translate('not_specified') ??
                                  'No especificada')
                            : _serviceModel!.location,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_price') ??
                            'Precio',
                        _serviceModel!.priceLabel,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_modality') ??
                            'Modalidad',
                        _serviceModel!.modality.label,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_estimated_time') ??
                            'Tiempo estimado',
                        _serviceModel!.estimatedTime,
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_rating') ??
                            'Calificación',
                        _serviceModel!.averageRating.toStringAsFixed(1),
                      ),
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_published') ??
                            'Publicado',
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(_serviceModel!.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _galleryCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _freelancerCard(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final serviceModel = _serviceModel!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: serviceModel.mainImageUrl,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Style.transparent,
                Style.black.withValues(alpha: .42),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceModel.title,
                  style: Style.getHeaderTwo(
                    color: Style.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _pill(serviceModel.category),
                    _pill(serviceModel.priceLabel),
                    _pill(serviceModel.modality.label),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _galleryCard() {
    final serviceModel = _serviceModel!;
    return _infoCard(
      title: MultiLanguages.of(context)?.translate('gallery') ?? 'Galería',
      child: SizedBox(
        height: 150.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: serviceModel.galleryImages.isEmpty
              ? 1
              : serviceModel.galleryImages.length,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            final image = serviceModel.galleryImages.isEmpty
                ? serviceModel.mainImageUrl
                : serviceModel.galleryImages[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: SizedBox(
                width: 220.w,
                child: CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _freelancerCard() {
    final freelancer = _freelancer!;
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.of(context).push(
            Transitions.slideUpTransition(
              FreelancerServiceProfileScreen(freelancerId: freelancer.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.w,
                backgroundImage: NetworkImage(freelancer.avatarUrl),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.fullName,
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      freelancer.specialty,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      freelancer.shortDescription ?? freelancer.description,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                      ).copyWith(height: 1.3),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Style.getObscureTextColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Style.getHeaderThree(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Style.white.withValues(alpha: .22)),
      ),
      child: Text(
        label,
        style: Style.getTextStyle(
          color: Style.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
