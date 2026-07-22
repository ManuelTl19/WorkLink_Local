import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/portfolio/models/project_model.dart';

class PortfolioProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PortfolioProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230.w,
      child: Card(
        color: Style.getCardColor(),
        elevation: 4,
        shadowColor: Style.getShadowColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
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
                    if (onEdit != null || onDelete != null)
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: PopupMenuButton<String>(
                          color: Style.getCardColor(),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: Style.white,
                            size: 18.w,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (_) => [
                            if (onEdit != null)
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                          ],
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
