import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomImagePickerField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool allowMultiple;
  final bool enabled;
  final bool readOnly;
  final bool allowCropping;
  final List<XFile>? initialFiles;
  final ValueChanged<List<XFile>?> onXFilesChanged;
  final ValueChanged<List<File>?>? onFilesChanged;
  final ValueChanged<List<Uint8List>?>? onBytesChanged;
  final String? errorText;
  final bool showError;

  const CustomImagePickerField({
    super.key,
    required this.label,
    required this.onXFilesChanged,
    this.hintText,
    this.allowMultiple = false,
    this.enabled = true,
    this.readOnly = false,
    this.allowCropping = false,
    this.initialFiles,
    this.onFilesChanged,
    this.onBytesChanged,
    this.errorText,
    this.showError = false,
  });

  @override
  State<CustomImagePickerField> createState() => _CustomImagePickerFieldState();
}

class _CustomImagePickerFieldState extends State<CustomImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  late List<XFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List<XFile>.from(widget.initialFiles ?? const []);
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
          onTap: widget.enabled && !widget.readOnly ? _openPickerSheet : null,
          borderRadius: Style.getBorderRadius(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 160.h,
                        decoration: BoxDecoration(
                          color: Style.getPrimaryColor().withValues(alpha: .08),
                          borderRadius: Style.getBorderRadius(),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Style.getPrimaryColor(),
                          size: 36.w,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        widget.hintText ?? 'Selecciona imágenes',
                        style: Style.getHintStyle(color: Style.getObscureTextColor()),
                      ),
                    ],
                  )
                : widget.allowMultiple
                    ? Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: _files.map(_thumbnail).toList(),
                      )
                    : _singlePreview(_files.first),
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

  Widget _singlePreview(XFile file) {
    return ClipRRect(
      borderRadius: Style.getBorderRadius(),
      child: SizedBox(
        height: 220.h,
        width: double.infinity,
        child: Image.file(File(file.path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _thumbnail(XFile file) {
    return SizedBox(
      width: 96.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Style.getBorderRadius(),
            child: SizedBox(
              height: 96.w,
              width: 96.w,
              child: Image.file(File(file.path), fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Style.getTextStyle(color: Style.getTextColor(), fontSize: 8),
          ),
        ],
      ),
    );
  }

  Future<void> _openPickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Style.getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetAction(
                  icon: Icons.photo_camera_rounded,
                  title: 'Tomar foto',
                  onTap: () => _pickImage(sheetContext, ImageSource.camera),
                ),
                _sheetAction(
                  icon: Icons.photo_library_rounded,
                  title: 'Elegir de galería',
                  onTap: () => _pickImage(sheetContext, ImageSource.gallery),
                ),
                if (_files.isNotEmpty)
                  _sheetAction(
                    icon: Icons.delete_outline_rounded,
                    title: 'Eliminar imagen',
                    onTap: () {
                      setState(() => _files = []);
                      widget.onXFilesChanged(null);
                      widget.onFilesChanged?.call(null);
                      widget.onBytesChanged?.call(null);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Style.getPrimaryColor()),
      title: Text(
        title,
        style: Style.getTextStyle(color: Style.getTextColor(), fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(BuildContext sheetContext, ImageSource source) async {
    final picked = widget.allowMultiple && source == ImageSource.gallery
        ? await _picker.pickMultiImage(imageQuality: 90)
        : [await _picker.pickImage(source: source, imageQuality: 90)].whereType<XFile>().toList();

    if (picked.isEmpty) {
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      return;
    }

    setState(() => _files = picked);
    widget.onXFilesChanged(_files);
    widget.onFilesChanged?.call(_files.map((file) => File(file.path)).toList());
    widget.onBytesChanged?.call(await Future.wait(_files.map((file) => file.readAsBytes())));

    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }
}
