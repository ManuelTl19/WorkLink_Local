import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/settings/models/report_problem_model.dart';
import 'package:worklink_local/modules/settings/services/report_problem_service.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ReportProblemScreenState createState() => ReportProblemScreenState();
}

class ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  XFile? _evidence;
  bool _submitting = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  Future<void> _pickEvidence() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _evidence = picked;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    final report = ReportProblemModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      evidence: _evidence,
    );

    final success = await ReportProblemService.submitReport(report);

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });

    Dialogs.showSimpleDialog(
      context,
      title: success ? 'Reporte enviado' : 'Error',
      message: success
          ? 'Tu reporte se ha enviado correctamente. Gracias.'
          : 'No se pudo enviar el reporte. Intenta de nuevo.',
      color: success ? Style.getPrimaryColor() : Style.getErrorColor(),
      svg: success ? Assets.svgCheckIcon : Assets.svgErrorIcon,
      duration: 1800,
    );

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        elevation: 0,
        iconTheme: IconThemeData(color: Style.getTextColor()),
        title: Text(
          'Reportar un problema',
          style: Style.getHeaderTwo(color: Style.getTextColor()),
        ),
      ),
      body: SingleChildScrollView(
        padding: Style.getPaddingHorizontal().copyWith(top: 20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Título',
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              CustomInputField(
                controller: titleController,
                label: 'Título',
                requiredField: true,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.h),
              Text(
                'Descripción',
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              CustomInputField(
                controller: descriptionController,
                label: 'Descripción',
                maxLines: 5,
                requiredField: true,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.h),
              CustomImagePickerField(
                label: 'Evidencia (foto opcional)',
                hintText: 'Selecciona una foto si deseas',
                onXFilesChanged: (files) {
                  setState(() {
                    _evidence = files?.first;
                  });
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: CustomWidgets.button(
                  onTap: () {
                    if (_submitting) return;
                    _submitReport();
                  },
                  color: Style.getPrimaryColor(),
                  height: 50,
                  child: _submitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Style.white,
                          ),
                        )
                      : Text(
                          'Enviar reporte',
                          style: Style.getHeaderTwo(
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
}
