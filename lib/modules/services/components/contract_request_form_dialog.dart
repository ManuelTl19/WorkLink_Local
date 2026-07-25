import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';

class ContractRequestFormDialog extends StatefulWidget {
  const ContractRequestFormDialog({
    super.key,
    required this.serviceTitle,
  });

  final String serviceTitle;

  @override
  State<ContractRequestFormDialog> createState() =>
      _ContractRequestFormDialogState();
}

class _ContractRequestFormDialogState extends State<ContractRequestFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _budgetFocus = FocusNode();

  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _descriptionFocus.dispose();
    _budgetFocus.dispose();
    super.dispose();
  }

  String? _validateDescription(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'La descripcion es obligatoria.';
    if (text.length < 8) return 'Agrega mas detalle en la descripcion.';
    return null;
  }

  String? _validateBudget(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) return 'Ingresa un numero valido.';
    if (parsed <= 0) return 'El presupuesto debe ser mayor a 0.';

    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _submitting = true);

    final rawBudget = _budgetController.text.trim();
    final budget = rawBudget.isEmpty
        ? null
        : double.tryParse(rawBudget.replaceAll(',', '.'));

    if (!mounted) return;
    Navigator.pop(context, {
      'description': _descriptionController.text.trim(),
      'budget': budget,
    });
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
                      'Solicitar contratacion',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completa tu solicitud para enviar una propuesta clara al freelancer.',
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      CustomFormSection(
                        title: 'Necesidad del servicio',
                        subtitle:
                            'Explica el objetivo, alcance y prioridad de tu solicitud.',
                        children: [
                          CustomInputField(
                            controller: _descriptionController,
                            focusNode: _descriptionFocus,
                            label: 'Descripcion',
                            hintText: 'Necesito este servicio para...',
                            requiredField: true,
                            validator: _validateDescription,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 4,
                            maxLines: 6,
                            maxLength: 500,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomFormSection(
                        title: 'Presupuesto',
                        subtitle:
                            'Campo opcional para establecer una referencia económica.',
                        children: [
                          CustomDoubleInputField(
                            controller: _budgetController,
                            label: 'Presupuesto estimado (opcional)',
                            hintText: 'Ej. 1200',
                            validator: _validateBudget,
                          ),
                          SizedBox(height: 12.h),
                          CustomFormCard(
                            child: Text(
                              'Servicio: ${widget.serviceTitle}',
                              style: Style.getTextStyle(
                                color: Style.getObscureTextColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                primaryLabel: 'Enviar solicitud',
                onPrimary: _submit,
                loading: _submitting,
                secondaryLabel: 'Cancelar',
                onSecondary: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
