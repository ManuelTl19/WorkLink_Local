import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';

import 'package:worklink_local/modules/app/screens/dashboard_screen.dart';

import 'package:shimmer/shimmer.dart';

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

  Widget header() {
    return Padding(
      padding: Style.getPaddingHorizontal(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () => showDrawer(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Style.getPrimaryColor(),
                    radius: 20.w,
                    child: CachedNetworkImage(
                      imageUrl: Assets.userAvatar,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 20.w,
                      ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        salute(),
                        style: Style.getHeaderThree(
                          color: Style.getObscureTextColor(),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "Jose Manuel",
                        style: Style.getHeaderThree(
                          color: Style.getTextColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_rounded,
                color: Style.getPrimaryColor(),
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
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
          child: TextField(
            decoration: InputDecoration(
              hintText: MultiLanguages.of(context)!.translate('search_home'),
              hintStyle: TextStyle(
                color: Style.grey,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Style.grey, size: 20.w),
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
            style: TextStyle(color: Style.getTextColor()),
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
            icon:  Assets.iconUsers,
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
        title(
          "Categorías",
          icon: Icons.category_rounded,
          action: () {},
        ),

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

        title(
          "vacantes",
          icon: Icons.category_rounded,
          action: () {},
        ),

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

        title(
          "Solicitudes",
          icon: Icons.assignment_rounded,
          action: () {},
        ),

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
