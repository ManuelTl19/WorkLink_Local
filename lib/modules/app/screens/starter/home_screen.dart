import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/main.dart';
import 'package:worklink_local/modules/companies/screens/companies_screen.dart';
import 'package:worklink_local/modules/companies/screens/company_profile_screen.dart';
import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/freelancers/screens/freelancers_screen.dart';
import 'package:worklink_local/modules/notifications/screens/notifications_screen.dart';
import 'package:worklink_local/modules/notifications/services/notification_service.dart';
import 'package:worklink_local/modules/portfolio/screens/portfolio_screen.dart';
import 'package:worklink_local/modules/requests/requests.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/screens/service_detail_screen.dart';
import 'package:worklink_local/modules/services/screens/my_services_screen.dart';
import 'package:worklink_local/modules/services/screens/services_screen.dart';
import 'package:worklink_local/modules/services/services.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/modules/vacancies/components/vacancy_card.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/screens/my_vacancies_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancies_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';

import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen>, RouteAware {
  // ignore: unused_field
  final _controller = PageController();

  int mode = 0;
  bool isLoading = true;
  UserModel? _user;
  int _notificationCount = 0;
  final ServicesService _servicesService = ServicesService();
  final RequestsService _requestsService = RequestsService();
  final VacanciesService _vacanciesService = VacanciesService();
  List<FreelancerModel> _freelancers = const [];
  List<ServiceModel> _services = const [];
  List<WorkRequestModel> _requests = const [];
  List<VacancyModel> _vacancies = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadHeaderData();
  }

  String get _roleName {
    final roles = _user?.roles ?? [];
    if (roles.isNotEmpty) return roles.first.toLowerCase().trim();
    return (_user?.tipoCuenta ?? '').toLowerCase().trim();
  }

  bool _hasRole(String role) {
    final roleName = role.toLowerCase().trim();
    final roles =
        _user?.roles
            .map((value) => value.toLowerCase().trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        [];

    if (roles.contains(roleName) || _roleName == roleName) {
      return true;
    }

    if (roleName == 'admin') {
      return roles.contains('administrador') || _roleName == 'administrador';
    }

    return false;
  }

  // ignore: unused_element
  void _onPageChanged(int index) {
    setState(() {
      mode = index;
    });
  }

  Future<bool> getData() async {
    try {
      await Future.wait([
        // TaskService.getTasks(),
        // ProjectService.getProjects(),
        // LeadService.getLeads(),
      ]);
    } catch (e) {
      logError('Error fetching data: $e');
      return false;
    }

    return true;
  }

  @override
  void initState() {
    _loadHeaderData();
    _loadNotificationCount();
    _loadHomeCards();
    getData().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      logWarning('No se pudo cargar el contador de notificaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: RefreshIndicator(
          onRefresh: () async {
            await _loadHeaderData();
            await _loadHomeCards();
            await getData();
            app.notify();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 14.h),

                header(),

                SizedBox(height: 14.h),

                searcher(),

                SizedBox(height: 18.h),

                overview(app),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadHeaderData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString(Constants.userEmailKey);

      if (userRaw != null && userRaw.isNotEmpty) {
        final userMap = jsonDecode(userRaw) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
      }
    } catch (e) {
      logWarning('No se pudo cargar la cabecera de inicio: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadHomeCards() async {
    List<FreelancerModel> freelancers = const [];

    try {
      freelancers = await FreelancersService.getFreelancers();
    } catch (_) {
      freelancers = const [];
    }

    final services = await _servicesService.getServices();
    final requests = await _requestsService.getRequests();
    final vacancies = await _vacanciesService.getFreelancerVacancies();

    if (!mounted) return;

    setState(() {
      _freelancers = freelancers.take(6).toList();
      _services = services.take(6).toList();
      _requests = requests.take(6).toList();
      _vacancies = vacancies.take(6).toList();
    });
  }

  Widget header() {
    return Padding(
      padding: Style.getPaddingHorizontal(),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Style.getCardColor(),
          borderRadius: Style.getBorderRadius(),
          border: Border.all(
            color: Style.getObscureTextColor().withValues(alpha: .08),
          ),
          boxShadow: [
            BoxShadow(
              color: Style.getShadowColor(),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => showDrawer(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Style.getPrimaryColor().withValues(alpha: .22),
                          Style.getPrimaryColor().withValues(alpha: .08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(2.5.w),
                    child: CircleAvatar(
                      radius: 21.w,
                      backgroundColor: Style.getCardColor(),
                      child: ClipOval(child: _profileAvatar()),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF28C76F),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Style.getCardColor(),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salute(),
                    style: Style.getHeaderThree(
                      color: Style.getObscureTextColor(),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Style.getHeaderTwo(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            _notificationButton(),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    final imageUrl = (_user?.fotoPerfil ?? '').trim();

    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 42.w,
        height: 42.w,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
        errorWidget: (context, url, error) => _avatarInitials(),
      );
    }

    return _avatarInitials();
  }

  Widget _avatarInitials() {
    return Container(
      alignment: Alignment.center,
      color: Style.getPrimaryColor().withValues(alpha: .10),
      child: Text(
        _initials,
        style: Style.getHeaderThree(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _notificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Style.getBackgroundColor().lighten(.02),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
              _loadNotificationCount();
            },
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Style.getObscureTextColor().withValues(alpha: .08),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Style.getPrimaryColor(),
                size: 21.w,
              ),
            ),
          ),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Style.getErrorColor(),
                borderRadius: Style.getCircularBorderRadius(100),
                border: Border.all(
                  color: Style.getBackgroundColor(),
                  width: 1.5,
                ),
              ),
              child: Text(
                '$_notificationCount',
                style: Style.getTextStyle(
                  color: Style.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String get _fullName {
    final name = [
      _user?.nombre ?? '',
      _user?.apellidoP ?? '',
      _user?.apellidoM ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');

    return name.isEmpty ? 'Jose Manuel' : name;
  }

  // ignore: unused_element
  String get _role {
    final roles = _user?.roles ?? [];
    if (roles.isNotEmpty) return roles.first;

    final tipoCuenta = (_user?.tipoCuenta ?? '').trim();
    if (tipoCuenta.isNotEmpty) return tipoCuenta;

    return 'Administrador';
  }

  String get _initials {
    final parts = _fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'JM';

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts[1].substring(0, 1).toUpperCase()
        : '';
    return '$first$second';
  }

  String salute() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour < 12) {
      return MultiLanguages.of(context)!.translate('good_morning');
    } else if (hour < 19) {
      return MultiLanguages.of(context)!.translate('good_afternoon');
    } else {
      return MultiLanguages.of(context)!.translate('good_night');
    }
  }

  Widget searcher() {
    return Container(
      height: 50.h,
      padding: Style.getPaddingHorizontal(),
      child: Material(
        color: Style.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
        elevation: 4,
        shadowColor: Style.getShadowColor(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomInputField(
            controller: TextEditingController(),
            hintText: MultiLanguages.of(context)!.translate('search_home'),
            prefixIcon: Icon(Icons.search, color: Style.grey, size: 20.w),
            suffixIcon: InkWell(
              onTap: () {},
              borderRadius: Style.getCircularBorderRadius(100),
              child: Icon(
                Icons.filter_list_rounded,
                color: Style.grey,
                size: 20.w,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _statsSection() {
    return Padding(
      padding: Style.getPaddingHorizontal(),
      child: Wrap(
        spacing: 14.w,
        runSpacing: 14.h,
        children: [
          _statCard(
            icon: Icons.design_services_rounded,
            title: MultiLanguages.of(context)!.translate('services'),
            value: '12',
            color: Style.getPrimaryColor(),
          ),
          _statCard(
            icon: Icons.work_outline_rounded,
            title: MultiLanguages.of(context)!.translate('vacancies'),
            value: '6',
            color: Style.getSecondaryColor(),
          ),
          _statCard(
            icon: Icons.assignment_turned_in_rounded,
            title: MultiLanguages.of(context)!.translate('requests'),
            value: '3',
            color: Style.getAccentColor(),
          ),
          _statCard(
            icon: Icons.thumb_up_alt_outlined,
            title: MultiLanguages.of(context)!.translate('reputation'),
            value: '4.8',
            color: Style.getTextColor(),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 68.w) / 2,
      child: Card(
        color: Style.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
        elevation: 6,
        shadowColor: Style.getShadowColor().withOpacity(0.12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22.w),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: Style.getTextStyle(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                value,
                style: Style.getHeaderOne(
                  color: Style.getTextColor(),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget box({
    required String icon,
    required Color color,
    required String title,
    required bool reverse,
    required int quantity,
    required Function() onTap,
  }) {
    return Card(
      color: Style.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
      elevation: 4,
      shadowColor: Style.getShadowColor().withOpacity(0.12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Style.getBorderRadius(),
          border: Border(
            left: BorderSide(color: color, width: 4.w),
          ),
        ),
        child: isLoading
            ? Shimmer.fromColors(
                baseColor: Style.getCardColor(),
                highlightColor: Style.getPrimaryColor().withOpacity(0.14),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: Style.getBorderRadius(),
                    color: Style.getCardColor(),
                  ),
                ),
              )
            : InkWell(
                onTap: onTap,
                borderRadius: Style.getBorderRadius(),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Image.asset(
                            icon,
                            width: 28.w,
                            height: 28.w,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Style.getTextStyle(
                                fontWeight: FontWeight.w600,
                                color: Style.getTextColor(),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              quantity.toString(),
                              style: Style.getHeaderOne(
                                color: Style.getTextColor(),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /*
  Widget chipOptions() {
    return Container(
      height: 55.h,
      alignment: Alignment.centerLeft,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: Style.getPadding(),
        children: [
          chipOption(
            title: MultiLanguages.of(context)!.translate('overview'),
            index: 0
          ),
          chipOption(
            title: MultiLanguages.of(context)!.translate('analytics'),
            index: 1
          ),
        ],
      ),
    );
  }

  Widget chipOption({
    required String title,
    required int index,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Material(
        elevation: mode == index ? 5 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: Style.getBorderRadius(),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              mode = index;
            });
          },
          borderRadius: Style.getBorderRadius(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: Style.getPaddingSymmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: mode == index 
                ? Style.getPrimaryColor()
                : Style.getBackgroundColor(),
              borderRadius: Style.getBorderRadius(),
              border: Border.all(
                color: Style.getPrimaryColor(),
                width: 1.w,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: mode == index
                  ? Style.getBackgroundColor() 
                  : Style.getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  */

  Widget title(String title, {IconData? icon, Function()? action}) {
    return Padding(
      padding: Style.getPaddingHorizontal(),
      child: GestureDetector(
        onTap: action,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isLoading
              ? [
                  if (icon != null) ...[
                    Shimmer.fromColors(
                      baseColor: Style.getCardColor(),
                      highlightColor: Style.getPrimaryColor().withOpacity(0.2),
                      child: Icon(
                        Icons.circle_rounded,
                        color: Style.getAccentColor(),
                        size: 25.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Flexible(
                    child: Shimmer.fromColors(
                      baseColor: Style.getCardColor(),
                      highlightColor: Style.getPrimaryColor().withOpacity(0.2),
                      child: Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          borderRadius: Style.getBorderRadius(),
                          color: Style.getCardColor(),
                        ),
                      ),
                    ),
                  ),
                ]
              : [
                  if (icon != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Style.getBackgroundColor().darken(),
                        shape: BoxShape.circle,
                      ),
                      padding: Style.getPaddingAll(6),
                      child: Icon(
                        icon,
                        color: Style.getSecondaryColor(),
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Text(
                    title,
                    style: Style.getHeaderTwo(
                      color: Style.getPrimaryColor().darken(
                        AppSettings.isDarkModeOn ? 0 : 0.1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (action != null)
                    IconButton(
                      onPressed: action,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Style.getPrimaryColor(),
                        size: 15.w,
                      ),
                    )
                  else
                    const SizedBox(),
                ],
        ),
      ),
    );
  }

  Widget overview(AppSettings app) {
    return Column(
      key: const Key('overview'),
      children: [
        if (_showFreelancersSection) ...[
          title(
            MultiLanguages.of(context)!.translate('freelancers'),
            icon: Icons.badge_rounded,
            action: _openFreelancers,
          ),
          _freelancersCarousel(),
        ],
        if (_showServicesSection) ...[
          SizedBox(height: 8.h),
          title(
            MultiLanguages.of(context)!.translate('services'),
            icon: Icons.design_services_rounded,
            action: _openServices,
          ),
          _servicesCarousel(),
        ],
        if (_showRequestsSection) ...[
          SizedBox(height: 8.h),
          title(
            MultiLanguages.of(context)!.translate('requests'),
            icon: Icons.assignment_rounded,
            action: _openRequests,
          ),
          _requestsCarousel(),
        ],
        if (_showVacanciesSection) ...[
          SizedBox(height: 8.h),
          title(
            MultiLanguages.of(context)!.translate('vacancies'),
            icon: Icons.work_outline_rounded,
            action: _openVacancies,
          ),
          _vacanciesCarousel(),
        ],
        SizedBox(height: 80.h),
      ],
    );
  }

  bool get _showFreelancersSection =>
      _hasRole('empresa') || _hasRole('cliente') || _hasRole('admin');
  bool get _showServicesSection =>
      _hasRole('empresa') || _hasRole('cliente') || _hasRole('admin');
  bool get _showRequestsSection =>
      _hasRole('cliente') || _hasRole('freelancer') || _hasRole('admin');
  bool get _showVacanciesSection =>
      _hasRole('empresa') ||
      _hasRole('cliente') ||
      _hasRole('freelancer') ||
      _hasRole('admin');

  Widget _freelancersCarousel() {
    if (isLoading) {
      return _loadingHorizontal(height: 230.h);
    }
    if (_freelancers.isEmpty) {
      return _emptyHorizontal(
        MultiLanguages.of(context)!.translate('home_no_freelancers'),
      );
    }

    return SizedBox(
      height: 230.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Style.getPadding(),
        itemCount: _freelancers.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final freelancer = _freelancers[index];
          return SizedBox(
            width: 320.w,
            child: FreelancerCard(
              freelancer: freelancer,
              onTap: () {
                Navigator.of(context).push(
                  Transitions.slideUpTransition(
                    PortfolioScreen(freelancer: freelancer),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _servicesCarousel() {
    if (isLoading) {
      return _loadingHorizontal(height: 260.h);
    }
    if (_services.isEmpty) {
      return _emptyHorizontal(
        MultiLanguages.of(context)!.translate('home_no_services'),
      );
    }

    return SizedBox(
      height: 260.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Style.getPadding(),
        itemCount: _services.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final service = _services[index];
          return SizedBox(
            width: 340.w,
            child: Align(
              alignment: Alignment.topCenter,
              child: ServiceCard(
                service: service,
                mode: ServiceCardMode.browse,
                onTap: () {
                  Navigator.of(context).push(
                    Transitions.slideUpTransition(
                      ServiceDetailScreen(serviceId: service.id),
                    ),
                  );
                },
                onRequest: () {
                  Navigator.of(context).push(
                    Transitions.slideUpTransition(
                      ServiceDetailScreen(serviceId: service.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _requestsCarousel() {
    if (isLoading) {
      return _loadingHorizontal(height: 315.h);
    }
    if (_requests.isEmpty) {
      return _emptyHorizontal(
        MultiLanguages.of(context)!.translate('home_no_requests'),
      );
    }

    return SizedBox(
      height: 315.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Style.getPadding(),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final request = _requests[index];
          return SizedBox(
            width: 340.w,
            child: RequestCard(
              request: request,
              mode: RequestCardMode.browse,
              onTap: () {
                _openRequestDetail(request);
              },
              onInterested: () {
                _openRequestDetail(request);
              },
            ),
          );
        },
      ),
    );
  }

  void _openRequestDetail(WorkRequestModel request) {
    if (request.id <= 0) {
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(
          context,
        )!.translate('home_invalid_request_title'),
        message: MultiLanguages.of(
          context,
        )!.translate('home_invalid_request_message'),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    Navigator.of(context).push(
      Transitions.slideUpTransition(RequestDetailScreen(requestId: request.id)),
    );
  }

  Widget _vacanciesCarousel() {
    if (isLoading) {
      return _loadingHorizontal(height: 315.h);
    }
    if (_vacancies.isEmpty) {
      return _emptyHorizontal(
        MultiLanguages.of(context)!.translate('home_no_vacancies'),
      );
    }

    return SizedBox(
      height: 315.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: Style.getPadding(),
        itemCount: _vacancies.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final vacancy = _vacancies[index];
          return SizedBox(
            width: 340.w,
            child: VacancyCard(
              vacancy: vacancy,
              mode: VacancyCardMode.freelancer,
              onTap: () {
                Navigator.of(context).push(
                  Transitions.slideUpTransition(
                    VacancyDetailScreen(vacancyId: vacancy.id),
                  ),
                );
              },
              onApply: () {
                Navigator.of(context).push(
                  Transitions.slideUpTransition(
                    VacancyDetailScreen(vacancyId: vacancy.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _loadingHorizontal({required double height}) {
    return Container(
      padding: Style.getPadding(),
      height: height,
      child: Shimmer.fromColors(
        baseColor: Style.getCardColor(),
        highlightColor: Style.getPrimaryColor().withValues(alpha: 0.2),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: Style.getBorderRadius(),
            color: Style.getCardColor(),
          ),
        ),
      ),
    );
  }

  Widget _emptyHorizontal(String text) {
    return Padding(
      padding: Style.getPadding(),
      child: Card(
        color: Style.getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: Style.getBorderRadius()),
        child: Container(
          width: double.infinity,
          padding: Style.getPadding(),
          child: Text(
            text,
            style: Style.getTextStyle(color: Style.getObscureTextColor()),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  List<Widget> _buildRoleCards() {
    if (_hasRole('admin')) {
      return [
        _homeActionCard(
          MultiLanguages.of(context)!.translate('companies'),
          Icons.apartment_rounded,
          Style.getPrimaryColor(),
          _openCompanies,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('freelancers'),
          Icons.badge_rounded,
          Style.getSecondaryColor(),
          _openFreelancers,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('services'),
          Icons.design_services_rounded,
          Style.getAccentColor(),
          _openServices,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('requests'),
          Icons.assignment_rounded,
          Style.kingBlue,
          _openRequests,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('vacancies'),
          Icons.work_outline_rounded,
          Style.getPrimaryColor().darken(.1),
          _openVacancies,
        ),
      ];
    }

    if (_hasRole('empresa')) {
      return [
        _homeActionCard(
          MultiLanguages.of(context)!.translate('freelancers'),
          Icons.badge_rounded,
          Style.getPrimaryColor(),
          _openFreelancers,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('services'),
          Icons.design_services_rounded,
          Style.getSecondaryColor(),
          _openServices,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('my_vacancies'),
          Icons.business_center_rounded,
          Style.getAccentColor(),
          _openMyVacancies,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('vacancies'),
          Icons.work_outline_rounded,
          Style.kingBlue,
          _openVacancies,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('business_profile'),
          Icons.apartment_rounded,
          Style.getPrimaryColor().darken(.1),
          _openCompanyProfile,
        ),
      ];
    }

    if (_hasRole('freelancer')) {
      return [
        _homeActionCard(
          MultiLanguages.of(context)!.translate('vacancies'),
          Icons.work_outline_rounded,
          Style.getPrimaryColor(),
          _openVacancies,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('requests'),
          Icons.assignment_rounded,
          Style.getSecondaryColor(),
          _openRequests,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('my_services'),
          Icons.work_history_rounded,
          Style.kingBlue,
          _openMyServices,
        ),
        _homeActionCard(
          MultiLanguages.of(context)!.translate('my_requests'),
          Icons.playlist_add_check_rounded,
          Style.getPrimaryColor().darken(.1),
          _openMyRequests,
        ),
      ];
    }

    return [
      _homeActionCard(
        MultiLanguages.of(context)!.translate('freelancers'),
        Icons.badge_rounded,
        Style.getPrimaryColor(),
        _openFreelancers,
      ),
      _homeActionCard(
        MultiLanguages.of(context)!.translate('services'),
        Icons.design_services_rounded,
        Style.getSecondaryColor(),
        _openServices,
      ),
      _homeActionCard(
        MultiLanguages.of(context)!.translate('requests'),
        Icons.assignment_rounded,
        Style.getAccentColor(),
        _openRequests,
      ),
      _homeActionCard(
        MultiLanguages.of(context)!.translate('vacancies'),
        Icons.work_outline_rounded,
        Style.kingBlue,
        _openVacancies,
      ),
    ];
  }

  Widget _homeActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final cardWidth =
        (MediaQuery.of(context).size.width -
            (Style.horizontalPadding * 2) -
            10.w) /
        2;

    return SizedBox(
      width: cardWidth,
      child: Material(
        color: Style.getCardColor(),
        borderRadius: Style.getBorderRadius(),
        child: InkWell(
          borderRadius: Style.getBorderRadius(),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: Style.getBorderRadius(),
              border: Border.all(color: color.withValues(alpha: .24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18.w),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: Style.getTextStyle(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFreelancers() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const FreelancersScreen()));
  }

  void _openServices() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ServicesScreen()));
  }

  void _openMyServices() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyServicesScreen()));
  }

  void _openRequests() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const RequestsScreen()));
  }

  void _openMyRequests() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyRequestsScreen()));
  }

  void _openVacancies() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const VacanciesScreen()));
  }

  void _openMyVacancies() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyVacanciesScreen()));
  }

  void _openCompanies() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const CompaniesScreen()));
  }

  void _openCompanyProfile() {
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const CompanyProfileScreen()));
  }

  @override
  bool get wantKeepAlive => true;
}
