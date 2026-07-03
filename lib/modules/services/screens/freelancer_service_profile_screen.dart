import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/portfolio/portfolio.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class FreelancerServiceProfileScreen extends StatefulWidget {
  const FreelancerServiceProfileScreen({super.key, required this.freelancerId});

  final int freelancerId;

  @override
  State<FreelancerServiceProfileScreen> createState() => _FreelancerServiceProfileScreenState();
}

class _FreelancerServiceProfileScreenState extends State<FreelancerServiceProfileScreen> {
  final ServicesService _service = ServicesService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  FreelancerModel? _freelancer;
  List<ServiceModel> _services = const [];

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
    final freelancer = FreelancersService().getFreelancerById(widget.freelancerId);
    final services = await _service.getFreelancerServices(freelancerId: widget.freelancerId);
    if (!mounted) return;
    setState(() {
      _freelancer = freelancer;
      _services = services;
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
    Navigator.of(context).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
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
            expandedHeight: 290.h,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.white),
            ),
            actions: [IconButton(onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: Style.white))],
            title: Text('Perfil del freelancer', style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w700)),
            flexibleSpace: FlexibleSpaceBar(background: _loading ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())) : _hero()),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_freelancer == null)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('El freelancer no existe.', style: Style.getTextStyle(color: Style.getObscureTextColor()))))
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 16.h, Style.horizontalPadding.w, 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: _contactFreelancer,
                        color: Style.getPrimaryColor(),
                        child: Text('Contactar', style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: () {
                          Navigator.of(context).push(Transitions.slideUpTransition(PortfolioScreen(freelancer: _freelancer!)));
                        },
                        color: Style.getCardColor(),
                        isFilled: false,
                        withBorder: true,
                        child: Text('Ver portafolio', style: Style.getHeaderThree(color: Style.getTextColor(), fontWeight: FontWeight.w700)),
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
                  title: 'Información profesional',
                  child: Column(
                    children: [
                      _detailRow('Especialidad', _freelancer!.specialty),
                      _detailRow('Estado', _freelancer!.availability),
                      _detailRow('Calificación', _freelancer!.rating.toStringAsFixed(1)),
                      _detailRow('Ubicación', _freelancer!.location),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 12.h, Style.horizontalPadding.w, 0),
                child: _infoCard(
                  title: 'Descripción profesional',
                  child: Text(_freelancer!.shortDescription, style: Style.getTextStyle(color: Style.getTextColor()).copyWith(height: 1.5)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 12.h, Style.horizontalPadding.w, 0),
                child: _infoCard(
                  title: 'Servicios publicados',
                  child: _services.isEmpty
                      ? Text('Este freelancer aún no ha publicado servicios.', style: Style.getTextStyle(color: Style.getObscureTextColor()))
                      : Column(
                          children: _services.map((service) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(service.mainImageUrl),
                                ),
                                title: Text(service.title, style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w700)),
                                subtitle: Text(service.priceLabel, style: Style.getTextStyle(color: Style.getObscureTextColor())),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final freelancer = _freelancer!;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(imageUrl: freelancer.avatarUrl, fit: BoxFit.cover),
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
                Text(freelancer.fullName, style: Style.getHeaderTwo(color: Style.white, fontWeight: FontWeight.w800, fontSize: 22)),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _pill(freelancer.specialty),
                    _pill(freelancer.availability),
                    _pill(freelancer.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
