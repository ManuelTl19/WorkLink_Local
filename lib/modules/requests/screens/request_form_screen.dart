import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key, this.request});

  final WorkRequestModel? request;

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final RequestsService _service = RequestsService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _budgetLabelController;
  late final TextEditingController _locationController;
  late RequestModality _modality;
  late RequestStatus _status;
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
    if (!_formKey.currentState!.validate()) return;
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
        SnackBar(content: Text('No se pudo guardar la solicitud: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Style.getTextColor(),
              ),
            ),
            title: Text(
              _isEditing ? 'Editar solicitud' : 'Nueva solicitud',
              style: Style.getHeaderTwo(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Style.horizontalPadding.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(
                      controller: _titleController,
                      label: 'Título',
                      hint: 'Necesitamos un sitio web...',
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _categoryController,
                            label: 'Categoría',
                            hint: 'Desarrollo Web',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _field(
                            controller: _budgetLabelController,
                            label: 'Presupuesto',
                            hint: r'$1,500',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _shortDescriptionController,
                      label: 'Descripción resumida',
                      hint: 'Resumen breve de la solicitud',
                      maxLines: 3,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _descriptionController,
                      label: 'Descripción completa',
                      hint: 'Explica lo que necesitas',
                      maxLines: 6,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _locationController,
                            label: 'Ubicación',
                            hint: 'Remoto',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomPickerField<RequestModality>(
                            label: 'Modalidad',
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
                              if (value != null)
                                setState(() => _modality = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    CustomPickerField<RequestStatus>(
                      label: 'Estado',
                      value: _status,
                      items: RequestStatus.values
                          .map(
                            (status) => CustomPickerOption(
                              value: status,
                              label: status.label,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    SizedBox(height: 22.h),
                    CustomWidgets.button(
                      onTap: _saving ? () {} : _save,
                      color: Style.getPrimaryColor(),
                      child: _saving
                          ? SizedBox(
                              height: 18.w,
                              width: 18.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Style.white,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Guardar cambios'
                                  : 'Crear solicitud',
                              style: Style.getHeaderThree(
                                color: Style.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
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
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Campo requerido' : null,
    );
  }
}
