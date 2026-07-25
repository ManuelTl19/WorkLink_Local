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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (mode == VacancyCardMode.company &&
                          (onEdit != null || onDelete != null))
                        _overflowMenu(context),
                      if (mode == VacancyCardMode.company &&
                          (onEdit != null || onDelete != null))
                        SizedBox(height: 6.h),
                      _statusChip(vacancy.status),
                    ],
                  ),
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
                  Icon(
                    Icons.people_alt_rounded,
                    color: Style.getSecondaryColor(),
                    size: 16.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${vacancy.applicantsCount} ${MultiLanguages.of(context)?.translate('applicants') ?? 'postulantes'}',
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (mode == VacancyCardMode.freelancer)
                _freelancerActions(context)
              else
                _companyActions(context),
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
          placeholder: (_, __) =>
              Container(color: Style.getPrimaryColor().withValues(alpha: .08)),
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
        border: Border.all(
          color: Style.getBorderColor().withValues(alpha: .25),
        ),
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

  Widget _freelancerActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onApply,
        icon: Icon(Icons.send_rounded, size: 16.w),
        label: Text(
          MultiLanguages.of(context)?.translate('apply') ?? 'Aplicar',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Style.getPrimaryColor(),
          foregroundColor: Style.white,
        ),
      ),
    );
  }

  Widget _companyActions(BuildContext context) {
    return Row(
      children: [
        if (onViewApplicants != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onViewApplicants,
              icon: Icon(Icons.people_alt_rounded, size: 16.w),
              label: Text(
                MultiLanguages.of(context)?.translate('applicants') ??
                    'Postulantes',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Style.getPrimaryColor(),
                foregroundColor: Style.white,
              ),
            ),
          ),
        if (onViewApplicants != null && onStatusPressed != null)
          SizedBox(width: 10.w),
        if (onStatusPressed != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onStatusPressed,
              icon: Icon(Icons.sync_alt_rounded, size: 16.w),
              label: Text(
                MultiLanguages.of(context)?.translate('status') ?? 'Estado',
              ),
            ),
          ),
      ],
    );
  }

  Widget _overflowMenu(BuildContext context) {
    return PopupMenuButton<_VacancyCardAction>(
      tooltip: 'Acciones',
      color: Style.getCardColor(),
      surfaceTintColor: Style.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      icon: Icon(
        Icons.more_vert_rounded,
        color: Style.getObscureTextColor(),
        size: 20.w,
      ),
      onSelected: (value) {
        if (value == _VacancyCardAction.edit) {
          onEdit?.call();
          return;
        }
        if (value == _VacancyCardAction.delete) {
          onDelete?.call();
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_VacancyCardAction>>[];
        if (onEdit != null) {
          items.add(
            PopupMenuItem<_VacancyCardAction>(
              value: _VacancyCardAction.edit,
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 18.w, color: Style.getTextColor()),
                  SizedBox(width: 10.w),
                  Text(
                    MultiLanguages.of(context)?.translate('edit_profile') ??
                        'Editar',
                    style: Style.getTextStyle(color: Style.getTextColor()),
                  ),
                ],
              ),
            ),
          );
        }
        if (onDelete != null) {
          items.add(
            PopupMenuItem<_VacancyCardAction>(
              value: _VacancyCardAction.delete,
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 18.w, color: Style.getErrorColor()),
                  SizedBox(width: 10.w),
                  Text(
                    MultiLanguages.of(context)?.translate('delete') ??
                        'Eliminar',
                    style: Style.getTextStyle(color: Style.getErrorColor()),
                  ),
                ],
              ),
            ),
          );
        }
        return items;
      },
    );
  }

  Color _statusColor(VacancyStatus status) {
    switch (status) {
      case VacancyStatus.abierta:
        return Style.getPrimaryColor();
      case VacancyStatus.cerrada:
        return Style.getErrorColor();
      case VacancyStatus.pausada:
        return Style.getSecondaryColor();
    }
  }
}

enum _VacancyCardAction { edit, delete }
