import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/utils/utils.dart';

enum RequestCardMode { browse, owner }

class RequestCard extends StatelessWidget {
  final WorkRequestModel request;
  final RequestCardMode mode;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatusPressed;
  final VoidCallback? onViewProfile;
  final VoidCallback? onInterested;

  const RequestCard({
    super.key,
    required this.request,
    required this.mode,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusPressed,
    this.onViewProfile,
    this.onInterested,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 5,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: onTap,
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
                          request.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          request.category,
                          style: Style.getTextStyle(color: Style.getPrimaryColor(), fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            _metaChip(Icons.place_rounded, request.location),
                            _metaChip(Icons.date_range_rounded, _dateLabel),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _statusChip(request.status),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                request.shortDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(color: Style.getObscureTextColor()).copyWith(height: 1.4),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _budgetTag(),
                  const Spacer(),
                  Icon(Icons.people_alt_rounded, color: Style.getSecondaryColor(), size: 16.w),
                  SizedBox(width: 4.w),
                  Text('${request.interestedCount} interesados', style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w700, fontSize: 8)),
                ],
              ),
              SizedBox(height: 12.h),
              if (mode == RequestCardMode.browse) _browseActions() else _ownerActions(),
            ],
          ),
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
          imageUrl: request.requesterAvatarUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
          errorWidget: (_, __, ___) => Icon(Icons.assignment_rounded, color: Style.getPrimaryColor(), size: 24.w),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Style.getBorderColor().withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: Style.getSecondaryColor()),
          SizedBox(width: 4.w),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w600, fontSize: 8))),
        ],
      ),
    );
  }

  Widget _statusChip(RequestStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: Style.getTextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 8)),
    );
  }

  Widget _budgetTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.getPrimaryColor().withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(request.budgetLabel, style: Style.getTextStyle(color: Style.getPrimaryColor(), fontWeight: FontWeight.w700, fontSize: 8)),
    );
  }

  Widget _browseActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.visibility_rounded, size: 16.w),
            label: const Text('Ver detalle'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onInterested,
            icon: Icon(Icons.chat_rounded, size: 16.w),
            label: const Text('Me interesa'),
            style: ElevatedButton.styleFrom(backgroundColor: Style.getPrimaryColor(), foregroundColor: Style.white),
          ),
        ),
      ],
    );
  }

  Widget _ownerActions() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _actionButton(label: 'Ver', icon: Icons.visibility_rounded, onPressed: onTap, filled: false),
        _actionButton(label: 'Editar', icon: Icons.edit_rounded, onPressed: onEdit),
        _actionButton(label: 'Eliminar', icon: Icons.delete_rounded, onPressed: onDelete, destructive: true, filled: false),
        _actionButton(label: 'Estado', icon: Icons.sync_alt_rounded, onPressed: onStatusPressed, filled: false),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool filled = true,
    bool destructive = false,
  }) {
    final foreground = destructive ? Style.getErrorColor() : Style.white;
    final background = destructive ? Style.getErrorColor() : Style.getPrimaryColor();

    return filled
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16.w),
            label: Text(label),
            style: ElevatedButton.styleFrom(backgroundColor: background, foregroundColor: foreground),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16.w),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: destructive ? Style.getErrorColor() : Style.getTextColor(),
              side: BorderSide(color: destructive ? Style.getErrorColor() : Style.getBorderColor()),
            ),
          );
  }

  String get _dateLabel => '${request.postedAt.day.toString().padLeft(2, '0')}/${request.postedAt.month.toString().padLeft(2, '0')}/${request.postedAt.year}';

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.abierta:
        return const Color(0xFF28C76F);
      case RequestStatus.enProceso:
        return const Color(0xFFFFA500);
      case RequestStatus.cerrada:
        return Style.getErrorColor();
    }
  }
}
