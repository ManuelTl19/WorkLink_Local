import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/requests/requests.dart';
import 'package:worklink_local/modules/services/services.dart';
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

class _DrawerContentState extends State<DrawerContent> {
  UserModel? _user;
  bool _isLoading = true;
  String? _activeSection;
  String? _activeItem;

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
    final index = screenIndex;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncActiveRoute();
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
                    _groupTitle('GENERAL'),
                    _navItem(
                      title: 'Inicio',
                      icon: Icons.home_rounded,
                      section: 'general',
                      item: 'inicio',
                      onTap: () {
                        _navigateToDashboard(1);
                      },
                    ),
                    SizedBox(height: 8.h),
                    _groupTitle('GESTIÓN'),
                    _navExpansionTile(
                      title: 'Clientes',
                      icon: Icons.groups_rounded,
                      section: 'gestion',
                      children: [
                        _subNavItem(
                          title: 'Mis Contrataciones',
                          icon: Icons.assignment_turned_in_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Favoritos',
                          icon: Icons.favorite_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Historial',
                          icon: Icons.history_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    _navExpansionTile(
                      title: 'Empresas',
                      icon: Icons.apartment_rounded,
                      section: 'gestion',
                      children: [
                        _subNavItem(
                          title: 'Mis Vacantes',
                          icon: Icons.work_rounded,
                          onTap: () {
                            _pushMyVacancies();
                          },
                        ),
                        _subNavItem(
                          title: 'Postulaciones',
                          icon: Icons.how_to_reg_rounded,
                          onTap: () {
                            _pushMyVacancies();
                          },
                        ),
                        _subNavItem(
                          title: 'Historial',
                          icon: Icons.history_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    _navExpansionTile(
                      title: 'Freelancers',
                      icon: Icons.badge_rounded,
                      section: 'gestion',
                      children: [
                        _subNavItem(
                          title: 'Vacantes',
                          icon: Icons.work_outline_rounded,
                          onTap: () {
                            _pushVacancies();
                          },
                        ),
                        _subNavItem(
                          title: 'Explorar Freelancers',
                          icon: Icons.manage_search_rounded,
                          onTap: () {
                            _pushFreelancers();
                          },
                        ),
                        _subNavItem(
                          title: 'Mi Portafolio',
                          icon: Icons.work_history_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Mis Servicios',
                          icon: Icons.schedule_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Disponibilidad',
                          icon: Icons.event_available_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Solicitudes recibidas',
                          icon: Icons.inbox_rounded,
                          onTap: () {},
                        ),
                        _subNavItem(
                          title: 'Historial de trabajos',
                          icon: Icons.fact_check_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    _navExpansionTile(
                      title: 'Servicios',
                      icon: Icons.design_services_rounded,
                      section: 'gestion',
                      children: [
                        _subNavItem(
                          title: 'Servicios',
                          icon: Icons.storefront_rounded,
                          onTap: () {
                            _pushServices();
                          },
                        ),
                        _subNavItem(
                          title: 'Mis Servicios',
                          icon: Icons.work_history_rounded,
                          onTap: () {
                            _pushMyServices();
                          },
                        ),
                      ],
                    ),
                    _navExpansionTile(
                      title: 'Solicitudes',
                      icon: Icons.assignment_rounded,
                      section: 'gestion',
                      children: [
                        _subNavItem(
                          title: 'Solicitudes',
                          icon: Icons.assignment_turned_in_rounded,
                          onTap: () {
                            _pushRequests();
                          },
                        ),
                        _subNavItem(
                          title: 'Mis Solicitudes',
                          icon: Icons.playlist_add_check_rounded,
                          onTap: () {
                            _pushMyRequests();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _groupTitle('CUENTA'),
                    _navItem(
                      title: 'Perfil',
                      icon: Icons.person_rounded,
                      section: 'cuenta',
                      item: 'perfil',
                      onTap: () {
                        _pushProfile();
                      },
                    ),
                    _navItem(
                      title: 'Configuración',
                      icon: Icons.settings_rounded,
                      section: 'cuenta',
                      item: 'configuracion',
                      onTap: () {
                        _navigateToDashboard(2);
                      },
                    ),
                    SizedBox(height: 8.h),
                    _groupTitle('SOPORTE'),
                    _navItem(
                      title: 'Centro de ayuda',
                      icon: Icons.support_agent_rounded,
                      section: 'soporte',
                      item: 'soporte',
                      onTap: () {
                        _showInfo(
                          title: 'Centro de ayuda',
                          message: 'Acceso a ayuda y soporte próximamente.',
                        );
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
    final role = _role;

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
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -3),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
        leading: Icon(icon, color: iconColor, size: 18.w),
        title: Text(
          title,
          style: Style.getTextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.circle, size: 8.w, color: Style.getPrimaryColor())
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _navExpansionTile({
    required String title,
    required IconData icon,
    required String section,
    required List<Widget> children,
  }) {
    final isExpandedGroup = _activeSection == section;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: Style.getCircularBorderRadius(14),
        border: Border.all(
          color: isExpandedGroup
              ? Style.getPrimaryColor().withValues(alpha: .18)
              : Colors.transparent,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpandedGroup,
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
          childrenPadding: EdgeInsets.only(left: 18.w, right: 8.w, bottom: 8.h),
          iconColor: Style.getPrimaryColor(),
          collapsedIconColor: Style.getObscureTextColor(),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: Style.getCircularBorderRadius(14),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: Style.getCircularBorderRadius(14),
          ),
          leading: Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: isExpandedGroup
                  ? Style.getPrimaryColor().withValues(alpha: .12)
                  : Style.getBackgroundColor().darken(.05),
              borderRadius: Style.getCircularBorderRadius(100),
            ),
            child: Icon(
              icon,
              size: 16.w,
              color: isExpandedGroup
                  ? Style.getPrimaryColor()
                  : Style.getTextColor(),
            ),
          ),
          title: Text(
            title,
            style: Style.getTextStyle(
              color: isExpandedGroup
                  ? Style.getPrimaryColor()
                  : Style.getTextColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Icon(
            isExpandedGroup
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded,
            color: isExpandedGroup
                ? Style.getPrimaryColor()
                : Style.getObscureTextColor(),
          ),
          children: [
            Container(
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.only(left: 12.w),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Style.getPrimaryColor().withValues(alpha: .18),
                    width: 1.4,
                  ),
                ),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 6 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subNavItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 4.w, top: 2.h, bottom: 2.h),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor().darken(.02),
        borderRadius: Style.getCircularBorderRadius(12),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -4),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
        leading: Icon(icon, size: 16.w, color: Style.getSecondaryColor()),
        title: Text(
          title,
          style: Style.getTextStyle(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
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
    if (screenIndex != index) {
      setState(() {
        screenIndex = index;
      });
      dashController.jumpToPage(index);
      return;
    }

    if (index == 1) {
      dashController.jumpToPage(index);
    }
  }

  void _pushProfile() {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(const ProfileScreen()));
  }

  void _pushFreelancers() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const FreelancersScreen()));
  }

  void _pushVacancies() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const VacanciesScreen()));
  }

  void _pushMyVacancies() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const MyVacanciesScreen()));
  }

  void _pushServices() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const ServicesScreen()));
  }

  void _pushMyServices() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const MyServicesScreen()));
  }

  void _pushRequests() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const RequestsScreen()));
  }

  void _pushMyRequests() {
    Navigator.of(context).pop();
    Navigator.of(context).push(Transitions.slideUpTransition(const MyRequestsScreen()));
  }

  void _showInfo({required String title, required String message}) {
    Dialogs.showSimpleDialog(
      context,
      title: title,
      message: message,
      color: Style.getPrimaryColor(),
      icon: Icons.info_outline_rounded,
    );
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
    final roles = _user?.roles ?? [];
    if (roles.isNotEmpty) return roles.first;

    final tipoCuenta = (_user?.tipoCuenta ?? '').trim();
    if (tipoCuenta.isNotEmpty) return tipoCuenta;

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
}
