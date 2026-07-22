import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
  });

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
                  color: Style.getPrimaryColor().withValues(alpha: .08),
                  child: company.logoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: company.logoUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Icon(
                            Icons.apartment_rounded,
                            color: Style.getPrimaryColor(),
                          ),
                        )
                      : Icon(
                          Icons.apartment_rounded,
                          color: Style.getPrimaryColor(),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
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
}
