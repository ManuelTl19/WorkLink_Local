import 'dart:io';
import 'package:worklink_local/helpers/helpers.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: Style.getPaddingSymmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            children: [
              Text(
                MultiLanguages.of(context)!.translate('close_app'),
                style: Style.getHeaderTwo(
                  color: Style.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Icon(
                Icons.exit_to_app_rounded,
                color: Style.getPrimaryColor(),
                size: 30.w,
              ),
              SizedBox(height: 10.h),
              Text(
                MultiLanguages.of(context)!.translate('close_app_description'),
                textAlign: TextAlign.center,
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Style.getCardColor(),
                  padding: EdgeInsets.all(8.w),
                  elevation: 0,
                  shadowColor: Style.getShadowColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: Style.getOnlyBorderRadius(bottomLeft: 10),
                  ),
                  alignment: Alignment.center,
                ),
                child: Text(
                  MultiLanguages.of(context)!.translate('cancel'),
                  style: Style.getHeaderThree(
                    color: Style.getPrimaryColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  pop(context);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    SystemNavigator.pop();
                    exit(0);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Style.red,
                  padding: EdgeInsets.all(8.w),
                  elevation: 0,
                  shadowColor: Style.getShadowColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: Style.getOnlyBorderRadius(bottomRight: 10),
                  ),
                  alignment: Alignment.center,
                ),
                child: Text(
                  MultiLanguages.of(context)!.translate('exit'),
                  style: Style.getHeaderThree(
                    color: Style.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
