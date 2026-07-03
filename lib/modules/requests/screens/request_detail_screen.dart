import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/modules/requests/screens/requester_profile_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final RequestsService _service = RequestsService();
  bool _loading = true;
  WorkRequestModel? _request;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final request = await _service.getRequestById(widget.requestId);
    if (!mounted) return;
    setState(() {
      _request = request;
      _loading = false;
    });
  }

  Future<void> _contactRequester() async {
    final request = _request;
    if (request == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: request.requesterName,
      avatarSeed: request.requesterName,
      subtitle: request.requesterAccountType,
      avatarUrl: request.requesterAvatarUrl,
      relatedEntityId: request.requesterId,
      relatedEntityType: 'requester',
    );

    if (!mounted) return;
    Navigator.of(context).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280.h,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.white),
            ),
            actions: [IconButton(onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: Style.white))],
            title: Text('Detalle de solicitud', style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(background: _loading ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())) : _hero()),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_request == null)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('La solicitud no existe.', style: Style.getTextStyle(color: Style.getObscureTextColor()))))
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 16.h, Style.horizontalPadding.w, 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: _contactRequester,
                        color: Style.getPrimaryColor(),
                        child: Text('Me interesa realizar este trabajo', style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontalPadding.w),
                child: _infoCard(
                  title: 'Descripción completa',
                  child: Text(_request!.description, style: Style.getTextStyle(color: Style.getTextColor()).copyWith(height: 1.5)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 12.h, Style.horizontalPadding.w, 0),
                child: _infoCard(
                  title: 'Información de la solicitud',
                  child: Column(
                    children: [
                      _detailRow('Categoría', _request!.category),
                      _detailRow('Presupuesto', _request!.budgetLabel),
                      _detailRow('Ubicación', _request!.location),
                      _detailRow('Modalidad', _request!.modality.label),
                      _detailRow('Fecha de publicación', DateFormat('dd MMM yyyy').format(_request!.postedAt)),
                      _detailRow('Estado', _request!.status.label),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 12.h, Style.horizontalPadding.w, 0),
                child: _requesterCard(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final request = _request!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(imageUrl: request.requesterAvatarUrl, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: .4), Style.getBackgroundColor().withValues(alpha: .95)],
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
                Text(request.title, style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w800, fontSize: 22)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _pill(request.category),
                    _pill(request.budgetLabel),
                    _pill(request.location),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _requesterCard() {
    final request = _request!;
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.of(context).push(Transitions.slideUpTransition(RequesterProfileScreen(requesterId: request.requesterId)));
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(radius: 30.w, backgroundImage: NetworkImage(request.requesterAvatarUrl)),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterName, style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
                    SizedBox(height: 4.h),
                    Text(request.requesterAccountType, style: Style.getTextStyle(color: Style.getPrimaryColor(), fontWeight: FontWeight.w700)),
                    SizedBox(height: 6.h),
                    Text(request.requesterDescription, style: Style.getTextStyle(color: Style.getTextColor()).copyWith(height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Style.getObscureTextColor()),
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
            Text(title, style: Style.getHeaderThree(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
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
          Expanded(flex: 4, child: Text(label, style: Style.getTextStyle(color: Style.getObscureTextColor(), fontWeight: FontWeight.w600))),
          SizedBox(width: 12.w),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.right, style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: Style.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(999), border: Border.all(color: Style.white.withValues(alpha: .22))),
      child: Text(label, style: Style.getTextStyle(color: Style.white, fontWeight: FontWeight.w700)),
    );
  }
}
