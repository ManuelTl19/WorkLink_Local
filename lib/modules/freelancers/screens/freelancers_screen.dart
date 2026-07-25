import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/portfolio/portfolio.dart';
import 'package:worklink_local/utils/utils.dart';

class FreelancersScreen extends StatefulWidget {
  const FreelancersScreen({super.key});

  @override
  State<FreelancersScreen> createState() => _FreelancersScreenState();
}

class _FreelancersScreenState extends State<FreelancersScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  List<FreelancerModel> _freelancers = const [];

  @override
  void initState() {
    super.initState();
    _loadFreelancers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFreelancers() async {
    setState(() => _isLoading = true);
    final freelancers = await FreelancersService.getFreelancers();
    if (!mounted) return;
    setState(() {
      _freelancers = freelancers;
      _isLoading = false;
    });
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
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
                ),
              ),
              title: Text(
                'Freelancers',
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadFreelancers,
                  icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  8.h,
                  Style.horizontalPadding.w,
                  14.h,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Style.getPrimaryColor().withValues(alpha: .16),
                        Style.getPrimaryColor().withValues(alpha: .06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: Style.getCircularBorderRadius(24),
                    border: Border.all(
                      color: Style.getPrimaryColor().withValues(alpha: .10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Style.getPrimaryColor().withValues(alpha: .12),
                          borderRadius: Style.getCircularBorderRadius(16),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          color: Style.getPrimaryColor(),
                          size: 22.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Descubre talento disponible',
                              style: Style.getHeaderTwo(
                                color: Style.getTextColor(),
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Explora perfiles freelance preparados para proyectos de clientes y empresas.',
                              style: Style.getTextStyle(
                                color: Style.getObscureTextColor(),
                              ).copyWith(height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())),
              )
            else if (_freelancers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'No hay freelancers disponibles por ahora.',
                      textAlign: TextAlign.center,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  0,
                  Style.horizontalPadding.w,
                  20.h,
                ),
                sliver: SliverList.separated(
                  itemCount: _freelancers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final freelancer = _freelancers[index];
                    return FreelancerCard(
                      freelancer: freelancer,
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            PortfolioScreen(
                              freelancer: freelancer,
                              showContactFab: true,
                            ),
                          ),
                        );
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
}