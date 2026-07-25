import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';

class VacancyFormScreen extends StatefulWidget {
  const VacancyFormScreen({super.key, this.vacancy, this.companyId});

  final VacancyModel? vacancy;
  final int? companyId;

  @override
  State<VacancyFormScreen> createState() => _VacancyFormScreenState();
}

class _VacancyFormScreenState extends State<VacancyFormScreen> {
  final VacanciesService _service = VacanciesService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  late VacancyStatus _status;

  bool _saving = false;

  bool get _isEditing => widget.vacancy != null;
  bool get _isClosed => widget.vacancy?.status == VacancyStatus.cerrada;
  List<VacancyStatus> get _statusOptions => _isEditing
      ? VacancyStatus.values
      : const <VacancyStatus>[VacancyStatus.abierta, VacancyStatus.pausada];

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
    _salaryController = TextEditingController(text: widget.vacancy?.salary ?? '');
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
    if (_saving || _isClosed) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

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
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Style.getTextColor(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? (MultiLanguages.of(context)?.translate(
                                    'vacancies_edit_title',
                                  ) ??
                                'Editar vacante')
                          : (MultiLanguages.of(context)?.translate(
                                    'vacancies_new_title',
                                  ) ??
                                'Nueva vacante'),
                      textAlign: TextAlign.center,
                      style: Style.getHeaderThree(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 12.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(
                        controller: _titleController,
                        label: MultiLanguages.of(context)
                                ?.translate('services_field_title') ??
                            'Titulo',
                        hint: 'Senior Flutter Developer',
                        enabled: !_isClosed,
                      ),
                      SizedBox(height: 14.h),
                      _field(
                        controller: _descriptionController,
                        label: MultiLanguages.of(context)
                                ?.translate('description') ??
                            'Descripcion',
                        hint: 'Describe el rol, responsabilidades y requisitos',
                        maxLines: 5,
                        enabled: !_isClosed,
                      ),
                      SizedBox(height: 14.h),
                      _field(
                        controller: _categoryController,
                        label: MultiLanguages.of(context)
                                ?.translate('services_category') ??
                            'Categoria',
                        hint: 'Desarrollo Movil',
                        enabled: !_isClosed,
                      ),
                      SizedBox(height: 14.h),
                      _field(
                        controller: _locationController,
                        label: MultiLanguages.of(context)?.translate('location') ??
                            'Ubicacion',
                        hint: 'Remoto',
                        enabled: !_isClosed,
                      ),
                      SizedBox(height: 14.h),
                      _field(
                        controller: _salaryController,
                        label: MultiLanguages.of(context)?.translate('salary') ??
                            'Salario',
                        hint: 'Ej. 22000.00',
                        enabled: !_isClosed,
                        requiredField: false,
                        validator: (value) {
                          final raw = (value ?? '').trim();
                          if (raw.isEmpty) return null;

                          final sanitized = raw
                              .replaceAll(RegExp(r'[^0-9,\.]'), '')
                              .replaceAll(',', '.');
                          final parsed = double.tryParse(sanitized);
                          if (parsed == null) {
                            return 'Ingresa un salario numerico valido.';
                          }
                          if (parsed < 0) {
                            return 'El salario no puede ser negativo.';
                          }
                          if (parsed > 9999999999.99) {
                            return 'El salario excede el maximo permitido.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),
                      CustomPickerField<VacancyStatus>(
                        label: MultiLanguages.of(context)?.translate('status') ??
                            'Estado',
                        value: _status,
                        enabled: !_isClosed,
                        items: _statusOptions
                            .map(
                              (status) => CustomPickerOption(
                                value: status,
                                label: status.label,
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _status = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
              decoration: BoxDecoration(
                color: Style.getBackgroundColor(),
                border: Border(
                  top: BorderSide(
                    color: Style.getBorderColor().withValues(alpha: .2),
                  ),
                ),
              ),
              child: CustomFormButtons(
                primaryLabel: _isEditing
                    ? (MultiLanguages.of(context)?.translate('save_changes') ??
                          'Guardar cambios')
                    : (MultiLanguages.of(context)
                                ?.translate('vacancies_create_button') ??
                          'Crear vacante'),
                onPrimary: _save,
                loading: _saving,
                secondaryLabel:
                    MultiLanguages.of(context)?.translate('cancel') ?? 'Cancelar',
                onSecondary: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
    bool requiredField = true,
    String? Function(String?)? validator,
  }) {
    return CustomInputField(
      controller: controller,
      label: label,
      hintText: hint,
      maxLines: maxLines,
      enabled: enabled,
      requiredField: requiredField,
      validator: validator ??
          (value) =>
              (requiredField && (value == null || value.trim().isEmpty))
                  ? (MultiLanguages.of(context)?.translate('field_required') ??
                      'Campo requerido')
                  : null,
    );
  }
}
