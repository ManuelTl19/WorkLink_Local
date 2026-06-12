
import 'package:worklink_local/helpers/helpers.dart';

////// PopUpMenu //////
class MyPopUpMenu extends StatefulWidget {
  final List<PopupMenuItem> items;
  final IconData icon;
  final Color color;
  final double size;
  final Function(int) onTap;
  const MyPopUpMenu({
    super.key, 
    required this.icon,
    required this.items, 
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<MyPopUpMenu> createState() => _MyPopUpMenuState();
}

class _MyPopUpMenuState extends State<MyPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => widget.items,
      color: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Style.circularBorderRadius),
      ),
      icon: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
      ),
      onSelected: (value) => widget.onTap(value),
    );
  }
}

