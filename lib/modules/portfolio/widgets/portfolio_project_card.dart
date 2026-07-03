import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/portfolio/models/project_model.dart';
import 'package:worklink_local/utils/utils.dart';

class PortfolioProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const PortfolioProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230.w,
      child: Card(
        color: Style.getCardColor(),
        elevation: 4,
        shadowColor: Style.getShadowColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 118.h,
                width: double.infinity,
                child: Stack(
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
                            Style.getPrimaryColor().withValues(alpha: .78),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12.w,
                      right: 12.w,
                      bottom: 10.h,
                      child: Text(
                        project.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Style.getHeaderThree(
                          color: Style.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                      ).copyWith(height: 1.35),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: Style.getSecondaryColor(),
                          size: 15.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          project.dateLabel,
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
}