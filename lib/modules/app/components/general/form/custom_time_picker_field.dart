import 'package:intl/intl.dart';
import 'package:worklink_local/modules/app/components/general/form/custom_input_field.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomTimePickerField extends StatefulWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?> onChanged;
  final bool enabled;
  final bool readOnly;
  final String? errorText;
  final bool showError;

  const CustomTimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.errorText,
    this.showError = false,
  });

  @override
  State<CustomTimePickerField> createState() => _CustomTimePickerFieldState();
}

class _CustomTimePickerFieldState extends State<CustomTimePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatTime(widget.value));
  }

  @override
  void didUpdateWidget(covariant CustomTimePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = _formatTime(widget.value);
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
      hintText: 'Selecciona una hora',
      readOnly: true,
      enabled: widget.enabled,
      showError: widget.showError,
      errorText: widget.errorText,
      onTap: widget.enabled && !widget.readOnly
          ? () async {
              final selected = await showTimePicker(
                context: context,
                initialTime: widget.value ?? TimeOfDay.now(),
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

  String _formatTime(TimeOfDay? value) {
    if (value == null) return '';
    return DateFormat('hh:mm a').format(DateTime(0, 1, 1, value.hour, value.minute));
  }
}
