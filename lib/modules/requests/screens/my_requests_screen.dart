import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/requests/components/request_card.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/modules/requests/screens/request_detail_screen.dart';
import 'package:worklink_local/modules/requests/screens/request_form_screen.dart';
import 'package:worklink_local/modules/requests/screens/requester_profile_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final RequestsService _service = RequestsService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  List<WorkRequestModel> _requests = const [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    final requests = await _service.getMyRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _loading = false;
    });
  }

  Future<void> _openForm({WorkRequestModel? request}) async {
    final saved = await Navigator.of(context).push(Transitions.slideUpTransition(RequestFormScreen(request: request)));
    if (saved == true && mounted) {
      await _loadRequests();
    }
  }

  Future<void> _deleteRequest(WorkRequestModel request) async {
    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: 'Eliminar solicitud',
      message: 'Esta acción eliminará la solicitud y sus interesados asociados.',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;
    await _service.deleteRequest(request.id);
    if (mounted) await _loadRequests();
  }

  Future<void> _changeStatus(WorkRequestModel request) async {
    final selected = await showModalBottomSheet<RequestStatus>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: RequestStatus.values.map((status) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(status.label, style: Style.getTextStyle(color: Style.getTextColor())),
                trailing: status == request.status ? Icon(Icons.check_rounded, color: Style.getPrimaryColor()) : null,
                onTap: () => Navigator.pop(context, status),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == request.status) return;
    await _service.changeRequestStatus(requestId: request.id, status: selected);
    if (mounted) await _loadRequests();
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
              actions: [IconButton(onPressed: _loadRequests, icon: Icon(Icons.refresh_rounded, color: Style.getTextColor())), IconButton(onPressed: () => _openForm(), icon: Icon(Icons.add_circle_outline_rounded, color: Style.getTextColor()))],
              title: Text('Mis Solicitudes', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 8.h, Style.horizontalPadding.w, 14.h),
                child: Row(
                  children: [
                    Expanded(child: _summaryCard('Solicitudes abiertas', _requests.where((item) => item.status == RequestStatus.abierta).length.toString(), Icons.task_alt_rounded)),
                    SizedBox(width: 10.w),
                    Expanded(child: _summaryCard('Interesados', _requests.fold<int>(0, (sum, item) => sum + item.interestedCount).toString(), Icons.people_alt_rounded)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontalPadding.w),
                child: CustomWidgets.button(
                  onTap: () => _openForm(),
                  color: Style.getPrimaryColor(),
                  child: Text('Crear solicitud', style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            if (_loading)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())))
            else if (_requests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Aún no has creado solicitudes.', style: Style.getTextStyle(color: Style.getObscureTextColor()))),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 4.h, Style.horizontalPadding.w, 20.h),
                sliver: SliverList.separated(
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return RequestCard(
                      request: request,
                      mode: RequestCardMode.owner,
                      onTap: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(RequestDetailScreen(requestId: request.id)));
                      },
                      onEdit: () => _openForm(request: request),
                      onDelete: () => _deleteRequest(request),
                      onStatusPressed: () => _changeStatus(request),
                      onViewProfile: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(RequesterProfileScreen(requesterId: request.requesterId)));
                      },
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
      decoration: BoxDecoration(color: Style.getCardColor(), borderRadius: Style.getCircularBorderRadius(22)),
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
