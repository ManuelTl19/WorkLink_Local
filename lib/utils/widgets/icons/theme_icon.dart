
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:worklink_local/helpers/helpers.dart';

class ThemeIcon extends StatefulWidget {
  final double size;
  final Color color;
  const ThemeIcon({
    super.key, 
    required this.size, 
    required this.color,
  });

  @override
  State<ThemeIcon> createState() => _ThemeIconState();
}

class _ThemeIconState extends State<ThemeIcon> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, value, child) => GestureDetector(
        onTap: () => value.changeTheme(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: animation,
                child: child,
              ),
            );
          },
          child: AppSettings.isDarkModeOn ? FaIcon(
            FontAwesomeIcons.solidMoon,
            key: Key('Moon-$AppSettings.isDarkModeOn'),
            color: widget.color,
            size: widget.size,
          ) : 
          FaIcon(
            FontAwesomeIcons.solidSun,
            key: Key('Sun-$AppSettings.isDarkModeOn'),
            color: widget.color,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}