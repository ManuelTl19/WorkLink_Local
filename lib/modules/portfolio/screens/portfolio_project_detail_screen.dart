import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/portfolio/models/portfolio_model.dart';
import 'package:worklink_local/modules/portfolio/models/project_model.dart';
import 'package:worklink_local/utils/utils.dart';

class PortfolioProjectDetailScreen extends StatelessWidget {
  final FreelancerModel freelancer;
  final PortfolioModel portfolio;
  final ProjectModel project;

  const PortfolioProjectDetailScreen({
    super.key,
    required this.freelancer,
    required this.portfolio,
    required this.project,
  });

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
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Style.white,
              ),
            ),
            title: Text(
              project.title,
              style: Style.getHeaderTwo(
                color: Style.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: project.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Style.getPrimaryColor().withValues(alpha: .84),
                          Style.getBackgroundColor().withValues(alpha: .95),
                        ],
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
                          Text(
                            freelancer.fullName,
                            style: Style.getHeaderTwo(
                              color: Style.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            freelancer.specialty,
                            style: Style.getTextStyle(
                              color: Style.white.withValues(alpha: .92),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              Style.horizontalPadding.w,
              16.h,
              Style.horizontalPadding.w,
              24.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Card(
                    color: Style.getCardColor(),
                    elevation: 5,
                    shadowColor: Style.getShadowColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Título'),
                          SizedBox(height: 4.h),
                          Text(
                            project.title,
                            style: Style.getHeaderTwo(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _sectionLabel('Descripción'),
                          SizedBox(height: 4.h),
                          Text(
                            project.fullDescription,
                            style: Style.getTextStyle(
                              color: Style.getTextColor(),
                            ).copyWith(height: 1.45),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              _infoTag(Icons.calendar_month_rounded, project.dateLabel),
                              SizedBox(width: 8.w),
                              _infoTag(Icons.lock_outline_rounded, portfolio.availabilityNote),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          _sectionLabel('Tecnologías'),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: project.technologies
                                .map(
                                  (tech) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Style.getPrimaryColor().withValues(alpha: .1),
                                      borderRadius: Style.getCircularBorderRadius(100),
                                    ),
                                    child: Text(
                                      tech,
                                      style: Style.getTextStyle(
                                        color: Style.getPrimaryColor(),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: Style.getHeaderThree(
        color: Style.getObscureTextColor(),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _infoTag(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Style.getBackgroundColor(),
          borderRadius: Style.getCircularBorderRadius(16),
          border: Border.all(
            color: Style.getBorderColor().withValues(alpha: .35),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Style.getSecondaryColor(), size: 15.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}