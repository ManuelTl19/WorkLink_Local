import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';
import 'package:worklink_local/modules/settings/screens/settings_screen.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class DrawerContent extends StatelessWidget {
  const DrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Drawer(
        backgroundColor: Style.getBackgroundColor(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(Assets.profileBg),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  dashboardKey.currentState!.closeDrawer();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundColor: Style.getPrimaryColor(),
                      child: CircleAvatar(
                        radius: 25.r,
                        backgroundImage: CachedNetworkImageProvider(
                          Assets.userAvatar,
                        ),
                        onBackgroundImageError: (exception, stackTrace) =>
                            const Icon(
                              Icons.person,
                              color: Style.white,
                              size: 30,
                            ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mani",
                            style: Style.getHeaderThree(
                              color: Style.white,
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Manu@gmail.com",
                            style: Style.getHeaderThree(
                              color: Style.white.withValues(alpha: .6),
                              fontSize: 10.w,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tile for home
            _normalTile(
              title: "Inicio",
              icon: Icons.home_rounded,
              onTap: () {
                screenIndex = 0;
                app.notify();
                push(context, const DashboardScreen());
                dashboardKey.currentState!.closeDrawer();
              },
            ),
            // End of tile for home

            // Expandable tile for modules
            moduleExpansioTile(
              context,
              title: "Clientes",
              icon: Icons.group_rounded,
              children: [
                // Tile for team
                _normalTile(
                  title: "Mis Contrataciones",
                  icon: Icons.assignment_turned_in_rounded,
                  onTap: () {
                    //TODO: Create a screen for collaborators list
                  },
                ),
                // End of tile for team
                // Tile for clients
                _normalTile(
                  title: "Favoritos",
                  icon: Icons.favorite_rounded,
                  onTap: () {},
                ),
                _normalTile(
                  title: "Historial",
                  icon: Icons.history_rounded,
                  onTap: () {},
                ),
              ],
            ),

            // Expandable tile for modules('task', 'projects')
            moduleExpansioTile(
              context,
              title: "Empresas",
              icon: Icons.group_rounded,
              children: [
                _normalTile(
                  title: "Mis Vacantes",
                  icon: Icons.work_rounded,
                  onTap: () {
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                // Tile for projects
                _normalTile(
                  title: "Postulaciones",
                  icon: Icons.how_to_reg_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();

                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                _normalTile(
                  title: "Historial",
                  icon: Icons.history_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
              ],
            ),

            moduleExpansioTile(
              context,
              title: "Freelancers",
              icon: Icons.group_rounded,
              children: [
                _normalTile(
                  title: "Mi Portafolio",
                  icon: Icons.work_history_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                _normalTile(
                  title: "Mis Servicios",
                  icon: Icons.schedule_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                _normalTile(
                  title: "Disponibilidad",
                  icon: Icons.inbox_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                _normalTile(
                  title: "Solicitudes recibidas",
                  icon: Icons.inbox_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
                _normalTile(
                  title: "Historial de trabajos",
                  icon: Icons.fact_check_rounded,
                  onTap: () {
                    screenIndex = 0;
                    app.notify();
                    dashboardKey.currentState!.closeDrawer();
                  },
                ),
              ],
            ),
            _normalTile(
              title: "Centro de ayuda",
              icon: Icons.support_agent_rounded,
              onTap: () {
                screenIndex = 0;
                app.notify();
                dashboardKey.currentState!.closeDrawer();
              },
            ),

            // Tile for settings
            _normalTile(
              title: MultiLanguages.of(context)!.translate('settings'),
              icon: Icons.settings_rounded,
              onTap: () => Navigator.of(
                context,
              ).push(Transitions.slideUpTransition(const SettingsScreen())),
            ),
            // End of tile for settings

            // Tile for logout
            _normalTile(
              title: MultiLanguages.of(context)!.translate('log_out'),
              icon: Icons.logout_rounded,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  Transitions.slideUpTransition(const LoginScreen()),
                );
                //AppSettings.currentUser!.clear();
              },
            ),

            // End of tile for logout
          ],
        ),
      ),
    );
  }

  Widget moduleExpansioTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        childrenPadding: EdgeInsets.only(left: 20.w),
        iconColor: Style.getTextColor(),
        title: Text(
          title,
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Icon(icon, color: Style.getTextColor(), size: 18.w),
        children: children,
      ),
    );
  }

  Widget _normalTile({
    required String title,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Style.getHeaderTwo(
          color: Style.getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: icon != null
          ? Icon(icon, color: Style.getTextColor(), size: 16.w)
          : null,
      onTap: onTap,
    );
  }
}
