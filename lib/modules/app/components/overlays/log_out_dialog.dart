import 'package:flutter/cupertino.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/screens/starter/login_screen.dart';

class LogOutDialog extends StatefulWidget {
  const LogOutDialog({super.key});

  @override
  State<LogOutDialog> createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> {
  bool isLoading = false;

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
                MultiLanguages.of(context)!.translate('log_out'),
                style: Style.getHeaderTwo(
                  color: Style.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 20.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? CircularProgressIndicator(
                        key: const Key('loading_indicator'),
                        color: Style.getPrimaryColor(),
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Style.getPrimaryColor(),
                        ),
                      )
                    : Icon(
                        key: const Key('logout_icon'),
                        Icons.exit_to_app_rounded,
                        color: Style.getPrimaryColor(),
                        size: 30.w,
                      ),
              ),
              SizedBox(height: 10.h),
              Text(
                MultiLanguages.of(context)!.translate('log_out_description'),
                style: Style.getHeaderThree(
                  color: Style.getTextColor(),
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20.h),
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
                onPressed: () async {
                  if (!mounted) return;
                  setState(() {
                    isLoading = true;
                  });

                  await Future.delayed(const Duration(seconds: 1));

                  if (!mounted) return;
                  setState(() {
                    isLoading = false;
                  });

                  await AuthService.logout();

                  if (context.mounted)
                    push(context, const LoginScreen(), replace: true);
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
