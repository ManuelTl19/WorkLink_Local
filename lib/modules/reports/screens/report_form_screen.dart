import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reports/services/reports_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  final int reportedUserId;
  final String reportedUserName;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ReportsService _service = ReportsService();

  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await _service.createReport(
        reportedId: widget.reportedUserId,
        reason: _reasonController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Reporte enviado',
        message: 'Tu reporte se registró correctamente y quedó en revisión.',
        color: Style.getPrimaryColor(),
        icon: Icons.check_circle_outline_rounded,
      );
      Navigator.of(context).pop(true);
    } on ReportFlowException catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'No se pudo enviar',
        message: _friendlyError(e),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'No se pudo enviar',
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

  String _friendlyError(ReportFlowException error) {
    switch (error.statusCode) {
      case 403:
        return error.message.isNotEmpty
            ? error.message
            : 'No tienes permiso para realizar esta acción.';
      case 409:
        return error.message.isNotEmpty
            ? error.message
            : 'Este reporte ya existe o no puede registrarse de nuevo.';
      case 422:
      case 400:
        return error.message.isNotEmpty
            ? error.message
            : 'Revisa los datos del reporte e inténtalo de nuevo.';
      default:
        return error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: Style.getTextColor()),
        title: Text(
          'Reportar usuario',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          Style.horizontalPadding.w,
          14.h,
          Style.horizontalPadding.w,
          24.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Style.getCardColor(),
                  borderRadius: Style.getBorderRadius(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vas a reportar a',
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.reportedUserName,
                      style: Style.getHeaderTwo(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'El estado inicial será pending. Procura describir el problema con claridad y evidencia suficiente.',
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ).copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Motivo breve',
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _reasonController,
                textInputAction: TextInputAction.next,
                maxLength: 120,
                decoration: _inputDecoration(
                  hint: 'Ej. Comportamiento inapropiado',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa un motivo breve';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.h),
              Text(
                'Descripción detallada',
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                minLines: 6,
                maxLines: 8,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                decoration: _inputDecoration(
                  hint:
                      'Explica qué pasó, cuándo ocurrió y por qué representa un problema.',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa una descripción detallada';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: CustomWidgets.button(
                  onTap: () {
                    if (_submitting) return;
                    _submit();
                  },
                  color: Style.getPrimaryColor(),
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Style.white,
                          ),
                        )
                      : Text(
                          'Enviar reporte',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Style.getCardColor(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(
          color: Style.getObscureTextColor().withValues(alpha: .12),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(
          color: Style.getObscureTextColor().withValues(alpha: .12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: Style.getPrimaryColor(), width: 1.3),
      ),
      counterStyle: Style.getTextStyle(color: Style.getObscureTextColor()),
    );
  }
}
