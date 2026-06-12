import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class ComplexDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final String svg;
  final IconData icon;
  final Color color;
  final List<Widget> actions;

  const ComplexDialogContent({
    super.key,
    required this.title,
    required this.message,
    this.svg = '',
    this.icon = Icons.info_outline_rounded,
    required this.color,
    required this.actions, Widget? content,
  });

  @override
  State<ComplexDialogContent> createState() => _ComplexDialogContentState();
}

class _ComplexDialogContentState extends State<ComplexDialogContent>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  isSvgNetwork(String svg) {
    if (svg.contains('http')) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: Style.getPaddingSymmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Style.getHeaderTwo(
                  color: Style.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              widget.svg.isNotEmpty
                  ? SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: CustomWidgets.lottieIcon(
                      path: widget.svg,
                      height: 100.w,
                      width: 100.w,
                      color: widget.color,
                    ),
                  )
                  : Icon(widget.icon, color: widget.color, size: 50.w),

              SizedBox(height: 8.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.h),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Style.getTextStyle(),
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: widget.actions,
        ),
      ],
    );
  }
}
