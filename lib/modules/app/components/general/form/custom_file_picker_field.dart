import 'package:file_picker/file_picker.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomFilePickerField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool allowMultiple;
  final bool enabled;
  final bool readOnly;
  final List<PlatformFile>? initialFiles;
  final ValueChanged<List<PlatformFile>?> onChanged;
  final String? errorText;
  final bool showError;

  const CustomFilePickerField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hintText,
    this.allowMultiple = false,
    this.enabled = true,
    this.readOnly = false,
    this.initialFiles,
    this.errorText,
    this.showError = false,
  });

  @override
  State<CustomFilePickerField> createState() => _CustomFilePickerFieldState();
}

class _CustomFilePickerFieldState extends State<CustomFilePickerField> {
  late List<PlatformFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List<PlatformFile>.from(widget.initialFiles ?? const []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Style.getHeaderThree(
            color: Style.getObscureTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: widget.enabled && !widget.readOnly ? _pickFiles : null,
          borderRadius: Style.getBorderRadius(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Style.getCardColor().withValues(alpha: .16),
              borderRadius: Style.getBorderRadius(),
              border: Border.all(
                color: widget.showError && widget.errorText != null
                    ? Style.getErrorColor().withValues(alpha: .24)
                    : Style.getFormFieldBorderColor(),
              ),
            ),
            child: _files.isEmpty
                ? Row(
                    children: [
                      Icon(Icons.attach_file_rounded, color: Style.getPrimaryColor(), size: 18.w),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          widget.hintText ?? 'Selecciona archivos',
                          style: Style.getHintStyle(color: Style.getObscureTextColor()),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _files
                        .map(
                          (file) => Chip(
                            label: Text(file.name),
                            backgroundColor: Style.getPrimaryColor().withValues(alpha: .12),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        if (widget.showError && widget.errorText != null) ...[
          SizedBox(height: 6.h),
          Text(
            widget.errorText!,
            style: Style.getTextStyle(color: Style.getErrorColor(), fontSize: 8),
          ),
        ],
      ],
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: widget.allowMultiple,
      type: FileType.any,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      _files = result.files;
    });
    widget.onChanged(_files);
  }
}
