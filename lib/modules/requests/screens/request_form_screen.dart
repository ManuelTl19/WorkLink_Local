import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key, this.request});

  final WorkRequestModel? request;

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final RequestsService _service = RequestsService();
  final List<GlobalKey<FormState>> _stepKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _budgetLabelController;
  late final TextEditingController _locationController;
  late RequestModality _modality;
  late RequestStatus _status;
  int _currentStep = 0;
  bool _saving = false;

  bool get _isEditing => widget.request != null;

  @override
  void initState() {
    super.initState();
    final request = widget.request;
    _titleController = TextEditingController(text: request?.title ?? '');
    _categoryController = TextEditingController(text: request?.category ?? '');
    _shortDescriptionController = TextEditingController(
      text: request?.shortDescription ?? '',
    );
    _descriptionController = TextEditingController(
      text: request?.description ?? '',
    );
    _budgetLabelController = TextEditingController(
      text: request?.budgetLabel ?? '',
    );
    _locationController = TextEditingController(text: request?.location ?? '');
    _modality = request?.modality ?? RequestModality.remoto;
    _status = request?.status ?? RequestStatus.abierta;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _budgetLabelController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final parsedBudget =
          double.tryParse(
            _budgetLabelController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0;
      if (_isEditing) {
        final updated = widget.request!.copyWith(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          shortDescription: _shortDescriptionController.text.trim(),
          description: _descriptionController.text.trim(),
          budgetLabel: _budgetLabelController.text.trim(),
          budgetValue: parsedBudget,
          location: _locationController.text.trim(),
          modality: _modality,
          status: _status,
        );
        await _service.updateRequest(updated);
      } else {
        await _service.createRequest(
          requesterId: RequestsService.currentRequesterId,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          shortDescription: _shortDescriptionController.text.trim(),
          description: _descriptionController.text.trim(),
          budgetValue: parsedBudget,
          budgetLabel: _budgetLabelController.text.trim(),
          location: _locationController.text.trim(),
          modality: _modality,
          status: _status,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MultiLanguages.of(context)?.translate('could_not_save') ?? 'No se pudo guardar'}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiStepFormScaffold(
      title: _isEditing
          ? (MultiLanguages.of(context)?.translate('requests_edit_title') ??
                'Editar solicitud')
          : (MultiLanguages.of(context)?.translate('requests_new_title') ??
                'Nueva solicitud'),
      stepTitles: const <String>['General', 'Descripcion', 'Modalidad'],
      currentStep: _currentStep,
      onClose: () => Navigator.pop(context),
      onBack: _currentStep == 0 ? null : () => setState(() => _currentStep--),
      onNext: _saving ? null : _onNext,
      isLastStep: _currentStep == 2,
      isLoading: _saving,
      submitLabel: _isEditing
          ? (MultiLanguages.of(context)?.translate('save_changes') ??
                'Guardar cambios')
          : (MultiLanguages.of(context)?.translate('requests_create_button') ??
                'Crear solicitud'),
      child: _stepContent(),
    );
  }

  Future<void> _onNext() async {
    final valid = _stepKeys[_currentStep].currentState?.validate() ?? true;
    if (!valid) {
      _showStepValidationDialog();
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      return;
    }

    await _save();
  }

  void _showStepValidationDialog() {
    Dialogs.showSimpleDialog(
      context,
      title: MultiLanguages.of(context)?.translate('error') ?? 'Error',
      message:
          'No puedes avanzar porque faltan campos requeridos por completar.',
      color: Style.getErrorColor(),
      icon: Icons.error_outline_rounded,
    );
  }

  Widget _stepContent() {
    if (_currentStep == 0) {
      return Form(
        key: _stepKeys[0],
        child: Column(
          children: [
            _field(
              controller: _titleController,
              label:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_field_title') ??
                  'Titulo',
              hint: 'Necesitamos un sitio web...',
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _categoryController,
              label:
                  MultiLanguages.of(context)?.translate('services_category') ??
                  'Categoria',
              hint: 'Desarrollo Web',
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _budgetLabelController,
              label:
                  MultiLanguages.of(context)?.translate('requests_budget') ??
                  'Presupuesto',
              hint: r'$1,500',
            ),
          ],
        ),
      );
    }

    if (_currentStep == 1) {
      return Form(
        key: _stepKeys[1],
        child: Column(
          children: [
            _field(
              controller: _shortDescriptionController,
              label:
                  MultiLanguages.of(
                    context,
                  )?.translate('requests_short_description') ??
                  'Descripcion resumida',
              hint:
                  MultiLanguages.of(
                    context,
                  )?.translate('requests_hint_short_description') ??
                  'Resumen breve de la solicitud',
              maxLines: 3,
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _descriptionController,
              label:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_full_description') ??
                  'Descripcion completa',
              hint:
                  MultiLanguages.of(
                    context,
                  )?.translate('requests_hint_full_description') ??
                  'Explica lo que necesitas',
              maxLines: 6,
            ),
          ],
        ),
      );
    }

    return Form(
      key: _stepKeys[2],
      child: Column(
        children: [
          _field(
            controller: _locationController,
            label:
                MultiLanguages.of(context)?.translate('location') ??
                'Ubicacion',
            hint: 'Remoto',
          ),
          SizedBox(height: 14.h),
          CustomPickerField<RequestModality>(
            label:
                MultiLanguages.of(context)?.translate('services_modality') ??
                'Modalidad',
            value: _modality,
            items: RequestModality.values
                .map(
                  (modality) => CustomPickerOption(
                    value: modality,
                    label: modality.label,
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _modality = value);
            },
          ),
          SizedBox(height: 14.h),
          CustomPickerField<RequestStatus>(
            label: MultiLanguages.of(context)?.translate('status') ?? 'Estado',
            value: _status,
            items: RequestStatus.values
                .map(
                  (status) =>
                      CustomPickerOption(value: status, label: status.label),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _status = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return CustomInputField(
      controller: controller,
      label: label,
      hintText: hint,
      maxLines: maxLines,
      requiredField: true,
      validator: (value) => (value == null || value.trim().isEmpty)
          ? (MultiLanguages.of(context)?.translate('field_required') ??
                'Campo requerido')
          : null,
    );
  }
}
