
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color oldColor;
  final String title;
  final Function(Color) onDone;

  const ColorPickerDialog({
    super.key, 
    required this.oldColor,
    required this.title,
    required this.onDone,
  });

  @override
  ColorPickerDialogState createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.oldColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Style.getBackgroundColor(),
      title: Text(
        widget.title,
        style: TextStyle(
          color: selectedColor,
        ),
      ),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        CustomWidgets.button(
          onTap: () {
            Navigator.of(context).pop();
            widget.onDone(widget.oldColor);
          },
          color: Style.getCardColor(),
          child: Text(
            MultiLanguages.of(context)!.translate('cancel'),
            style: TextStyle(
              color: selectedColor,
            ),
          )
        )
      ],
    );
  }
}