import 'package:intl/intl.dart';
import 'package:worklink_local/modules/app/components/general/form/custom_input_field.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomDatePickerField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool readOnly;
  final String? errorText;
  final bool showError;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.showError = false,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == null ? '' : DateFormat('dd/MM/yyyy').format(widget.value!),
    );
  }

  @override
  void didUpdateWidget(covariant CustomDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.value == null ? '' : DateFormat('dd/MM/yyyy').format(widget.value!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: _controller,
      label: widget.label,
      hintText: widget.value == null ? 'Selecciona una fecha' : DateFormat('dd/MM/yyyy').format(widget.value!),
      readOnly: true,
      enabled: widget.enabled,
      showError: widget.showError,
      errorText: widget.errorText,
      onTap: widget.enabled && !widget.readOnly
          ? () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: widget.value ?? DateTime.now(),
                firstDate: widget.firstDate ?? DateTime(1900),
                lastDate: widget.lastDate ?? DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Style.getPrimaryColor(),
                        onPrimary: Style.white,
                        surface: Style.getCardColor(),
                        onSurface: Style.getTextColor(),
                      ),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
              widget.onChanged(selected);
            }
          : null,
    );
  }
}
