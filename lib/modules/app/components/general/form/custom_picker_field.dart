import 'package:worklink_local/helpers/helpers.dart';

class CustomPickerOption<T> {
  final T value;
  final String label;
  final Widget? child;

  const CustomPickerOption({
    required this.value,
    required this.label,
    this.child,
  });
}

class CustomPickerField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<CustomPickerOption<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool readOnly;
  final bool requiredField;
  final bool showError;
  final String? errorText;

  const CustomPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.requiredField = false,
    this.showError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValidator =
        validator ??
        (requiredField
            ? (selected) => selected == null ? 'Campo requerido' : null
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Style.getHeaderThree(
              color: Style.getObscureTextColor(),
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: label),
              if (requiredField)
                TextSpan(
                  text: ' *',
                  style: Style.getHeaderThree(
                    color: Style.getErrorColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<T>(
          value: value,
          validator: effectiveValidator,
          onChanged: enabled && !readOnly ? onChanged : null,
          iconEnabledColor: Style.getPrimaryColor(),
          dropdownColor: Style.getCardColor(),
          decoration: InputDecoration(
            hintText: hintText ?? label,
            errorText: showError ? errorText : null,
            filled: true,
            fillColor: Style.getCardColor().withValues(alpha: .16),
            border: OutlineInputBorder(
              borderRadius: Style.getBorderRadius(),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Style.getBorderRadius(),
              borderSide: BorderSide(color: Style.getFormFieldBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Style.getBorderRadius(),
              borderSide: BorderSide(
                color: Style.getPrimaryColor(),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: Style.getBorderRadius(),
              borderSide: BorderSide(color: Style.getErrorColor(), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: Style.getBorderRadius(),
              borderSide: BorderSide(color: Style.getErrorColor(), width: 1.4),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 15.h,
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: item.child ?? Text(item.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
