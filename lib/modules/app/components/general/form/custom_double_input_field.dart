import 'package:flutter/services.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/custom_input_field.dart';

class CustomDoubleInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool requiredField;
  final bool enabled;
  final bool readOnly;

  const CustomDoubleInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.requiredField = false,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: controller,
      label: label,
      hintText: hintText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      requiredField: requiredField,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    );
  }
}
