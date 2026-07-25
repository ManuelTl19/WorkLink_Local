import 'package:intl/intl.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/utils/utils.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final VacanciesService _service = VacanciesService();

  bool _loading = true;
  bool _submitting = false;
  ApplicationStatus? _filterStatus;
  List<VacancyApplicationModel> _applications = const [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _loading = true);
    try {
      final items = await _service.getMyApplications(status: _filterStatus);
      if (!mounted) return;
      setState(() {
        _applications = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _editMessage(VacancyApplicationModel application) async {
    if (_submitting || application.status != ApplicationStatus.pendiente) return;

    final controller = TextEditingController(text: application.message);
    final formKey = GlobalKey<FormState>();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18.w,
            16.h,
            18.w,
            MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar mensaje',
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: controller,
                  maxLines: 5,
                  maxLength: 5000,
                  decoration: InputDecoration(
                    hintText: 'Actualiza tu mensaje para la empresa...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length > 5000) {
                      return 'El mensaje no puede superar 5000 caracteres.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() != true) return;
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Style.getPrimaryColor(),
                          foregroundColor: Style.white,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (submitted != true) return;

    setState(() => _submitting = true);
    try {
      await _service.updateApplicationMessage(
        applicationId: application.id,
        message: controller.text.trim(),
      );
      if (!mounted) return;
      await _loadApplications();
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: 'Mensaje actualizado.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _withdraw(VacancyApplicationModel application) async {
    if (_submitting || application.status != ApplicationStatus.pendiente) return;

    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: 'Retirar postulación',
      message: '¿Quieres retirar esta postulación?',
      confirmText: 'Retirar',
      cancelText: 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await _service.deleteApplication(application.id);
      if (!mounted) return;
      await _loadApplications();
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: 'Postulación retirada correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.aceptada:
        return const Color(0xFF28C76F);
      case ApplicationStatus.rechazada:
        return Style.getErrorColor();
      case ApplicationStatus.pendiente:
        return Style.getSecondaryColor();
    }
  }

  String _vacancyLabel(VacancyApplicationModel item) {
    if (item.vacancyTitle.trim().isNotEmpty) return item.vacancyTitle.trim();
    return 'Vacante #${item.vacancyId}';
  }

  Widget _filterChip(String label, ApplicationStatus? status) {
    final selected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _filterStatus = status);
        _loadApplications();
      },
      selectedColor: Style.getPrimaryColor().withValues(alpha: .18),
      labelStyle: Style.getTextStyle(
        color: selected ? Style.getPrimaryColor() : Style.getTextColor(),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        title: Text(
          'Mis postulaciones',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _submitting ? null : _loadApplications,
            icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(Style.horizontalPadding.w),
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _filterChip('Todas', null),
                    _filterChip('Pendientes', ApplicationStatus.pendiente),
                    _filterChip('Aceptadas', ApplicationStatus.aceptada),
                    _filterChip('Rechazadas', ApplicationStatus.rechazada),
                  ],
                ),
                SizedBox(height: 12.h),
                if (_applications.isEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: Style.getCardColor(),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Text(
                      'No tienes postulaciones para este filtro.',
                      textAlign: TextAlign.center,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ..._applications.map(
                    (item) {
                      final color = _statusColor(item.status);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Card(
                          color: Style.getCardColor(),
                          elevation: 4,
                          shadowColor: Style.getShadowColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _vacancyLabel(item),
                                        style: Style.getHeaderThree(
                                          color: Style.getTextColor(),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: .12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        item.status.label,
                                        style: Style.getTextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.companyName.trim().isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    item.companyName,
                                    style: Style.getTextStyle(
                                      color: Style.getPrimaryColor(),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 8.h),
                                Text(
                                  'Postulada el ${DateFormat('dd/MM/yyyy HH:mm').format(item.appliedAt)}',
                                  style: Style.getTextStyle(
                                    color: Style.getObscureTextColor(),
                                    fontSize: 7,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  item.message.trim().isNotEmpty
                                      ? item.message
                                      : 'Sin mensaje adicional.',
                                  style: Style.getTextStyle(
                                    color: Style.getTextColor(),
                                  ).copyWith(height: 1.35),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            Transitions.slideUpTransition(
                                              VacancyDetailScreen(
                                                vacancyId: item.vacancyId,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.work_outline_rounded, size: 16.w),
                                        label: const Text('Ver vacante'),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.status == ApplicationStatus.pendiente) ...[
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _submitting ? null : () => _editMessage(item),
                                          icon: Icon(Icons.edit_rounded, size: 16.w),
                                          label: const Text('Editar mensaje'),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _submitting ? null : () => _withdraw(item),
                                          icon: Icon(Icons.delete_outline_rounded, size: 16.w),
                                          label: const Text('Retirar'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Style.getErrorColor(),
                                            side: BorderSide(color: Style.getErrorColor()),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
