import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/main.dart';
import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/companies/screens/company_profile_screen.dart';
import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/notifications/screens/notifications_screen.dart';
import 'package:worklink_local/modules/reviews/screens/reviews_screen.dart';
import 'package:worklink_local/modules/reports/screens/reports_screen.dart';
import 'package:worklink_local/modules/services/services.dart';
import 'package:worklink_local/modules/vacancies/screens/my_applications_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/my_vacancies_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancies_screen.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/modules/users/screens/profile_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class DrawerContent extends StatefulWidget {
  const DrawerContent({super.key});

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> with RouteAware {
  UserModel? _user;
  // ignore: unused_field
  bool _isLoading = true;
  String? _activeSection;
  String? _activeItem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    _syncActiveRoute();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadUser();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _syncActiveRoute();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString(Constants.userEmailKey);

      if (userRaw != null && userRaw.isNotEmpty) {
        final userMap = jsonDecode(userRaw) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
      }
    } catch (e) {
      logWarning('No se pudo leer el usuario del drawer: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _syncActiveRoute() {
    // Get the current dashboard state to determine active section
    final dashboardState = currentDashboardState as DashboardScreenState?;
    final index = dashboardState?.screenIndex ?? 1;
    if (index == 1) {
      _activeSection = 'general';
      _activeItem = 'inicio';
    } else if (index == 2) {
      _activeSection = 'cuenta';
      _activeItem = 'configuracion';
    } else {
      _activeSection = 'general';
      _activeItem = 'inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Drawer(
        backgroundColor: Style.getBackgroundColor(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                  children: [
                    _groupTitle(
                      MultiLanguages.of(context)!.translate('general'),
                    ),
                    _navItem(
                      title: MultiLanguages.of(context)!.translate('home'),
                      icon: Icons.home_rounded,
                      section: 'general',
                      item: 'inicio',
                      onTap: () {
                        _navigateToDashboard(1);
                      },
                    ),
                    ..._buildRoleMenuItems(),
                    SizedBox(height: 8.h),
                    _groupTitle(
                      MultiLanguages.of(context)!.translate('account'),
                    ),
                    _navItem(
                      title: MultiLanguages.of(context)!.translate('profile'),
                      icon: Icons.person_rounded,
                      section: 'cuenta',
                      item: 'perfil',
                      onTap: () {
                        _pushProfile();
                      },
                    ),
                    _navItem(
                      title: 'Mis calificaciones',
                      icon: Icons.rate_review_rounded,
                      section: 'cuenta',
                      item: 'calificaciones',
                      onTap: _pushReviews,
                    ),
                    _navItem(
                      title: 'Mis reportes',
                      icon: Icons.report_problem_rounded,
                      section: 'cuenta',
                      item: 'reportes',
                      onTap: _pushReports,
                    ),
                    _navItem(
                      title: MultiLanguages.of(context)!.translate('settings'),
                      icon: Icons.settings_rounded,
                      section: 'cuenta',
                      item: 'configuracion',
                      onTap: () {
                        _navigateToDashboard(2);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Style.getObscureTextColor().withValues(alpha: .12),
                    ),
                    SizedBox(height: 8.h),
                    _navItem(
                      title: MultiLanguages.of(context)!.translate('log_out'),
                      icon: Icons.logout_rounded,
                      section: 'logout',
                      item: 'logout',
                      destructive: true,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          Transitions.slideUpTransition(const LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final fullName = _fullName;
    final email = _email;
    final role = _role; // ignore: unused_local_variable

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getBorderRadius(),
      ),
      child: InkWell(
        borderRadius: Style.getBorderRadius(),
        onTap: _pushProfile,
        child: Row(
          children: [
            _avatar(size: 28),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Style.getHeaderThree(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Style.getTextStyle(
                      color: Style.getObscureTextColor(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.w,
                  color: Style.getObscureTextColor(),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 6.h),
      child: Text(
        title,
        style: Style.getHeaderThree(
          color: Style.getObscureTextColor(),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _navItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String section,
    required String item,
    bool destructive = false,
  }) {
    final isSelected = _activeSection == section && _activeItem == item;
    final backgroundColor = isSelected
        ? Style.getPrimaryColor().withValues(alpha: .10)
        : Colors.transparent;
    final iconColor = destructive
        ? Style.getErrorColor()
        : isSelected
        ? Style.getPrimaryColor()
        : Style.getTextColor();
    final textColor = destructive
        ? Style.getErrorColor()
        : isSelected
        ? Style.getPrimaryColor()
        : Style.getTextColor();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: Style.getCircularBorderRadius(14),
        border: Border(
          left: BorderSide(
            color: isSelected ? Style.getPrimaryColor() : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: Style.getCircularBorderRadius(14),
        child: InkWell(
          borderRadius: Style.getCircularBorderRadius(14),
          splashColor: Style.getPrimaryColor().withValues(alpha: .12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 18.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: Style.getTextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.circle, size: 8.w, color: Style.getPrimaryColor()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar({double size = 12}) {
    final imageUrl = (_user?.fotoPerfil ?? '').trim();

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size.r,
        backgroundColor: Style.getPrimaryColor().withValues(alpha: .12),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: size * 1.w,
            height: size * 1.w,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _fallbackAvatar(size),
          ),
        ),
      );
    }

    return _fallbackAvatar(size);
  }

  Widget _fallbackAvatar(double size) {
    return CircleAvatar(
      radius: size.r,
      backgroundColor: Style.getPrimaryColor(),
      child: Text(
        _initials,
        style: Style.getTextStyle(
          color: Style.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  void _navigateToDashboard(int index) {
    Navigator.of(context).pop();

    // Get the current dashboard state
    final dashboardState = currentDashboardState as DashboardScreenState?;
    if (dashboardState == null) return;

    // Navigate to the selected page
    dashboardState.goToPage(index);
  }

  void _pushProfile() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ProfileScreen()));
  }

  void _pushFreelancers() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const FreelancersScreen()));
  }

  void _pushProfessionalProfile() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      Transitions.slideUpTransition(
        const FreelancerServiceProfileScreen(
          freelancerId: null,
          ownerPreview: true,
        ),
      ),
    );
  }

  void _pushFreelancerAvailability() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const FreelancerAvailabilityScreen()));
  }

  void _pushVacancies() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const VacanciesScreen()));
  }

  void _pushMyVacancies() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyVacanciesScreen()));
  }

  void _pushMyApplications() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyApplicationsScreen()));
  }

  void _pushServices() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ServicesScreen()));
  }

  void _pushMyServices() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const MyServicesScreen()));
  }

  void _pushRequests() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ServiceRequestsScreen()));
  }

  void _pushCompanyProfile() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const CompanyProfileScreen()));
  }

  void _pushNotifications() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const NotificationsScreen()));
  }

  void _pushReviews() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ReviewsScreen()));
  }

  void _pushReports() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ReportsScreen()));
  }

  void _goToChats() {
    _navigateToDashboard(0);
  }

  String get _fullName {
    final name = [
      _user?.nombre ?? '',
      _user?.apellidoP ?? '',
      _user?.apellidoM ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');

    if (name.isEmpty) {
      return 'Mani';
    }

    return name;
  }

  String get _email {
    final value = (_user?.correo ?? '').trim();
    return value.isEmpty ? 'Manu@gmail.com' : value;
  }

  String get _role {
    const restrictedRoles = {'admin', 'administrador'};

    final visibleRole = (_user?.roles ?? [])
        .map((role) => role.trim())
        .firstWhere(
          (role) =>
              role.isNotEmpty &&
              !restrictedRoles.contains(role.toLowerCase()),
          orElse: () => '',
        );
    if (visibleRole.isNotEmpty) return visibleRole;

    final tipoCuenta = (_user?.tipoCuenta ?? '').trim();
    if (tipoCuenta.isNotEmpty &&
        !restrictedRoles.contains(tipoCuenta.toLowerCase())) {
      return tipoCuenta;
    }

    return 'Usuario';
  }

  String get _initials {
    final parts = _fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'WL';

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts[1].substring(0, 1).toUpperCase()
        : '';
    return '$first$second';
  }

  bool _hasRole(String role) {
    final normalizedRoles =
        _user?.roles
            .map((value) => value.toLowerCase().trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        [];
    final roleName = role.toLowerCase().trim();
    final currentType = (_user?.tipoCuenta ?? '').toLowerCase().trim();

    if (normalizedRoles.contains(roleName) || currentType == roleName) {
      return true;
    }

    if (roleName == 'admin') {
      return normalizedRoles.contains('administrador') ||
          currentType == 'administrador';
    }

    return false;
  }

  List<Widget> _buildRoleMenuItems() {
    if (_hasRole('empresa')) {
      return [
        _navItem(
          title: MultiLanguages.of(context)!.translate('freelancers'),
          icon: Icons.badge_rounded,
          section: 'gestion',
          item: 'freelancers_empresa',
          onTap: _pushFreelancers,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('services'),
          icon: Icons.design_services_rounded,
          section: 'gestion',
          item: 'servicios_empresa',
          onTap: _pushServices,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('my_vacancies'),
          icon: Icons.business_center_rounded,
          section: 'gestion',
          item: 'mis_vacantes_empresa',
          onTap: _pushMyVacancies,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('vacancies'),
          icon: Icons.work_outline_rounded,
          section: 'gestion',
          item: 'vacantes_empresa',
          onTap: _pushVacancies,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('chats'),
          icon: Icons.chat_bubble_rounded,
          section: 'gestion',
          item: 'chats_empresa',
          onTap: _goToChats,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('business_profile'),
          icon: Icons.apartment_rounded,
          section: 'gestion',
          item: 'perfil_empresa',
          onTap: _pushCompanyProfile,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('notifications'),
          icon: Icons.notifications_rounded,
          section: 'gestion',
          item: 'notificaciones_empresa',
          onTap: _pushNotifications,
        ),
      ];
    }

    if (_hasRole('freelancer')) {
      return [
        _navItem(
          title: MultiLanguages.of(context)!.translate('my_services'),
          icon: Icons.work_history_rounded,
          section: 'gestion',
          item: 'mis_servicios_freelancer',
          onTap: _pushMyServices,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('vacancies'),
          icon: Icons.work_outline_rounded,
          section: 'gestion',
          item: 'vacantes_freelancer',
          onTap: _pushVacancies,
        ),
        _navItem(
          title: 'Mis postulaciones',
          icon: Icons.assignment_ind_rounded,
          section: 'gestion',
          item: 'postulaciones_freelancer',
          onTap: _pushMyApplications,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('requests'),
          icon: Icons.assignment_rounded,
          section: 'gestion',
          item: 'solicitudes_freelancer',
          onTap: _pushRequests,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('chats'),
          icon: Icons.chat_bubble_rounded,
          section: 'gestion',
          item: 'chats_freelancer',
          onTap: _goToChats,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('professional_profile'),
          icon: Icons.person_rounded,
          section: 'gestion',
          item: 'perfil_freelancer',
          onTap: _pushProfessionalProfile,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('availability'),
          icon: Icons.calendar_month_rounded,
          section: 'gestion',
          item: 'disponibilidad_freelancer',
          onTap: _pushFreelancerAvailability,
        ),
        _navItem(
          title: MultiLanguages.of(context)!.translate('notifications'),
          icon: Icons.notifications_rounded,
          section: 'gestion',
          item: 'notificaciones_freelancer',
          onTap: _pushNotifications,
        ),
      ];
    }

    return [
      _navItem(
        title: MultiLanguages.of(context)!.translate('freelancers'),
        icon: Icons.badge_rounded,
        section: 'gestion',
        item: 'freelancers_cliente',
        onTap: _pushFreelancers,
      ),
      _navItem(
        title: MultiLanguages.of(context)!.translate('services'),
        icon: Icons.design_services_rounded,
        section: 'gestion',
        item: 'servicios_cliente',
        onTap: _pushServices,
      ),
      _navItem(
        title: MultiLanguages.of(context)!.translate('requests'),
        icon: Icons.assignment_rounded,
        section: 'gestion',
        item: 'solicitudes_cliente',
        onTap: _pushRequests,
      ),
      _navItem(
        title: MultiLanguages.of(context)!.translate('chats'),
        icon: Icons.chat_bubble_rounded,
        section: 'gestion',
        item: 'chats_cliente',
        onTap: _goToChats,
      ),
      _navItem(
        title: MultiLanguages.of(context)!.translate('notifications'),
        icon: Icons.notifications_rounded,
        section: 'gestion',
        item: 'notificaciones_cliente',
        onTap: _pushNotifications,
      ),
    ];
  }
}
