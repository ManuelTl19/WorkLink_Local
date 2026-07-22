import 'package:flutter/services.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool requiredField;
  final bool showError;
  final int maxLines;
  final int minLines;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  const CustomInputField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredField = false,
    this.showError = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.contentPadding,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.textStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValidator =
        validator ??
        (requiredField
            ? (value) => (value ?? '').trim().isEmpty ? 'Campo requerido' : null
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style:
                labelStyle ??
                Style.getHeaderThree(
                  color: Style.getObscureTextColor(),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
        ],
        Flexible(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            onTap: onTap,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            validator: effectiveValidator,
            inputFormatters: inputFormatters,
            style:
                textStyle ??
                Style.getTextStyle(color: Style.getTextColor(), fontSize: 10),
            decoration: InputDecoration(
              hintText: hintText ?? label,
              helperText: helperText,
              errorText: showError ? errorText : null,
              hintStyle: Style.getHintStyle(
                color: Style.getObscureTextColor(),
                fontSize: 10,
              ),
              filled: true,
              fillColor: Style.getCardColor().withValues(alpha: .16),
              border: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide(
                  color: Style.getBorderColor().withValues(alpha: .08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide(
                  color: Style.getPrimaryColor(),
                  width: 1.2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: Style.getBorderRadius(),
                borderSide: BorderSide(
                  color: Style.getBorderColor().withValues(alpha: .08),
                ),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
            ),
          ),
        ),
      ],
    );
  }
}
