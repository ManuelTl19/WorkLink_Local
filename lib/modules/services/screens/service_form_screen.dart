import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});

  final ServiceModel? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final ServicesService _service = ServicesService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceLabelController;
  late final TextEditingController _estimatedTimeController;
  late final TextEditingController _imageController;
  late final TextEditingController _tagsController;
  late ServiceModality _modality;
  late ServiceStatus _status;
  bool _saving = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _titleController = TextEditingController(text: service?.title ?? '');
    _categoryController = TextEditingController(text: service?.category ?? '');
    _shortDescriptionController = TextEditingController(
      text: service?.shortDescription ?? '',
    );
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _priceLabelController = TextEditingController(
      text: service?.priceLabel ?? '',
    );
    _estimatedTimeController = TextEditingController(
      text: service?.estimatedTime ?? '',
    );
    _imageController = TextEditingController(text: service?.mainImageUrl ?? '');
    _tagsController = TextEditingController(
      text: service?.tags.join(', ') ?? '',
    );
    _modality = service?.modality ?? ServiceModality.remoto;
    _status = service?.status ?? ServiceStatus.activo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    _priceLabelController.dispose();
    _estimatedTimeController.dispose();
    _imageController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (_isEditing) {
        final updated = widget.service!.copyWith(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          shortDescription: _shortDescriptionController.text.trim(),
          description: _descriptionController.text.trim(),
          priceLabel: _priceLabelController.text.trim(),
          estimatedTime: _estimatedTimeController.text.trim(),
          mainImageUrl: _imageController.text.trim(),
          tags: tags,
          modality: _modality,
          status: _status,
        );
        await _service.updateService(updated);
      } else {
        await _service.createService(
          freelancerId: ServicesService.currentFreelancerId,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          shortDescription: _shortDescriptionController.text.trim(),
          description: _descriptionController.text.trim(),
          priceValue:
              double.tryParse(
                _priceLabelController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0,
          priceLabel: _priceLabelController.text.trim(),
          modality: _modality,
          estimatedTime: _estimatedTimeController.text.trim(),
          status: _status,
          mainImageUrl: _imageController.text.trim(),
          tags: tags,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el servicio: $e')),
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
              _isEditing ? 'Editar servicio' : 'Nuevo servicio',
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
                      hint: 'Servicio principal',
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _categoryController,
                            label: 'Categoría',
                            hint: 'Desarrollo Móvil',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _field(
                            controller: _priceLabelController,
                            label: 'Precio',
                            hint: r'$45 / hora',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _shortDescriptionController,
                      label: 'Descripción corta',
                      hint: 'Resumen breve del servicio',
                      maxLines: 3,
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _descriptionController,
                      label: 'Descripción completa',
                      hint: 'Detalle completo del servicio',
                      maxLines: 6,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _estimatedTimeController,
                            label: 'Tiempo estimado',
                            hint: '2-4 semanas',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomPickerField<ServiceModality>(
                            label: 'Modalidad',
                            value: _modality,
                            items: ServiceModality.values
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
                    _field(
                      controller: _imageController,
                      label: 'Imagen principal',
                      hint: 'https://...',
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _tagsController,
                      label: 'Etiquetas',
                      hint: 'Flutter, Dart, API REST',
                      maxLines: 2,
                    ),
                    SizedBox(height: 14.h),
                    CustomPickerField<ServiceStatus>(
                      label: 'Estado',
                      value: _status,
                      items: ServiceStatus.values
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
                              _isEditing ? 'Guardar cambios' : 'Crear servicio',
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
