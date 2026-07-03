import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';
import 'package:worklink_local/modules/vacancies/models/applicant_model.dart';

class ApplicantCard extends StatelessWidget {
  final ApplicantModel applicant;
  final VoidCallback onViewProfile;
  final VoidCallback onContact;

  const ApplicantCard({
    super.key,
    required this.applicant,
    required this.onViewProfile,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final freelancer = applicant.freelancer;

    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28.w,
              backgroundColor: Style.getPrimaryColor().withValues(alpha: .10),
              backgroundImage: freelancer.avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(freelancer.avatarUrl)
                  : null,
              child: freelancer.avatarUrl.isEmpty
                  ? Text(
                      _initials(freelancer.fullName),
                      style: Style.getTextStyle(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
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
                          style: Style.getHeaderTwo(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _statusChip(applicant.applicationStatus),
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
                      Icon(Icons.star_rounded, color: const Color(0xFFFFC107), size: 16.w),
                      SizedBox(width: 4.w),
                      Text(
                        freelancer.rating.toStringAsFixed(1),
                        style: Style.getTextStyle(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.place_rounded, color: Style.getSecondaryColor(), size: 15.w),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          freelancer.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Style.getTextStyle(color: Style.getObscureTextColor()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Postuló el ${DateFormat('dd/MM/yyyy').format(applicant.appliedAt)}',
                    style: Style.getTextStyle(color: Style.getObscureTextColor(), fontSize: 7),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onViewProfile,
                          icon: Icon(Icons.badge_rounded, size: 16.w),
                          label: const Text('Ver perfil'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onContact,
                          icon: Icon(Icons.chat_bubble_rounded, size: 16.w),
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
          ],
        ),
      ),
    );
  }

  Widget _statusChip(ApplicationStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Style.getTextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 8,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty);
    final initials = parts.map((part) => part[0]).take(2).join();
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.aceptada:
        return const Color(0xFF28C76F);
      case ApplicationStatus.enRevision:
        return const Color(0xFFFFA500);
      case ApplicationStatus.rechazada:
        return Style.getErrorColor();
      case ApplicationStatus.pendiente:
        return Style.getSecondaryColor();
    }
  }
}