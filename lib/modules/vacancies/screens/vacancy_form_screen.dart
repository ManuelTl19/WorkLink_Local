import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';

class VacancyFormScreen extends StatefulWidget {
  const VacancyFormScreen({super.key, this.vacancy, this.companyId});

  final VacancyModel? vacancy;
  final int? companyId;

  @override
  State<VacancyFormScreen> createState() => _VacancyFormScreenState();
}

class _VacancyFormScreenState extends State<VacancyFormScreen> {
  final VacanciesService _service = VacanciesService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  late VacancyStatus _status;
  bool _saving = false;

  bool get _isEditing => widget.vacancy != null;

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
    if (!_formKey.currentState!.validate()) return;

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
          companyId: widget.companyId ?? VacanciesService.currentCompanyId,
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
        SnackBar(content: Text('No se pudo guardar la vacante: $e')),
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
              _isEditing ? 'Editar vacante' : 'Nueva vacante',
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
                      hint: 'Senior Flutter Developer',
                    ),
                    SizedBox(height: 14.h),
                    _field(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint: 'Describe el rol, responsabilidades y requisitos',
                      maxLines: 5,
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
                            controller: _locationController,
                            label: 'Ubicación',
                            hint: 'Remoto',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _salaryController,
                            label: 'Salario',
                            hint: 'MXN \$40,000 - \$60,000',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomPickerField<VacancyStatus>(
                            label: 'Estado',
                            value: _status,
                            items: VacancyStatus.values
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
                        ),
                      ],
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
                              _isEditing ? 'Guardar cambios' : 'Crear vacante',
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
