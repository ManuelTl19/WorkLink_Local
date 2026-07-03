import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/requests/models/requester_profile_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class RequesterProfileScreen extends StatefulWidget {
  const RequesterProfileScreen({super.key, required this.requesterId});

  final int requesterId;

  @override
  State<RequesterProfileScreen> createState() => _RequesterProfileScreenState();
}

class _RequesterProfileScreenState extends State<RequesterProfileScreen> {
  final RequestsService _service = RequestsService();
  bool _loading = true;
  RequesterProfileModel? _requester;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final requester = await _service.getRequesterById(widget.requesterId);
    if (!mounted) return;
    setState(() {
      _requester = requester;
      _loading = false;
    });
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
            expandedHeight: 300.h,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.white),
            ),
            actions: [IconButton(onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: Style.white))],
            title: Text('Perfil del solicitante', style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(background: _loading ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())) : _hero()),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_requester == null)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('El solicitante no existe.', style: Style.getTextStyle(color: Style.getObscureTextColor()))))
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 16.h, Style.horizontalPadding.w, 0),
                child: Card(
                  color: Style.getCardColor(),
                  elevation: 4,
                  shadowColor: Style.getShadowColor(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
                        SizedBox(height: 12.h),
                        _detailRow('Descripción', _requester!.description),
                        _detailRow('Ubicación', _requester!.location),
                        _detailRow('Calificación', _requester!.rating.toStringAsFixed(1)),
                        _detailRow('Información relevante', _requester!.relevantInfo),
                        _detailRow('Sitio', _requester!.website),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final requester = _requester!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(imageUrl: requester.avatarUrl, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: .38), Style.getBackgroundColor().withValues(alpha: .95)],
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
                Text(requester.name, style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w800, fontSize: 22)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _pill(requester.accountType),
                    _pill(requester.location),
                    _pill(requester.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
