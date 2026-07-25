import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onContact;
  final List<Widget> actions;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onContact,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                SizedBox(width: 10.w),
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
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        request.accountType,
                        style: Style.getTextStyle(
                          color: Style.getPrimaryColor(),
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _statusPill(),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(request.requestedAt),
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onContact,
                icon: Icon(Icons.chat_rounded, size: 14.w),
                label: Text(
                  MultiLanguages.of(context)?.translate('contact') ??
                      'Contactar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Style.getPrimaryColor(),
                  foregroundColor: Style.white,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  textStyle: Style.getTextStyle(
                    color: Style.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                  ),
                ),
              ),
            ),
            if (request.description.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                  fontSize: 8,
                ).copyWith(height: 1.35),
              ),
            ],
            if (request.budget != null) ...[
              SizedBox(height: 6.h),
              Text(
                'Presupuesto: ${request.budgetLabel}',
                style: Style.getTextStyle(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                  fontSize: 8,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Wrap(spacing: 8.w, runSpacing: 8.h, children: actions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill() {
    final status = request.status;
    final Color color;
    switch (status) {
      case ServiceContractRequestStatus.pending:
        color = Colors.orange;
        break;
      case ServiceContractRequestStatus.accepted:
        color = Colors.blue;
        break;
      case ServiceContractRequestStatus.rejected:
        color = Style.getErrorColor();
        break;
      case ServiceContractRequestStatus.canceled:
        color = Colors.grey;
        break;
      case ServiceContractRequestStatus.contracted:
        color = Style.getPrimaryColor();
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        request.status.label,
        style: Style.getTextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 6.5,
        ),
      ),
    );
  }

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 52.w,
        height: 52.w,
        color: Style.getPrimaryColor().withValues(alpha: .08),
        child: CachedNetworkImage(
          imageUrl: request.avatarUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
          errorWidget: (_, __, ___) => Icon(
            Icons.groups_rounded,
            color: Style.getPrimaryColor(),
            size: 20.w,
          ),
        ),
      ),
    );
  }
}
