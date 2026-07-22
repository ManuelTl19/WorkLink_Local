import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';

class FreelancerCard extends StatelessWidget {
  final FreelancerModel freelancer;
  final VoidCallback onTap;

  const FreelancerCard({
    super.key,
    required this.freelancer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratingValue = freelancer.rating ?? freelancer.averageRate ?? 0;
    final availabilityValue =
        freelancer.availability ??
        (freelancer.available ? 'Disponible' : 'No disponible');

    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            freelancer.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Style.getHeaderTwo(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Style.getObscureTextColor(),
                          size: 14.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      freelancer.specialty,
                      style: Style.getTextStyle(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          size: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ratingValue.toStringAsFixed(1),
                          style: Style.getTextStyle(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _availabilityChip(availabilityValue),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      freelancer.shortDescription ?? freelancer.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ).copyWith(height: 1.35),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          color: Style.getSecondaryColor(),
                          size: 15.w,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            freelancer.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Style.getTextStyle(
                              color: Style.getObscureTextColor(),
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _avatar() {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Style.getPrimaryColor().withValues(alpha: .12),
        boxShadow: [
          BoxShadow(
            color: Style.getShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: freelancer.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
          errorWidget: (context, url, error) => Center(
            child: Text(
              freelancer.fullName
                  .split(' ')
                  .where((part) => part.trim().isNotEmpty)
                  .map((part) => part[0])
                  .take(2)
                  .join()
                  .toUpperCase(),
              style: Style.getTextStyle(
                color: Style.getPrimaryColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _availabilityChip(String value) {
    final isAvailable = value.toLowerCase().contains('disponible');
    final color = isAvailable
        ? const Color(0xFF28C76F)
        : Style.getSecondaryColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: Style.getCircularBorderRadius(100),
      ),
      child: Text(
        value,
        style: Style.getTextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 7,
        ),
      ),
    );
  }
}
