import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

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
  static const int _maxPhotoBytes = 2 * 1024 * 1024;
  static const List<int> _compressionQualities = <int>[
    85,
    75,
    65,
    55,
    45,
    35,
    25,
  ];
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
                  child: Icon(
                    Icons.photo_camera_rounded,
                    color: Style.white,
                    size: 16.w,
                  ),
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
      child: Icon(
        Icons.person_rounded,
        color: Style.getPrimaryColor(),
        size: 48.w,
      ),
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

    _PreparedAvatar? prepared;
    try {
      prepared = await _prepareImageForUpload(picked);
    } catch (e) {
      logWarning('No se pudo procesar la imagen de perfil: $e');
      prepared = null;
    }

    if (prepared == null) {
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      if (!mounted) return;

      Dialogs.showSimpleDialog(
        context,
        title: 'Imagen muy pesada',
        message:
            'No pudimos ajustar la foto a 2MB. Elige otra imagen más ligera.',
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    final preparedAvatar = prepared;

    setState(() {
      _xFile = preparedAvatar.xFile;
      _file = preparedAvatar.file;
      _bytes = preparedAvatar.bytes;
    });

    widget.onXFileChanged?.call(preparedAvatar.xFile);
    widget.onFileChanged?.call(_file);
    widget.onBytesChanged?.call(preparedAvatar.bytes);

    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }

  Future<_PreparedAvatar?> _prepareImageForUpload(XFile picked) async {
    final originalBytes = await picked.readAsBytes();
    if (originalBytes.length <= _maxPhotoBytes) {
      return _PreparedAvatar(
        xFile: picked,
        file: File(picked.path),
        bytes: originalBytes,
      );
    }

    for (final quality in _compressionQualities) {
      Uint8List? compressedBytes;

      try {
        compressedBytes = await FlutterImageCompress.compressWithFile(
          picked.path,
          quality: quality,
          format: CompressFormat.jpeg,
          keepExif: false,
        );
      } catch (_) {
        compressedBytes = await _compressBytesFallback(
          originalBytes,
          quality: quality,
        );
      }

      if (compressedBytes == null || compressedBytes.isEmpty) {
        continue;
      }

      if (compressedBytes.length > _maxPhotoBytes) {
        continue;
      }

      final tempFile = await _writeCompressedTempFile(compressedBytes);
      return _PreparedAvatar(
        xFile: XFile(tempFile.path),
        file: tempFile,
        bytes: compressedBytes,
      );
    }

    return null;
  }

  Future<Uint8List?> _compressBytesFallback(
    Uint8List bytes, {
    required int quality,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
    } catch (_) {
      return null;
    }
  }

  Future<File> _writeCompressedTempFile(Uint8List bytes) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${Directory.systemTemp.path}/worklink_avatar_$timestamp.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

class _PreparedAvatar {
  final XFile xFile;
  final File file;
  final Uint8List bytes;

  const _PreparedAvatar({
    required this.xFile,
    required this.file,
    required this.bytes,
  });
}
