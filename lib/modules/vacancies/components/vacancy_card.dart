import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';

enum VacancyCardMode { freelancer, company }

class VacancyCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VacancyCardMode mode;
  final VoidCallback onTap;
  final VoidCallback? onApply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewApplicants;
  final VoidCallback? onStatusPressed;
  final VoidCallback? onViewCompany;

  const VacancyCard({
    super.key,
    required this.vacancy,
    required this.mode,
    required this.onTap,
    this.onApply,
    this.onEdit,
    this.onDelete,
    this.onViewApplicants,
    this.onStatusPressed,
    this.onViewCompany,
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
                  _companyAvatar(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mode == VacancyCardMode.freelancer)
                          Text(
                            vacancy.companyName,
                            style: Style.getTextStyle(
                              color: Style.getPrimaryColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        Text(
                          vacancy.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Style.getHeaderTwo(
                            color: Style.getTextColor(),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            _metaChip(Icons.category_rounded, vacancy.category),
                            _metaChip(Icons.place_rounded, vacancy.location),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _statusChip(vacancy.status),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                vacancy.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(
                  color: Style.getObscureTextColor(),
                ).copyWith(height: 1.4),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _salaryTag(),
                  const Spacer(),
                  Icon(Icons.people_alt_rounded, color: Style.getSecondaryColor(), size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    '${vacancy.applicantsCount} postulantes',
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (mode == VacancyCardMode.freelancer) _freelancerActions() else _companyActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _companyAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        width: 60.w,
        height: 60.w,
        color: Style.getPrimaryColor().withValues(alpha: .08),
        child: CachedNetworkImage(
          imageUrl: vacancy.companyLogoUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
          errorWidget: (_, __, ___) => Icon(
            Icons.apartment_rounded,
            color: Style.getPrimaryColor(),
            size: 24.w,
          ),
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w600,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(VacancyStatus status) {
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

  Widget _salaryTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.getPrimaryColor().withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        vacancy.salary,
        style: Style.getTextStyle(
          color: Style.getPrimaryColor(),
          fontWeight: FontWeight.w700,
          fontSize: 8,
        ),
      ),
    );
  }

  Widget _freelancerActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.visibility_rounded, size: 16.w),
            label: const Text('Ver'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApply,
            icon: Icon(Icons.send_rounded, size: 16.w),
            label: const Text('Aplicar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Style.getPrimaryColor(),
              foregroundColor: Style.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyActions() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _actionButton(
          label: 'Ver',
          icon: Icons.visibility_rounded,
          onPressed: onTap,
          filled: false,
        ),
        _actionButton(
          label: 'Editar',
          icon: Icons.edit_rounded,
          onPressed: onEdit,
        ),
        _actionButton(
          label: 'Eliminar',
          icon: Icons.delete_rounded,
          onPressed: onDelete,
          destructive: true,
          filled: false,
        ),
        _actionButton(
          label: 'Postulantes',
          icon: Icons.people_alt_rounded,
          onPressed: onViewApplicants,
        ),
        if (onStatusPressed != null)
          _actionButton(
            label: 'Estado',
            icon: Icons.sync_alt_rounded,
            onPressed: onStatusPressed,
            filled: false,
          ),
        if (onViewCompany != null)
          _actionButton(
            label: 'Empresa',
            icon: Icons.apartment_rounded,
            onPressed: onViewCompany,
            filled: false,
          ),
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
              side: BorderSide(
                color: destructive ? Style.getErrorColor() : Style.getBorderColor(),
              ),
            ),
          );
  }

  Color _statusColor(VacancyStatus status) {
    switch (status) {
      case VacancyStatus.abierta:
        return const Color(0xFF28C76F);
      case VacancyStatus.cerrada:
        return Style.getErrorColor();
      case VacancyStatus.pausada:
        return const Color(0xFFFFA500);
    }
  }
}