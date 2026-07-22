import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/components/service_card.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/services/screens/freelancer_service_profile_screen.dart';
import 'package:worklink_local/modules/services/screens/service_detail_screen.dart';
import 'package:worklink_local/modules/services/screens/service_form_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final ServicesService _service = ServicesService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  int? _currentFreelancerId;
  List<ServiceModel> _services = const [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    final freelancerId = await _service.getCurrentFreelancerId();
    final services = await _service.getFreelancerServices(
      freelancerId: freelancerId,
    );
    if (!mounted) return;
    setState(() {
      _currentFreelancerId = freelancerId;
      _services = services;
      _loading = false;
    });
  }

  Future<void> _openForm({ServiceModel? service}) async {
    final saved = await Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ServiceFormScreen(service: service)));
    if (saved == true && mounted) {
      await _loadServices();
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title:
          MultiLanguages.of(context)?.translate('services_delete_title') ??
          'Eliminar servicio',
      message:
          MultiLanguages.of(context)?.translate('services_delete_message') ??
          'Esta acción eliminará el servicio y las solicitudes asociadas.',
      confirmText:
          MultiLanguages.of(context)?.translate('delete') ?? 'Eliminar',
      cancelText: MultiLanguages.of(context)?.translate('cancel') ?? 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;
    await _service.deleteService(service.id);
    if (mounted) await _loadServices();
  }

  Future<void> _changeStatus(ServiceModel service) async {
    final nextStatus = service.status == ServiceStatus.activo
        ? ServiceStatus.inactivo
        : ServiceStatus.activo;
    await _service.changeServiceStatus(
      serviceId: service.id,
      status: nextStatus,
    );
    if (mounted) await _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Style.getPrimaryColor(),
                Style.getPrimaryColor().lighten(.12),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Style.getPrimaryColor().withValues(alpha: .28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Style.white),
            label: Text(
              MultiLanguages.of(context)?.translate('services_create_button') ??
                  'Crear servicio',
              style: Style.getHeaderThree(
                color: Style.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadServices,
          color: Style.getPrimaryColor(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                title: Text(
                  MultiLanguages.of(context)?.translate('my_services_title') ??
                      'Mis Servicios',
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    8.h,
                    Style.horizontalPadding.w,
                    14.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          MultiLanguages.of(
                                context,
                              )?.translate('services_active_count') ??
                              'Servicios activos',
                          _services
                              .where(
                                (item) => item.status == ServiceStatus.activo,
                              )
                              .length
                              .toString(),
                          Icons.storefront_rounded,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _summaryCard(
                          MultiLanguages.of(context)?.translate('requests') ??
                              'Solicitudes',
                          _services
                              .fold<int>(
                                0,
                                (sum, item) => sum + item.interestedCount,
                              )
                              .toString(),
                          Icons.inbox_rounded,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomWidgets.button(
                          onTap: () => _openForm(),
                          color: Style.getPrimaryColor(),
                          child: Text(
                            MultiLanguages.of(
                                  context,
                                )?.translate('services_create_button') ??
                                'Crear servicio',
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
                          onTap: () {
                            Navigator.of(context).push(
                              Transitions.slideUpTransition(
                                FreelancerServiceProfileScreen(
                                  freelancerId: _currentFreelancerId,
                                  ownerPreview: true,
                                ),
                              ),
                            );
                          },
                          color: Style.getCardColor(),
                          isFilled: false,
                          withBorder: true,
                          child: Text(
                            MultiLanguages.of(
                                  context,
                                )?.translate('my_profile') ??
                                'Mi perfil',
                            style: Style.getHeaderThree(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 12.h)),
              if (_loading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                  ),
                )
              else if (_services.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_empty_owner') ??
                            'Aún no has creado servicios.',
                        textAlign: TextAlign.center,
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    4.h,
                    Style.horizontalPadding.w,
                    20.h,
                  ),
                  sliver: SliverList.separated(
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return ServiceCard(
                        service: service,
                        mode: ServiceCardMode.owner,
                        onTap: () {
                          Navigator.of(context).push(
                            Transitions.slideUpTransition(
                              ServiceDetailScreen(serviceId: service.id),
                            ),
                          );
                        },
                        onEdit: () => _openForm(service: service),
                        onDelete: () => _deleteService(service),
                        onStatusPressed: () => _changeStatus(service),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getCircularBorderRadius(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Style.getPrimaryColor(), size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  title,
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
