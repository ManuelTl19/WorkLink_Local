import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reports/models/report_model.dart';
import 'package:worklink_local/modules/reports/services/reports_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.isAdmin,
  });

  final int reportId;
  final bool isAdmin;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final ReportsService _service = ReportsService();

  UserModel? _user;
  bool _loading = true;
  bool _submitting = false;
  UserReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      await _loadCurrentUser();
      final report = await _service.getReportById(widget.reportId);

      if (!mounted) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } on ReportFlowException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: _friendlyError(e),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(Constants.userEmailKey);
    if (userRaw == null || userRaw.isEmpty) return;

    _user = UserModel.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
  }

  bool get _isOwner =>
      _report != null && _user != null && _report!.reporterId == _user!.id;

  bool get _canWithdraw => _report != null && _report!.isPending && _isOwner;

  bool get _canDelete => _report != null && (widget.isAdmin || _canWithdraw);

  Future<void> _updateStatus() async {
    final report = _report;
    if (report == null || !widget.isAdmin) return;

    final allowedStatuses = report.isPending
        ? [ReportStatus.reviewed, ReportStatus.resolved]
        : report.isReviewed
        ? [ReportStatus.resolved]
        : <ReportStatus>[];

    if (allowedStatuses.isEmpty) {
      Dialogs.showSimpleDialog(
        context,
        title: 'Estado final',
        message:
            'Un reporte resuelto ya no puede cambiar a un estado anterior.',
        color: Style.getPrimaryColor(),
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    final selected = await showModalBottomSheet<ReportStatus>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actualizar estado',
                style: Style.getHeaderTwo(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              ...allowedStatuses.map(
                (status) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    status.label,
                    style: Style.getTextStyle(color: Style.getTextColor()),
                  ),
                  trailing: status == report.status
                      ? Icon(
                          Icons.check_rounded,
                          color: Style.getPrimaryColor(),
                        )
                      : null,
                  onTap: () => Navigator.pop(context, status),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected == report.status) return;

    setState(() => _submitting = true);
    try {
      await _service.updateReportStatus(reportId: report.id, status: selected);
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Estado actualizado',
        message: 'El reporte se actualizó correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
      await _loadData();
    } on ReportFlowException catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: _friendlyError(e),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteReport() async {
    final report = _report;
    if (report == null || !_canDelete) return;

    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title: widget.isAdmin ? 'Eliminar reporte' : 'Retirar reporte',
      message: widget.isAdmin
          ? 'Esta acción eliminará el reporte del sistema.'
          : 'Si lo retiras, el reporte dejará de estar disponible y no podrás recuperarlo.',
      confirmText: widget.isAdmin ? 'Eliminar' : 'Retirar',
      cancelText: 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await _service.deleteReport(report.id);
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: widget.isAdmin ? 'Reporte eliminado' : 'Reporte retirado',
        message: widget.isAdmin
            ? 'El reporte se eliminó correctamente.'
            : 'El reporte fue retirado correctamente.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
      Navigator.of(context).pop(true);
    } on ReportFlowException catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Error',
        message: _friendlyError(e),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _friendlyError(ReportFlowException error) {
    switch (error.statusCode) {
      case 403:
        return error.message.isNotEmpty
            ? error.message
            : 'No tienes permiso para realizar esta acción.';
      case 409:
        return error.message.isNotEmpty
            ? error.message
            : 'El estado o la operación no es válida para este reporte.';
      default:
        return error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: Style.getTextColor()),
        title: Text(
          'Detalle del reporte',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadData,
            icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : report == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'No se encontró el reporte.',
                  textAlign: TextAlign.center,
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Style.horizontalPadding.w,
                14.h,
                Style.horizontalPadding.w,
                24.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    title: 'Estado',
                    child: Row(
                      children: [
                        _statusBadge(report.statusLabel, report.status),
                        const Spacer(),
                        Text(
                          report.createdAt != report.updatedAt
                              ? 'Actualizado'
                              : 'Creado',
                          style: Style.getTextStyle(
                            color: Style.getObscureTextColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _sectionCard(
                    title: 'Información del reporte',
                    child: Column(
                      children: [
                        _detailRow(
                          'Reportado',
                          report.reportedName.isNotEmpty
                              ? report.reportedName
                              : 'Usuario ${report.reportedId}',
                        ),
                        _detailRow('Motivo', report.reason),
                        _detailRow('Descripción', report.description),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _sectionCard(
                    title: 'Fechas y autor',
                    child: Column(
                      children: [
                        _detailRow(
                          'Creado por',
                          report.reporterName.isNotEmpty
                              ? report.reporterName
                              : 'Usuario ${report.reporterId}',
                        ),
                        _detailRow(
                          'Fecha de creación',
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(report.createdAt),
                        ),
                        _detailRow(
                          'Última actualización',
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(report.updatedAt),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  if (_canDelete)
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: () {
                          if (_submitting) return;
                          _deleteReport();
                        },
                        color: Style.getErrorColor(),
                        child: Text(
                          widget.isAdmin
                              ? 'Eliminar reporte'
                              : 'Retirar reporte',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (widget.isAdmin && report.isPending) ...[
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: () {
                          if (_submitting) return;
                          _updateStatus();
                        },
                        color: Style.getPrimaryColor(),
                        child: Text(
                          'Actualizar estado',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ] else if (widget.isAdmin && report.isReviewed) ...[
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: () {
                          if (_submitting) return;
                          _updateStatus();
                        },
                        color: Style.getPrimaryColor(),
                        child: Text(
                          'Marcar como resuelto',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Style.getObscureTextColor().withValues(alpha: .10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Style.getHeaderThree(
              color: Style.getTextColor(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ).copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, ReportStatus status) {
    final color = switch (status) {
      ReportStatus.pending => Style.getSecondaryColor(),
      ReportStatus.reviewed => Style.getSecondaryColor(),
      ReportStatus.resolved => Style.getPrimaryColor(),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Style.getTextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
