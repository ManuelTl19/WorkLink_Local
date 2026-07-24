import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});

  final ServiceModel? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final ServicesService _service = ServicesService();
  final List<GlobalKey<FormState>> _stepKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late ServiceStatus _status;
  int _currentStep = 0;
  bool _saving = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _titleController = TextEditingController(text: service?.title ?? '');
    _categoryController = TextEditingController(text: service?.category ?? '');
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _priceController = TextEditingController(
      text: service != null && service.priceValue > 0
          ? service.priceValue.toStringAsFixed(
              service.priceValue % 1 == 0 ? 0 : 2,
            )
          : '',
    );
    _locationController = TextEditingController(
      text: service?.location.isNotEmpty == true ? service!.location : 'Remoto',
    );
    _status = service?.status == ServiceStatus.activo
        ? ServiceStatus.activo
        : ServiceStatus.inactivo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final parsedPriceValue =
          double.tryParse(
            _priceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0;

      if (_isEditing) {
        final updated = widget.service!.copyWith(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          description: _descriptionController.text.trim(),
          priceValue: parsedPriceValue,
          status: _status,
        );
        await _service.updateService(updated);
      } else {
        final freelancerId = await _service.getCurrentFreelancerId();
        await _service.createService(
          freelancerId: freelancerId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priceValue: parsedPriceValue,
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          isActive: _status == ServiceStatus.activo,
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
          ? (MultiLanguages.of(context)?.translate('services_edit_title') ??
                'Editar servicio')
          : (MultiLanguages.of(context)?.translate('services_new_title') ??
                'Nuevo servicio'),
      stepTitles: const <String>['Basico', 'Detalle', 'Publicacion'],
      currentStep: _currentStep,
      onClose: () => Navigator.pop(context),
      onBack: _currentStep == 0 ? null : () => setState(() => _currentStep--),
      onNext: _saving ? null : _onNext,
      isLastStep: _currentStep == 2,
      isLoading: _saving,
      submitLabel: _isEditing
          ? (MultiLanguages.of(context)?.translate('save_changes') ??
                'Guardar cambios')
          : (MultiLanguages.of(context)?.translate('services_create_button') ??
                'Crear servicio'),
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
              hint:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_hint_title') ??
                  'Servicio principal',
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _categoryController,
              label:
                  MultiLanguages.of(context)?.translate('services_category') ??
                  'Categoria',
              hint:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_hint_category') ??
                  'Desarrollo movil',
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _priceController,
              label:
                  MultiLanguages.of(context)?.translate('services_price') ??
                  'Precio',
              hint: '8500',
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
              controller: _descriptionController,
              label:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_full_description') ??
                  'Descripcion completa',
              hint:
                  MultiLanguages.of(
                    context,
                  )?.translate('services_hint_full_description') ??
                  'Detalle completo del servicio',
              maxLines: 6,
            ),
            SizedBox(height: 14.h),
            _field(
              controller: _locationController,
              label:
                  MultiLanguages.of(context)?.translate('location') ??
                  'Ubicacion',
              hint: MultiLanguages.of(context)?.translate('remote') ?? 'Remoto',
            ),
          ],
        ),
      );
    }

    return Form(
      key: _stepKeys[2],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Style.getCardColor(),
              borderRadius: Style.getBorderRadius(),
              border: Border.all(color: Style.getBorderColor()),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MultiLanguages.of(context)?.translate('status') ??
                            'Estado',
                        style: Style.getTextStyle(
                          color: Style.getTextColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _status == ServiceStatus.activo
                            ? (MultiLanguages.of(
                                    context,
                                  )?.translate('active') ??
                                  'Activa')
                            : (MultiLanguages.of(
                                    context,
                                  )?.translate('inactive') ??
                                  'Inactiva'),
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _status == ServiceStatus.activo,
                  activeThumbColor: Style.getPrimaryColor(),
                  onChanged: (value) {
                    setState(() {
                      _status = value
                          ? ServiceStatus.activo
                          : ServiceStatus.inactivo;
                    });
                  },
                ),
              ],
            ),
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
