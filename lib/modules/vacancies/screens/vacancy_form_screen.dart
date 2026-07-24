import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class VacancyFormScreen extends StatefulWidget {
  const VacancyFormScreen({super.key, this.vacancy, this.companyId});

  final VacancyModel? vacancy;
  final int? companyId;

  @override
  State<VacancyFormScreen> createState() => _VacancyFormScreenState();
}

class _VacancyFormScreenState extends State<VacancyFormScreen> {
  final VacanciesService _service = VacanciesService();
  final List<GlobalKey<FormState>> _stepKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  late VacancyStatus _status;
  int _currentStep = 0;
  bool _saving = false;

  bool get _isEditing => widget.vacancy != null;
  bool get _isClosed => widget.vacancy?.status == VacancyStatus.cerrada;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.vacancy?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.vacancy?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.vacancy?.category ?? '',
    );
    _locationController = TextEditingController(
      text: widget.vacancy?.location ?? '',
    );
    _salaryController = TextEditingController(
      text: widget.vacancy?.salary ?? '',
    );
    _status = widget.vacancy?.status ?? VacancyStatus.abierta;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isEditing && _isClosed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MultiLanguages.of(context)?.translate('vacancy_closed') ??
                'La vacante está cerrada y no puede modificarse.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      if (_isEditing) {
        final vacancy = widget.vacancy!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          salary: _salaryController.text.trim(),
          status: _status,
        );
        await _service.updateVacancy(vacancy);
      } else {
        await _service.createVacancy(
          companyId: widget.companyId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          salary: _salaryController.text.trim(),
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
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiStepFormScaffold(
      title: _isEditing
          ? (MultiLanguages.of(context)?.translate('vacancies_edit_title') ??
                'Editar vacante')
          : (MultiLanguages.of(context)?.translate('vacancies_new_title') ??
                'Nueva vacante'),
      stepTitles: const <String>['Puesto', 'Condiciones', 'Estado'],
      currentStep: _currentStep,
      onClose: () => Navigator.pop(context),
      onBack: _currentStep == 0 ? null : () => setState(() => _currentStep--),
      onNext: (_saving || _isClosed) ? null : _onNext,
      isLastStep: _currentStep == 2,
      isLoading: _saving,
      submitLabel: _isEditing
          ? (MultiLanguages.of(context)?.translate('save_changes') ??
                'Guardar cambios')
          : (MultiLanguages.of(context)?.translate('vacancies_create_button') ??
                'Crear vacante'),
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
              hint: 'Senior Flutter Developer',
              enabled: !_isClosed,
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _descriptionController,
              label:
                  MultiLanguages.of(context)?.translate('description') ??
                  'Descripcion',
              hint: 'Describe el rol, responsabilidades y requisitos',
              maxLines: 5,
              enabled: !_isClosed,
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
              controller: _categoryController,
              label:
                  MultiLanguages.of(context)?.translate('services_category') ??
                  'Categoria',
              hint: 'Desarrollo Movil',
              enabled: !_isClosed,
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _locationController,
              label:
                  MultiLanguages.of(context)?.translate('location') ??
                  'Ubicacion',
              hint: 'Remoto',
              enabled: !_isClosed,
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _salaryController,
              label:
                  MultiLanguages.of(context)?.translate('salary') ?? 'Salario',
              hint: 'MXN \$40,000 - \$60,000',
              enabled: !_isClosed,
            ),
          ],
        ),
      );
    }

    return Form(
      key: _stepKeys[2],
      child: CustomPickerField<VacancyStatus>(
        label: MultiLanguages.of(context)?.translate('status') ?? 'Estado',
        value: _status,
        enabled: !_isClosed,
        items: VacancyStatus.values
            .map(
              (status) =>
                  CustomPickerOption(value: status, label: status.label),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _status = value);
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return CustomInputField(
      controller: controller,
      label: label,
      hintText: hint,
      maxLines: maxLines,
      enabled: enabled,
      requiredField: true,
      validator: (value) => (value == null || value.trim().isEmpty)
          ? (MultiLanguages.of(context)?.translate('field_required') ??
                'Campo requerido')
          : null,
    );
  }
}
