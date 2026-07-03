import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/utils/utils.dart';

enum ServiceCardMode { browse, owner }

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final ServiceCardMode mode;
  final VoidCallback onTap;
  final VoidCallback? onRequest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewRequests;
  final VoidCallback? onStatusPressed;

  const ServiceCard({
    super.key,
    required this.service,
    required this.mode,
    required this.onTap,
    this.onRequest,
    this.onEdit,
    this.onDelete,
    this.onViewRequests,
    this.onStatusPressed,
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
              _imageHeader(),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Style.getHeaderTwo(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          service.category,
                          style: Style.getTextStyle(
                            color: Style.getPrimaryColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(service.status),
                ],
              ),
              SizedBox(height: 8.h),
              if (mode == ServiceCardMode.browse)
                Text(
                  service.freelancerName,
                  style: Style.getTextStyle(
                    color: Style.getSecondaryColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: const Color(0xFFFFC107), size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    service.averageRating.toStringAsFixed(1),
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _infoChip(service.priceLabel),
                  SizedBox(width: 8.w),
                  _infoChip(service.modality.label),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                service.shortDescription,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(color: Style.getObscureTextColor()).copyWith(height: 1.4),
              ),
              SizedBox(height: 12.h),
              if (mode == ServiceCardMode.browse) _browseActions() else _ownerActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        height: 180.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: service.mainImageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
              errorWidget: (_, __, ___) => Container(
                color: Style.getPrimaryColor().withValues(alpha: .08),
                child: Icon(Icons.design_services_rounded, color: Style.getPrimaryColor(), size: 36.w),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: .45)],
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusBadge(),
                  if (service.featured)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Style.getPrimaryColor().withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Destacado',
                        style: Style.getTextStyle(color: Style.white, fontWeight: FontWeight.w700, fontSize: 7),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.w,
                    backgroundImage: service.freelancerAvatarUrl.isNotEmpty ? NetworkImage(service.freelancerAvatarUrl) : null,
                    backgroundColor: Style.white.withValues(alpha: .18),
                    child: service.freelancerAvatarUrl.isEmpty
                        ? Icon(Icons.person_rounded, color: Style.white, size: 16.w)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      service.freelancerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Style.getHeaderThree(color: Style.white, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    final color = _statusColor(service.status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        service.status.label,
        style: Style.getTextStyle(color: Style.white, fontWeight: FontWeight.w700, fontSize: 7),
      ),
    );
  }

  Widget _statusChip(ServiceStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Style.getTextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 8),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Style.getBorderColor().withValues(alpha: .25)),
      ),
      child: Text(
        text,
        style: Style.getTextStyle(
          color: Style.getTextColor(),
          fontWeight: FontWeight.w600,
          fontSize: 7,
        ),
      ),
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
            onPressed: onRequest,
            icon: Icon(Icons.send_rounded, size: 16.w),
            label: const Text('Solicitar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Style.getPrimaryColor(),
              foregroundColor: Style.white,
            ),
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
        _actionButton(label: 'Interesados', icon: Icons.people_alt_rounded, onPressed: onViewRequests),
        if (onStatusPressed != null)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: foreground,
            ),
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

  Color _statusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.activo:
        return const Color(0xFF28C76F);
      case ServiceStatus.pausado:
        return const Color(0xFFFFA500);
      case ServiceStatus.archivado:
        return Style.getErrorColor();
    }
  }
}