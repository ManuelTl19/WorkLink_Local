import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';

import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final _controller = PageController();

  int mode = 0;
  bool isLoading = true;
  UserModel? _user;
  int _notificationCount = 0;

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
    getData().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: RefreshIndicator(
          onRefresh: () async {
            await getData();
            app.notify();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20.h),

                header(),

                SizedBox(height: 15.h),

                searcher(),

                boxes(app),

                // chipOptions(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: isLoading ? 0 : 90.h,
                  // child: ClockInClockOutCard(
                  //   collaboratorId: AppSettings.currentUser!.id,
                  // ),
                ),

                SizedBox(height: 10.h),

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
            onTap: () {},
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
            label: MultiLanguages.of(context)!.translate('search_home'),
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

  Widget boxes(AppSettings app) {
    return SizedBox(
      height: 100.w,
      child: GridView(
        padding: Style.getPadding(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisExtent: 160.w,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.w,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          box(
            icon: Assets.iconUsers,
            quantity: 0,
            reverse: false,
            color: Style.getPrimaryColor(),
            title: 'Servicios',
            onTap: () {},
          ),

          box(
            icon: Assets.iconDocuments,
            quantity: 0,
            reverse: true,
            color: Style.getPrimaryColor(),
            title: 'Vacantes',
            onTap: () {},
          ),

          box(
            icon: Assets.iconDocuments,
            quantity: 0,
            reverse: true,
            color: Style.getPrimaryColor(),
            title: 'Solicitudes',
            onTap: () {},
          ),

          box(
            icon: Assets.iconLeads,
            quantity: 0,
            reverse: true,
            color: Style.getPrimaryColor(),
            title: 'Mensajes',
            onTap: () {},
          ),

          box(
            icon: Assets.iconCalendar,
            quantity: 0,
            reverse: true,
            color: Style.getPrimaryColor(),
            title: 'Reputación',
            onTap: () {},
          ),
        ],
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
      shadowColor: Style.getShadowColor(),
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
                highlightColor: Style.getPrimaryColor().withValues(alpha: 0.2),
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
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        icon,
                        width: 40.w,
                        height: 40.w,
                        color: color,
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Style.getTextStyle(
                                fontWeight: FontWeight.w600,
                                color: Style.getTextColor(),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Style.getTextColor().withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  color: Style.getTextColor(),
                                  fontWeight: FontWeight.w600,
                                ),
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
                      highlightColor: Style.getPrimaryColor().withValues(
                        alpha: 0.2,
                      ),
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
                      highlightColor: Style.getPrimaryColor().withValues(
                        alpha: 0.2,
                      ),
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
                  action != null
                      ? IconButton(
                          onPressed: () => action(),
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Style.getPrimaryColor(),
                            size: 15.w,
                          ),
                        )
                      : const SizedBox(),
                ],
        ),
      ),
    );
  }

  Widget overview(AppSettings app) {
    return Column(
      key: const Key('overview'),
      children: [
        title("Categorías", icon: Icons.category_rounded, action: () {}),

        if (isLoading) ...[
          Container(
            padding: Style.getPadding(),
            height: 100.h,
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
          ),
        ] else ...[
          Padding(
            padding: Style.getPadding(),
            child: Card(
              color: Style.getCardColor(),
              shape: RoundedRectangleBorder(
                borderRadius: Style.getBorderRadius(),
              ),
              child: Container(
                padding: Style.getPadding(),
                height: 120.h,
                child: Center(
                  child: Text(
                    'No hay categorias',
                    style: Style.getHeaderThree(color: Style.getTextColor()),
                  ),
                ),
              ),
            ),
          ),
        ],

        title("vacantes", icon: Icons.category_rounded, action: () {}),

        if (isLoading) ...[
          Container(
            padding: Style.getPadding(),
            height: 180.h,
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
          ),
        ] else ...[
          Padding(
            padding: Style.getPadding(),
            child: Card(
              color: Style.getCardColor(),
              shape: RoundedRectangleBorder(
                borderRadius: Style.getBorderRadius(),
              ),
              child: Container(
                padding: Style.getPadding(),
                height: 120.h,
                child: Center(
                  child: Text(
                    'No hay vacantes disponibles',
                    style: Style.getHeaderThree(color: Style.getTextColor()),
                  ),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 10.h),

        title("Solicitudes", icon: Icons.assignment_rounded, action: () {}),

        if (isLoading) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: Style.getPadding(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 180.h,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Style.getCardColor(),
                highlightColor: Style.getPrimaryColor().withValues(alpha: 0.2),
                child: Container(
                  width: double.infinity,
                  height: 160.h,
                  decoration: BoxDecoration(
                    borderRadius: Style.getBorderRadius(),
                    color: Style.getCardColor(),
                  ),
                ),
              );
            },
          ),
        ] else ...[
          Padding(
            padding: Style.getPadding(),
            child: Card(
              color: Style.getCardColor(),
              shape: RoundedRectangleBorder(
                borderRadius: Style.getBorderRadius(),
              ),
              child: Container(
                padding: Style.getPadding(),
                height: 100.h,
                child: Center(
                  child: Text(
                    'No hay tareas disponibles',
                    style: Style.getHeaderThree(color: Style.getTextColor()),
                  ),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 80.h),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
