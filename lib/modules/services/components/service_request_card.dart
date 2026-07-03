import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onViewProfile;
  final VoidCallback onContact;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onViewProfile,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Style.getHeaderTwo(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        request.accountType,
                        style: Style.getTextStyle(
                          color: Style.getPrimaryColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(request.requestedAt),
                        style: Style.getTextStyle(color: Style.getObscureTextColor()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewProfile,
                    icon: Icon(Icons.person_outline_rounded, size: 16.w),
                    label: const Text('Ver perfil'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContact,
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 16.w),
                    label: const Text('Contactar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Style.getPrimaryColor(),
                      foregroundColor: Style.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 60.w,
        height: 60.w,
        color: Style.getPrimaryColor().withValues(alpha: .08),
        child: CachedNetworkImage(
          imageUrl: request.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
          errorWidget: (_, __, ___) => Icon(Icons.groups_rounded, color: Style.getPrimaryColor(), size: 24.w),
        ),
      ),
    );
  }
}