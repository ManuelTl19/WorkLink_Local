import 'package:worklink_local/helpers/helpers.dart';

class DialogAnimation extends StatefulWidget {
  final Widget content;
  const DialogAnimation({super.key, required this.content});

  @override
  State<StatefulWidget> createState() => DialogAnimationState();
}

class DialogAnimationState extends State<DialogAnimation> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            margin:  Style.getPaddingAll(40),
            padding: Style.noPadding(),
            decoration: ShapeDecoration(
              color: Style.getCardColor(),
              shape: RoundedRectangleBorder(
                borderRadius: Style.getBorderRadius(),
              ),
            ),
            child: widget.content,
          ),
        ),
      ),
    );
  }
}