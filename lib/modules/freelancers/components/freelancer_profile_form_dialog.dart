import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/utils/utils.dart';

class FreelancerProfileFormDialog extends StatefulWidget {
  const FreelancerProfileFormDialog({
    super.key,
    this.initialProfile,
    this.isEditing = false,
  });

  final FreelancerModel? initialProfile;
  final bool isEditing;

  @override
  State<FreelancerProfileFormDialog> createState() =>
      _FreelancerProfileFormDialogState();
}

class _FreelancerProfileFormDialogState
    extends State<FreelancerProfileFormDialog> {
  late final TextEditingController _specialtyController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rateController;
  late final TextEditingController _locationController;
  late final TextEditingController _serviceAreaController;
  late final TextEditingController _workModeController;
  late final TextEditingController _experienceController;
  late final TextEditingController _rateTypeController;
  late final TextEditingController _languagesController;
  late final TextEditingController _websiteController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _githubController;
  late final TextEditingController _portfolioUrlController;

  late final FocusNode _specialtyFocus;
  late final FocusNode _descriptionFocus;
  late final FocusNode _rateFocus;
  late final FocusNode _locationFocus;

  final GlobalKey<FormState> _baseStepKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _optionsStepKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isAvailable = true;
  bool _isLoading = false;
  bool _showOptionsInlineErrors = false;
  String? _selectedRateType;
  String? _selectedWorkMode;
  String? _selectedLanguage;
  final List<String> _selectedLanguages = [];

  static const List<String> _rateTypeOptions = ['hourly', 'project', 'negotiable'];
  static const List<String> _workModeOptions = [
    'remote',
    'on_site',
    'hybrid',
    'home_service',
  ];
  static const List<String> _languageOptions = [
    'Spanish',
    'English',
    'Portuguese',
    'French',
    'German',
    'Italian',
    'Dutch',
    'Swedish',
    'Danish',
    'Norwegian',
    'Finnish',
    'Polish',
    'Turkish',
    'Arabic',
    'Hindi',
    'Japanese',
    'Korean',
    'Mandarin',
    'Russian',
    'Ukrainian',
  ];

  static const Map<String, String> _languageEs = {
    'Spanish': 'Espanol',
    'English': 'Ingles',
    'Portuguese': 'Portugues',
    'French': 'Frances',
    'German': 'Aleman',
    'Italian': 'Italiano',
    'Dutch': 'Neerlandes',
    'Swedish': 'Sueco',
    'Danish': 'Danes',
    'Norwegian': 'Noruego',
    'Finnish': 'Finlandes',
    'Polish': 'Polaco',
    'Turkish': 'Turco',
    'Arabic': 'Arabe',
    'Hindi': 'Hindi',
    'Japanese': 'Japones',
    'Korean': 'Coreano',
    'Mandarin': 'Mandarin',
    'Russian': 'Ruso',
    'Ukrainian': 'Ucraniano',
  };

  bool get _isEnglish => Localizations.localeOf(context).languageCode == 'en';
  String _t(String es, String en) => _isEnglish ? en : es;

  @override
  void initState() {
    super.initState();
    _specialtyController = TextEditingController(
      text: widget.initialProfile?.specialty ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialProfile?.description ?? '',
    );
    _rateController = TextEditingController(
      text: widget.initialProfile?.hourlyRate.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialProfile?.location ?? '',
    );
    _serviceAreaController = TextEditingController(
      text: widget.initialProfile?.serviceArea ?? '',
    );
    _workModeController = TextEditingController(
      text: widget.initialProfile?.workMode ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.initialProfile?.experience ?? '',
    );
    _rateTypeController = TextEditingController(
      text: widget.initialProfile?.rateType ?? '',
    );
    _languagesController = TextEditingController();
    _websiteController = TextEditingController(
      text: widget.initialProfile?.website ?? '',
    );
    _facebookController = TextEditingController(
      text: widget.initialProfile?.facebook ?? '',
    );
    _instagramController = TextEditingController(
      text: widget.initialProfile?.instagram ?? '',
    );
    _linkedinController = TextEditingController(
      text: widget.initialProfile?.linkedin ?? '',
    );
    _githubController = TextEditingController(
      text: widget.initialProfile?.github ?? '',
    );
    _portfolioUrlController = TextEditingController(
      text: widget.initialProfile?.portfolioUrl ?? '',
    );

    _specialtyFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _rateFocus = FocusNode();
    _locationFocus = FocusNode();

    _isAvailable = widget.initialProfile?.available ?? true;
    _selectedRateType =
      _normalizeRateType(_rateTypeController.text) ?? 'negotiable';
    _rateTypeController.text = _selectedRateType ?? 'negotiable';
    _selectedWorkMode = _normalizeWorkMode(_workModeController.text);
    _selectedLanguages.addAll(
      (widget.initialProfile?.languages ?? const [])
          .map(_normalizeLanguage)
          .where((item) => item.isNotEmpty),
    );
    _languagesController.text = _selectedLanguages.join(', ');
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    _descriptionController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _serviceAreaController.dispose();
    _workModeController.dispose();
    _experienceController.dispose();
    _rateTypeController.dispose();
    _languagesController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioUrlController.dispose();
    _specialtyFocus.dispose();
    _descriptionFocus.dispose();
    _rateFocus.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  String? _normalizeRateType(String? value) {
    final raw = value?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;
    if (raw == 'hourly') return 'hourly';
    if (raw == 'project') return 'project';
    if (raw == 'negotiable') return 'negotiable';
    if (raw == 'por hora') return 'hourly';
    if (raw == 'por proyecto') return 'project';
    if (raw == 'negociable') return 'negotiable';
    return null;
  }

  String? _normalizeWorkMode(String? value) {
    final raw = value?.trim().toLowerCase();
    if (raw == null || raw.isEmpty) return null;
    if (raw == 'remote' || raw == 'remoto') return 'remote';
    if (raw == 'on_site' || raw == 'onsite' || raw == 'presencial') {
      return 'on_site';
    }
    if (raw == 'hybrid' || raw == 'hibrido' || raw == 'hibrida') {
      return 'hybrid';
    }
    if (raw == 'home_service' ||
        raw == 'servicio a domicilio' ||
        raw == 'a domicilio') {
      return 'home_service';
    }
    return null;
  }

  String _normalizeLanguage(String value) {
    final lower = value.trim().toLowerCase();
    for (final option in _languageOptions) {
      if (option.toLowerCase() == lower) return option;
    }
    for (final entry in _languageEs.entries) {
      if (entry.value.toLowerCase() == lower) return entry.key;
    }
    return value.trim();
  }

  String _rateTypeLabel(String value) {
    if (_isEnglish) {
      if (value == 'hourly') return 'Hourly';
      if (value == 'project') return 'Per project';
      return 'Negotiable';
    }
    if (value == 'hourly') return 'Por hora';
    if (value == 'project') return 'Por proyecto';
    return 'Negociable';
  }

  String _workModeLabel(String value) {
    if (_isEnglish) {
      if (value == 'remote') return 'Remote';
      if (value == 'on_site') return 'On-site';
      if (value == 'hybrid') return 'Hybrid';
      return 'Home service';
    }
    if (value == 'remote') return 'Remoto';
    if (value == 'on_site') return 'Presencial';
    if (value == 'hybrid') return 'Hibrido';
    return 'Servicio a domicilio';
  }

  String _languageLabel(String value) {
    if (_isEnglish) return value;
    return _languageEs[value] ?? value;
  }

  bool get _isNegotiableRate =>
      (_selectedRateType ?? '').toLowerCase().trim() == 'negotiable';

  String _rateLabelByType() {
    if ((_selectedRateType ?? '').toLowerCase().trim() == 'project') {
      return _t('Tarifa por proyecto', 'Project rate');
    }
    return _t('Tarifa por hora', 'Hourly rate');
  }

  String _rateHintByType() {
    if ((_selectedRateType ?? '').toLowerCase().trim() == 'project') {
      return _t('Ej. 150 por proyecto', 'Example: 150 per project');
    }
    return _t('Ej. 25 por hora', 'Example: 25 per hour');
  }

  String? _validateSpecialty(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    if (text.length < 3) return _t('Minimo 3 caracteres', 'Minimum 3 characters');
    if (text.length > 100) return _t('Maximo 100 caracteres', 'Maximum 100 characters');
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    if (text.length < 10) return _t('Minimo 10 caracteres', 'Minimum 10 characters');
    if (text.length > 1000) return _t('Maximo 1000 caracteres', 'Maximum 1000 characters');
    return null;
  }

  String? _validateRate(String? value) {
    if ((_selectedRateType ?? '').toLowerCase().trim() == 'negotiable') {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      final optionalRate = double.tryParse(text);
      if (optionalRate == null) {
        return _t('Ingresa un numero valido', 'Enter a valid number');
      }
      if (optionalRate < 0) {
        return _t('La tarifa no puede ser negativa', 'Rate cannot be negative');
      }
      return null;
    }

    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    final rate = double.tryParse(text);
    if (rate == null) return _t('Ingresa un numero valido', 'Enter a valid number');
    if (rate <= 0) return _t('La tarifa debe ser mayor a 0', 'Rate must be greater than 0');
    if (rate > 9999) return _t('La tarifa debe ser menor a 9999', 'Rate must be less than 9999');
    return null;
  }

  String? _validateLocation(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    if (text.length < 3) return _t('Minimo 3 caracteres', 'Minimum 3 characters');
    if (text.length > 100) return _t('Maximo 100 caracteres', 'Maximum 100 characters');
    return null;
  }

  String? _validateServiceArea(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    if (text.length < 3) return _t('Minimo 3 caracteres', 'Minimum 3 characters');
    if (text.length > 120) return _t('Maximo 120 caracteres', 'Maximum 120 characters');
    return null;
  }

  String? _validateExperience(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _t('Campo requerido', 'Required field');
    if (text.length < 5) return _t('Minimo 5 caracteres', 'Minimum 5 characters');
    if (text.length > 500) return _t('Maximo 500 caracteres', 'Maximum 500 characters');
    return null;
  }

  List<String> _missingFieldsForStep(int step) {
    final missing = <String>[];

    if (step == 0) {
      if ((_validateSpecialty(_specialtyController.text) ?? '').isNotEmpty) {
        missing.add(_t('Especialidad valida', 'Valid specialty'));
      }
      if ((_validateDescription(_descriptionController.text) ?? '').isNotEmpty) {
        missing.add(_t('Descripcion valida', 'Valid description'));
      }
      if ((_validateLocation(_locationController.text) ?? '').isNotEmpty) {
        missing.add(_t('Ubicacion valida', 'Valid location'));
      }
    }

    if (step == 1) {
      if (_selectedRateType == null || _selectedRateType!.isEmpty) {
        missing.add(_t('Tipo de tarifa', 'Rate type'));
      }
      if ((_validateRate(_rateController.text) ?? '').isNotEmpty) {
        missing.add(_t('Tarifa valida', 'Valid rate'));
      }
      if (_selectedWorkMode == null || _selectedWorkMode!.isEmpty) {
        missing.add(_t('Modalidad', 'Work mode'));
      }
      if ((_validateServiceArea(_serviceAreaController.text) ?? '').isNotEmpty) {
        missing.add(_t('Area de servicio valida', 'Valid service area'));
      }
      if ((_validateExperience(_experienceController.text) ?? '').isNotEmpty) {
        missing.add(_t('Experiencia valida', 'Valid experience'));
      }
    }

    return missing;
  }

  Future<bool> _validateCurrentStep() async {
    if (_currentStep == 0) {
      final isValid = _baseStepKey.currentState?.validate() ?? false;
      if (!isValid) {
        await _showMissingDialog(_missingFieldsForStep(_currentStep));
        return false;
      }
    }

    if (_currentStep == 1) {
      if (!_showOptionsInlineErrors && mounted) {
        setState(() => _showOptionsInlineErrors = true);
      }

      final optionsValid = _optionsStepKey.currentState?.validate() ?? false;
      if (!optionsValid) {
        await _showMissingDialog(_missingFieldsForStep(_currentStep));
        return false;
      }
    }

    final missing = _missingFieldsForStep(_currentStep);
    if (missing.isNotEmpty) {
      await _showMissingDialog(missing);
      return false;
    }

    return true;
  }

  Future<void> _showMissingDialog(List<String> missing) async {
    if (missing.isEmpty || !mounted) return;
    await Dialogs.showSimpleDialog(
      context,
      title: _t('Faltan campos en este paso', 'Missing fields in this step'),
      message: missing.map((item) => '- $item').join('\n'),
      color: Style.getErrorColor(),
      icon: Icons.warning_amber_rounded,
    );
  }

  void _addLanguage(String? lang) {
    if (lang == null || lang.isEmpty) return;

    setState(() {
      if (!_selectedLanguages.contains(lang)) {
        _selectedLanguages.add(lang);
      }
      _languagesController.text = _selectedLanguages.join(', ');
      _selectedLanguage = null;
      if (_selectedLanguages.isNotEmpty) {
        _showOptionsInlineErrors = false;
      }
    });
  }

  void _removeLanguage(String lang) {
    setState(() {
      _selectedLanguages.remove(lang);
      _languagesController.text = _selectedLanguages.join(', ');
    });
  }

  Widget _textField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
    void Function(String)? onFieldSubmitted,
    bool requiredField = false,
  }) {
    return CustomInputField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hintText: hint,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      requiredField: requiredField,
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Style.getPrimaryColor(),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: Style.getHeaderThree(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Form(
        key: _baseStepKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(_t('Informacion profesional', 'Professional information')),
            SizedBox(height: 14.h),
            _textField(
              controller: _specialtyController,
              focusNode: _specialtyFocus,
              label: MultiLanguages.of(context)!.translate('specialty'),
              hint: MultiLanguages.of(context)!.translate('specialty_hint'),
              validator: _validateSpecialty,
              onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
              requiredField: true,
            ),
            SizedBox(height: 14.h),
            _textField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              label: MultiLanguages.of(context)!.translate('description'),
              hint: MultiLanguages.of(context)!.translate('description_hint'),
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: 5,
              validator: _validateDescription,
              onFieldSubmitted: (_) => _locationFocus.requestFocus(),
              requiredField: true,
            ),
            SizedBox(height: 14.h),
            _textField(
              controller: _locationController,
              focusNode: _locationFocus,
              label: MultiLanguages.of(context)!.translate('location'),
              hint: MultiLanguages.of(context)!.translate('location_hint'),
              validator: _validateLocation,
              requiredField: true,
            ),
          ],
        ),
      );
    }

    if (_currentStep == 1) {
      return Form(
        key: _optionsStepKey,
        autovalidateMode: _showOptionsInlineErrors
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(_t('Condiciones de trabajo', 'Work conditions')),
            SizedBox(height: 14.h),
            CustomPickerField<String>(
              label: _t('Tipo de tarifa', 'Rate type'),
              value: _selectedRateType,
              hintText: _t('Selecciona una opcion', 'Select an option'),
              requiredField: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _t('Campo requerido', 'Required field');
                }
                return null;
              },
              items: _rateTypeOptions
                  .map(
                    (option) => CustomPickerOption<String>(
                      value: option,
                      label: _rateTypeLabel(option),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRateType = value;
                  _rateTypeController.text = value ?? '';
                  if (_isNegotiableRate) {
                    _rateController.clear();
                  }
                });
              },
            ),
            if (!_isNegotiableRate) ...[
              SizedBox(height: 14.h),
              _textField(
                controller: _rateController,
                focusNode: _rateFocus,
                label: _rateLabelByType(),
                hint: _rateHintByType(),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                validator: _validateRate,
                requiredField: true,
              ),
            ],
            SizedBox(height: 14.h),
            CustomPickerField<String>(
              label: _t('Modalidad', 'Work mode'),
              value: _selectedWorkMode,
              hintText: _t('Selecciona una opcion', 'Select an option'),
              requiredField: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return _t('Campo requerido', 'Required field');
                }
                return null;
              },
              items: _workModeOptions
                  .map(
                    (option) => CustomPickerOption<String>(
                      value: option,
                      label: _workModeLabel(option),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorkMode = value;
                  _workModeController.text = value ?? '';
                });
              },
            ),
            SizedBox(height: 14.h),
            CustomPickerField<String>(
              key: ValueKey<String?>(_selectedLanguage),
              label: _t('Idiomas', 'Languages'),
              value: _selectedLanguage,
              hintText: _t('Selecciona y agrega', 'Select and add'),
              items: _languageOptions
                  .map(
                    (option) => CustomPickerOption<String>(
                      value: option,
                      label: _languageLabel(option),
                    ),
                  )
                  .toList(),
              onChanged: _addLanguage,
            ),
            SizedBox(height: 10.h),
            if (_selectedLanguages.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    _t(
                      'Agrega idiomas si quieres mostrarlos en tu perfil.',
                      'Add languages if you want to display them on your profile.',
                    ),
                  style: Style.getTextStyle(
                      color: Style.getObscureTextColor(),
                  ),
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _selectedLanguages
                      .map(
                        (lang) => Chip(
                          label: Text(_languageLabel(lang)),
                          onDeleted: () => _removeLanguage(lang),
                        ),
                      )
                      .toList(),
                ),
              ),
            SizedBox(height: 14.h),
            _textField(
              controller: _serviceAreaController,
              label: _t('Area de servicio', 'Service area'),
              hint: _t(
                'Ej. Desarrollo web y apps empresariales',
                'Example: Web and business app development',
              ),
              validator: _validateServiceArea,
              requiredField: true,
            ),
            SizedBox(height: 14.h),
            _textField(
              controller: _experienceController,
              label: _t('Experiencia', 'Experience'),
              hint: _t(
                'Ej. Tres anos desarrollando apps',
                'Example: Three years building apps',
              ),
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 4,
              validator: _validateExperience,
              requiredField: true,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t('Enlaces y disponibilidad', 'Links and availability')),
        SizedBox(height: 14.h),
        _textField(
          controller: _websiteController,
          label: 'Website',
          hint: 'https://tu-sitio.com',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        _textField(
          controller: _facebookController,
          label: 'Facebook',
          hint: 'https://facebook.com/usuario',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        _textField(
          controller: _instagramController,
          label: 'Instagram',
          hint: 'https://instagram.com/usuario',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        _textField(
          controller: _linkedinController,
          label: 'LinkedIn',
          hint: 'https://linkedin.com/in/usuario',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        _textField(
          controller: _githubController,
          label: 'GitHub',
          hint: 'https://github.com/usuario',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        _textField(
          controller: _portfolioUrlController,
          label: 'URL de portafolio',
          hint: 'https://behance.net/usuario',
          keyboardType: TextInputType.url,
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Style.getBackgroundColor(),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Style.getBorderColor().withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: _isAvailable
                    ? Style.getPrimaryColor()
                    : Style.getObscureTextColor(),
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MultiLanguages.of(context)!.translate('available'),
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _isAvailable
                          ? _t('Clientes pueden verte', 'Clients can see you')
                          : _t('No visible para clientes', 'Hidden from clients'),
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
                activeThumbColor: Style.getPrimaryColor(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_currentStep != 2) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final allMissing = <String>[
        ..._missingFieldsForStep(0),
        ..._missingFieldsForStep(1),
      ];
      if (allMissing.isNotEmpty) {
        await _showMissingDialog(allMissing);
        return;
      }

        final parsedRate = ((_selectedRateType ?? '').toLowerCase().trim() == 'negotiable')
          ? 0.0
          : double.parse(_rateController.text);

      final profile = FreelancerModel(
        id: widget.initialProfile?.id,
        userId: widget.initialProfile?.userId,
        fullName: widget.initialProfile?.fullName ?? '',
        specialty: _specialtyController.text.trim(),
        description: _descriptionController.text.trim(),
        hourlyRate: parsedRate,
        available: _isAvailable,
        location: _locationController.text.trim(),
        avatarUrl: widget.initialProfile?.avatarUrl ?? '',
        averageRate: widget.initialProfile?.averageRate,
        serviceArea: _serviceAreaController.text.trim().isEmpty
            ? null
            : _serviceAreaController.text.trim(),
        workMode: _selectedWorkMode,
        experience: _experienceController.text.trim().isEmpty
            ? null
            : _experienceController.text.trim(),
        rateType: _selectedRateType,
        languages: _selectedLanguages,
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        facebook: _facebookController.text.trim().isEmpty
            ? null
            : _facebookController.text.trim(),
        instagram: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        linkedin: _linkedinController.text.trim().isEmpty
            ? null
            : _linkedinController.text.trim(),
        github: _githubController.text.trim().isEmpty
            ? null
            : _githubController.text.trim(),
        portfolioUrl: _portfolioUrlController.text.trim().isEmpty
            ? null
            : _portfolioUrlController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, profile);
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: MultiLanguages.of(context)!.translate('error'),
        message: e.toString(),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = MultiLanguages.of(context)!.translate(
      widget.isEditing
          ? 'edit_professional_profile'
          : 'create_professional_profile',
    );

    return MultiStepFormScaffold(
      title: title,
      stepTitles: <String>[
        _t('Basico', 'Basic'),
        _t('Opciones', 'Options'),
        _t('Enlaces', 'Links'),
      ],
      currentStep: _currentStep,
      onClose: () => Navigator.pop(context),
      onBack: _currentStep == 0 ? null : () => setState(() => _currentStep -= 1),
      onNext: _isLoading
          ? null
          : () async {
              if (_currentStep < 2) {
                final canContinue = await _validateCurrentStep();
                if (!canContinue) return;
                if (!mounted) return;
                setState(() => _currentStep += 1);
                return;
              }
              await _handleSubmit();
            },
      isLastStep: _currentStep == 2,
      isLoading: _isLoading,
      nextLabel: _t('Siguiente', 'Next'),
      submitLabel: MultiLanguages.of(context)!.translate('save'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MultiLanguages.of(context)!.translate(
              'complete_your_profile_description',
            ),
            style: Style.getTextStyle(color: Style.getObscureTextColor()),
          ),
          SizedBox(height: 14.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey<int>(_currentStep),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }
}
