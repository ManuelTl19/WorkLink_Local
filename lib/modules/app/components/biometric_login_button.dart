import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;

  const BiometricLoginButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Style.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: Style.getButtonBorderRadius(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: Style.getButtonBorderRadius(),
              gradient: LinearGradient(
                colors: [
                  Style.getBackgroundColor().withValues(alpha: .92),
                  Style.getPrimaryColor().withValues(alpha: .08),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(
                color: Style.getPrimaryColor().withValues(alpha: .55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Style.getPrimaryColor().withValues(alpha: .12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: loading
                ? SizedBox(
                    height: 24.w,
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Style.getPrimaryColor(),
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Style.getPrimaryColor().withValues(alpha: .12),
                        ),
                        child: Icon(
                          Icons.fingerprint_rounded,
                          color: Style.getPrimaryColor(),
                          size: 24.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ingresar con biometría',
                              style: Style.getHeaderThree(
                                color: Style.getPrimaryColor(),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Usa tu huella para volver a entrar',
                              style: Style.getTextStyle(
                                color: Style.getObscureTextColor(),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Style.getPrimaryColor().withValues(alpha: .10),
                        ),
                        child: Icon(
                          Icons.sensor_door_rounded,
                          color: Style.getPrimaryColor(),
                          size: 18.w,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
