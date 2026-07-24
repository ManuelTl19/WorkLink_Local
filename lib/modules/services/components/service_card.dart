import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

enum ServiceCardMode { browse, owner }

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final ServiceCardMode mode;
  final VoidCallback onTap;
  final int? requestCount;
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
    this.requestCount,
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
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 3.h),
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
                  if (mode == ServiceCardMode.owner)
                    _ownerQuickActions(context),
                ],
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  if (_priceText.isNotEmpty) _infoChip(_priceText),
                  _infoChip(
                    service.location.isEmpty
                        ? (MultiLanguages.of(context)?.translate('remote') ??
                              'Remoto')
                        : service.location,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                _descriptionText(context),
                maxLines: mode == ServiceCardMode.browse ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                ).copyWith(height: 1.4),
              ),
              if (mode == ServiceCardMode.owner) ...[
                SizedBox(height: 10.h),
                _ownerVisibilityRow(context),
                if (onViewRequests != null) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewRequests,
                      icon: Icon(Icons.inbox_rounded, size: 16.w),
                      label: Text(
                        'Solicitudes (${requestCount ?? service.interestedCount})',
                      ),
                    ),
                  ),
                ],
              ],
              if (mode == ServiceCardMode.browse)
                _browseActions(context)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Style.getBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .25),
        ),
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

  Widget _browseActions(BuildContext context) {
    if (onRequest == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onRequest,
          icon: Icon(Icons.send_rounded, size: 16.w),
          label: Text(
            MultiLanguages.of(context)?.translate('request_service') ??
                'Solicitar',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Style.getPrimaryColor(),
            foregroundColor: Style.white,
          ),
        ),
      ),
    );
  }

  Widget _ownerQuickActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Style.getPrimaryColor().withValues(alpha: .10),
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onStatusPressed,
            tooltip: service.status == ServiceStatus.activo
                ? (MultiLanguages.of(context)?.translate('hidden') ??
                      'No visible')
                : (MultiLanguages.of(context)?.translate('visible') ??
                      'Visible'),
            icon: Icon(
              service.status == ServiceStatus.activo
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: service.status == ServiceStatus.activo
                  ? Style.getPrimaryColor()
                  : Style.getObscureTextColor(),
              size: 18.w,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        CustomPopupActions(
          backgroundColor: Style.getCardColor(),
          actions: [
            if (onEdit != null)
              PopupAction(
                value: 'edit',
                label:
                    MultiLanguages.of(context)?.translate('edit_profile') ??
                    'Editar',
                icon: Icons.edit_rounded,
                color: Style.getPrimaryColor(),
                onPressed: onEdit!,
              ),
            if (onDelete != null)
              PopupAction(
                value: 'delete',
                label:
                    MultiLanguages.of(context)?.translate('delete') ??
                    'Eliminar',
                icon: Icons.delete_rounded,
                color: Style.getErrorColor(),
                onPressed: onDelete!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _ownerVisibilityRow(BuildContext context) {
    final isVisible = service.status == ServiceStatus.activo;
    final color = isVisible
        ? Style.getPrimaryColor()
        : Style.getObscureTextColor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Icon(
            isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: color,
            size: 18.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isVisible
                  ? (MultiLanguages.of(context)?.translate('visible') ??
                        'Visible')
                  : (MultiLanguages.of(context)?.translate('hidden') ??
                        'No visible'),
              style: Style.getTextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool filled = true,
    bool destructive = false,
  }) {
    final background = destructive
        ? Style.getErrorColor()
        : Style.getPrimaryColor();

    return filled
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16.w),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: Style.white,
              visualDensity: VisualDensity.compact,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16.w),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: destructive
                  ? Style.getErrorColor()
                  : Style.getTextColor(),
              side: BorderSide(
                color: destructive
                    ? Style.getErrorColor()
                    : Style.getBorderColor(),
              ),
              visualDensity: VisualDensity.compact,
            ),
          );
  }

  Color _statusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.activo:
        return Style.getPrimaryColor();
      case ServiceStatus.inactivo:
        return Style.getObscureTextColor();
    }
  }

  String _descriptionText(BuildContext context) {
    final text = service.shortDescription.trim().isNotEmpty
        ? service.shortDescription.trim()
        : service.description.trim();
    if (text.isNotEmpty) return text;
    return MultiLanguages.of(context)?.translate('no_description') ??
        'Sin descripcion';
  }

  String get _priceText {
    final label = service.priceLabel.trim();
    if (label.isNotEmpty) return label;
    return service.priceValue <= 0
        ? ''
        : '\$${service.priceValue.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
