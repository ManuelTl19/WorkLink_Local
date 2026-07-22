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
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;
  late ServiceStatus _status;
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
    if (!_formKey.currentState!.validate()) return;

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
              _isEditing
                  ? (MultiLanguages.of(
                          context,
                        )?.translate('services_edit_title') ??
                        'Editar servicio')
                  : (MultiLanguages.of(
                          context,
                        )?.translate('services_new_title') ??
                        'Nuevo servicio'),
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
                      label:
                          MultiLanguages.of(
                            context,
                          )?.translate('services_field_title') ??
                          'Título',
                      hint:
                          MultiLanguages.of(
                            context,
                          )?.translate('services_hint_title') ??
                          'Servicio principal',
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _categoryController,
                            label:
                                MultiLanguages.of(
                                  context,
                                )?.translate('services_category') ??
                                'Categoría',
                            hint:
                                MultiLanguages.of(
                                  context,
                                )?.translate('services_hint_category') ??
                                'Desarrollo móvil',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _field(
                            controller: _priceController,
                            label:
                                MultiLanguages.of(
                                  context,
                                )?.translate('services_price') ??
                                'Precio',
                            hint: '8500',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _descriptionController,
                      label:
                          MultiLanguages.of(
                            context,
                          )?.translate('services_full_description') ??
                          'Descripción completa',
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
                          'Ubicación',
                      hint:
                          MultiLanguages.of(context)?.translate('remote') ??
                          'Remoto',
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
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
                                  MultiLanguages.of(
                                        context,
                                      )?.translate('status') ??
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
                            activeColor: Style.getPrimaryColor(),
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
                                  ? (MultiLanguages.of(
                                          context,
                                        )?.translate('save_changes') ??
                                        'Guardar cambios')
                                  : (MultiLanguages.of(context)?.translate(
                                          'services_create_button',
                                        ) ??
                                        'Crear servicio'),
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
      validator: (value) => (value == null || value.trim().isEmpty)
          ? (MultiLanguages.of(context)?.translate('field_required') ??
                'Campo requerido')
          : null,
    );
  }
}
