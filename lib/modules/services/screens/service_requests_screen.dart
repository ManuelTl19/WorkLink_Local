import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/services/components/service_request_card.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key, required this.serviceId});

  final int serviceId;

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> {
  final ServicesService _service = ServicesService();
  bool _loading = true;
  ServiceModel? _serviceModel;
  List<ServiceRequestModel> _requests = const [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final serviceModel = await _service.getServiceById(widget.serviceId);
    final requests = await _service.getServiceRequestsByServiceId(widget.serviceId);
    if (!mounted) return;
    setState(() {
      _serviceModel = serviceModel;
      _requests = requests;
      _loading = false;
    });
  }

  Future<void> _contactRequester(ServiceRequestModel request) async {
    final chat = await MessageService.getOrCreateChat(
      name: request.requesterName,
      avatarSeed: request.requesterName,
      subtitle: request.accountType,
      avatarUrl: request.avatarUrl,
      relatedEntityId: request.requesterId,
      relatedEntityType: 'service_requester',
    );

    if (!mounted) return;
    Navigator.of(context).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  void _showRequesterProfile(ServiceRequestModel request) {
    showModalBottomSheet<void>(
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
            children: [
              Center(
                child: Container(
                  width: 46.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Style.getObscureTextColor().withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28.w,
                    backgroundImage: request.avatarUrl.isNotEmpty ? NetworkImage(request.avatarUrl) : null,
                    backgroundColor: Style.getPrimaryColor().withValues(alpha: .12),
                    child: request.avatarUrl.isEmpty ? Icon(Icons.groups_rounded, color: Style.getPrimaryColor()) : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.requesterName, style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
                        SizedBox(height: 4.h),
                        Text(request.accountType, style: Style.getTextStyle(color: Style.getPrimaryColor(), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _infoRow('Fecha de solicitud', DateFormat('dd MMM yyyy, HH:mm').format(request.requestedAt)),
              _infoRow('Tipo de cuenta', request.accountType),
              _infoRow('ID', request.requesterId.toString()),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: CustomWidgets.button(
                  onTap: () {
                    Navigator.pop(context);
                    _contactRequester(request);
                  },
                  color: Style.getPrimaryColor(),
                  child: Text('Contactar', style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: Style.getTextStyle(color: Style.getObscureTextColor(), fontWeight: FontWeight.w600)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(value, textAlign: TextAlign.right, style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        title: Text('Solicitudes', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : _serviceModel == null
              ? Center(child: Text('El servicio no existe.', style: Style.getTextStyle(color: Style.getObscureTextColor())))
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(Style.horizontalPadding.w),
                  children: [
                    Card(
                      color: Style.getCardColor(),
                      elevation: 4,
                      shadowColor: Style.getShadowColor(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_serviceModel!.title, style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
                            SizedBox(height: 6.h),
                            Text('${_requests.length} interesados', style: Style.getTextStyle(color: Style.getObscureTextColor())),
                            SizedBox(height: 6.h),
                            Text('Última actualización ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: Style.getTextStyle(color: Style.getObscureTextColor(), fontSize: 7)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    if (_requests.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Text('Todavía no hay solicitudes para este servicio.', textAlign: TextAlign.center, style: Style.getTextStyle(color: Style.getObscureTextColor())),
                      )
                    else
                      ..._requests.map(
                        (request) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ServiceRequestCard(
                            request: request,
                            onViewProfile: () => _showRequesterProfile(request),
                            onContact: () => _contactRequester(request),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
