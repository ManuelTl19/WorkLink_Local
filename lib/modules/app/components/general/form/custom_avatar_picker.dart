import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/helpers/helpers.dart';

class CustomAvatarPicker extends StatefulWidget {
  final Uint8List? initialBytes;
  final File? initialFile;
  final XFile? initialXFile;
  final ValueChanged<Uint8List?>? onBytesChanged;
  final ValueChanged<File?>? onFileChanged;
  final ValueChanged<XFile?>? onXFileChanged;
  final double size;
  final bool enabled;

  const CustomAvatarPicker({
    super.key,
    this.initialBytes,
    this.initialFile,
    this.initialXFile,
    this.onBytesChanged,
    this.onFileChanged,
    this.onXFileChanged,
    this.size = 120,
    this.enabled = true,
  });

  @override
  State<CustomAvatarPicker> createState() => _CustomAvatarPickerState();
}

class _CustomAvatarPickerState extends State<CustomAvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;
  File? _file;
  XFile? _xFile;

  @override
  void initState() {
    super.initState();
    _bytes = widget.initialBytes;
    _file = widget.initialFile;
    _xFile = widget.initialXFile;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _bytes != null
        ? Image.memory(_bytes!, fit: BoxFit.cover)
        : _xFile != null
            ? Image.file(File(_xFile!.path), fit: BoxFit.cover)
            : _file != null
                ? Image.file(_file!, fit: BoxFit.cover)
                : null;

    return SizedBox(
      width: widget.size.w,
      height: widget.size.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? _openSheet : null,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Style.getCardColor().withValues(alpha: .16),
                    border: Border.all(
                      color: Style.getPrimaryColor().withValues(alpha: .22),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(child: preview ?? _placeholder()),
                ),
              ),
            ),
          ),
          Positioned(
            right: 4.w,
            bottom: 4.w,
            child: Material(
              color: Style.getPrimaryColor(),
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: widget.enabled ? _openSheet : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 34.w,
                  height: 34.w,
                  child: Icon(Icons.photo_camera_rounded, color: Style.white, size: 16.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Style.getPrimaryColor().withValues(alpha: .10),
      child: Icon(Icons.person_rounded, color: Style.getPrimaryColor(), size: 48.w),
    );
  }

  Future<void> _openSheet() async {
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
                if (_bytes != null || _file != null || _xFile != null)
                  _sheetAction(
                    icon: Icons.delete_outline_rounded,
                    title: 'Eliminar foto',
                    onTap: () {
                      setState(() {
                        _bytes = null;
                        _file = null;
                        _xFile = null;
                      });
                      widget.onBytesChanged?.call(null);
                      widget.onFileChanged?.call(null);
                      widget.onXFileChanged?.call(null);
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
        style: Style.getTextStyle(
          color: Style.getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(BuildContext sheetContext, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) {
      if (sheetContext.mounted) Navigator.pop(sheetContext);
      return;
    }

    setState(() {
      _xFile = picked;
      _file = File(picked.path);
      _bytes = null;
    });

    final bytes = await picked.readAsBytes();
    setState(() => _bytes = bytes);

    widget.onXFileChanged?.call(picked);
    widget.onFileChanged?.call(_file);
    widget.onBytesChanged?.call(bytes);

    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }
}
