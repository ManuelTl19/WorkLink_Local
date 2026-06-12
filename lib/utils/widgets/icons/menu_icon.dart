
import 'package:worklink_local/helpers/helpers.dart';

class MenuIcon extends StatefulWidget {
  final double size;
  final Color color;
  final bool isOpen;
  
  const MenuIcon({
    super.key, 
    required this.size, 
    required this.color,
    required this.isOpen,
  });

  @override
  State<MenuIcon> createState() => _MenuIconState();
}

class _MenuIconState extends State<MenuIcon> with SingleTickerProviderStateMixin {
  late Animation<double> _myAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _myAnimation = CurvedAnimation(
      curve: Curves.linear,
      parent: _controller
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isOpen) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _myAnimation,
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}