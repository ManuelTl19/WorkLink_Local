import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/companies/models/company_profile_model.dart';

class CompanyCard extends StatelessWidget {
  final CompanyProfileModel company;
  final VoidCallback onTap;

  const CompanyCard({super.key, required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  color: Style.getPrimaryColor().withValues(alpha: .10),
                  child: company.photoUrl.isNotEmpty
                      ? Image.network(
                          company.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      company.industry,
                      style: Style.getTextStyle(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      company.location,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.w,
                          color: Style.getSecondaryColor(),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          company.averageRate.toStringAsFixed(1),
                          style: Style.getTextStyle(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          company.ownerName,
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      company.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                      ).copyWith(height: 1.35),
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

  Widget _fallbackAvatar() {
    return Center(
      child: Text(
        company.initials,
        style: Style.getHeaderThree(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
