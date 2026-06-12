
import 'package:worklink_local/helpers/helpers.dart';

class NormalAppBar extends StatelessWidget {
  final double height; 
  final Color backgroundColor;
  final Widget title;
  final List<Widget> actions;
  final bool showElevation,
    automaticallyImplyLeading,
    centerTitle;
    
  const NormalAppBar({
    super.key,
    this.height = 56.0, 
    required this.backgroundColor,
    required this.title,
    this.actions = const [],
    this.showElevation = true,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: showElevation ? 5.0 : 0.0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading 
        ? null 
        : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Style.getPrimaryColor(),
          iconSize: 20,
          onPressed: () => pop(context),
        ),
      centerTitle: centerTitle,
      title: title,
      actions: actions,
    );
  }

  static PreferredSize appBar({
    double height = 56.0, 
    required Color backgroundColor,
    required Widget title,
    bool centerTitle = false,
    List<Widget> actions = const [],
    bool showElevation = true,
    bool automaticallyImplyLeading = true,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: NormalAppBar(
        height: height,
        backgroundColor: backgroundColor,
        title: title,
        actions: actions,
        showElevation: showElevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
    );
  }
}