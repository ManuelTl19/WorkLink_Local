import 'package:flutter/services.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/custom_input_field.dart';

class CustomNumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool requiredField;
  final bool enabled;
  final bool readOnly;

  const CustomNumberInputField({
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
      keyboardType: TextInputType.number,
      requiredField: requiredField,
      enabled: enabled,
      readOnly: readOnly,
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
