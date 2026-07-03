import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/components/service_card.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/services/screens/freelancer_service_profile_screen.dart';
import 'package:worklink_local/modules/services/screens/service_detail_screen.dart';
import 'package:worklink_local/modules/services/screens/service_form_screen.dart';
import 'package:worklink_local/modules/services/screens/service_requests_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
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
    final services = await _service.getFreelancerServices();
    if (!mounted) return;
    setState(() {
      _services = services;
      _loading = false;
    });
  }

  Future<void> _openForm({ServiceModel? service}) async {
    final saved = await Navigator.of(context).push(
      Transitions.slideUpTransition(ServiceFormScreen(service: service)),
    );
    if (saved == true && mounted) {
      await _loadServices();
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: 'Eliminar servicio',
      message: 'Esta acción eliminará el servicio y las solicitudes asociadas.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;
    await _service.deleteService(service.id);
    if (mounted) await _loadServices();
  }

  Future<void> _changeStatus(ServiceModel service) async {
    final selected = await showModalBottomSheet<ServiceStatus>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ServiceStatus.values.map((status) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(status.label, style: Style.getTextStyle(color: Style.getTextColor())),
                trailing: status == service.status ? Icon(Icons.check_rounded, color: Style.getPrimaryColor()) : null,
                onTap: () => Navigator.pop(context, status),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == service.status) return;
    await _service.changeServiceStatus(serviceId: service.id, status: selected);
    if (mounted) await _loadServices();
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
              backgroundColor: Style.getBackgroundColor(),
              surfaceTintColor: Style.transparent,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.getTextColor()),
              ),
              actions: [
                IconButton(onPressed: _loadServices, icon: Icon(Icons.refresh_rounded, color: Style.getTextColor())),
                IconButton(onPressed: () => _openForm(), icon: Icon(Icons.add_circle_outline_rounded, color: Style.getTextColor())),
              ],
              title: Text('Mis Servicios', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 8.h, Style.horizontalPadding.w, 14.h),
                child: Row(
                  children: [
                    Expanded(child: _summaryCard('Servicios activos', _services.where((item) => item.status == ServiceStatus.activo).length.toString(), Icons.storefront_rounded)),
                    SizedBox(width: 10.w),
                    Expanded(child: _summaryCard('Solicitudes', _services.fold<int>(0, (sum, item) => sum + item.interestedCount).toString(), Icons.inbox_rounded)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontalPadding.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: () => _openForm(),
                        color: Style.getPrimaryColor(),
                        child: Text('Crear servicio', style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: () {
                          Navigator.of(context).push(Transitions.slideUpTransition(const FreelancerServiceProfileScreen(freelancerId: ServicesService.currentFreelancerId)));
                        },
                        color: Style.getCardColor(),
                        isFilled: false,
                        withBorder: true,
                        child: Text('Mi perfil', style: Style.getHeaderThree(color: Style.getTextColor(), fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            if (_loading)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())))
            else if (_services.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text('Aún no has creado servicios.', textAlign: TextAlign.center, style: Style.getTextStyle(color: Style.getObscureTextColor(), fontWeight: FontWeight.w600)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 4.h, Style.horizontalPadding.w, 20.h),
                sliver: SliverList.separated(
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return ServiceCard(
                      service: service,
                      mode: ServiceCardMode.owner,
                      onTap: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(ServiceDetailScreen(serviceId: service.id)));
                      },
                      onEdit: () => _openForm(service: service),
                      onDelete: () => _deleteService(service),
                      onViewRequests: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(ServiceRequestsScreen(serviceId: service.id)));
                      },
                      onStatusPressed: () => _changeStatus(service),
                    );
                  },
                ),
              ),
          ],
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
                Text(value, style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800, fontSize: 20)),
                Text(title, style: Style.getTextStyle(color: Style.getObscureTextColor())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
