import 'package:worklink_local/helpers/helpers.dart';

class MultiStepFormScaffold extends StatelessWidget {
  const MultiStepFormScaffold({
    super.key,
    required this.title,
    required this.stepTitles,
    required this.currentStep,
    required this.child,
    required this.onClose,
    this.onBack,
    this.onNext,
    this.isLastStep = false,
    this.isLoading = false,
    this.nextLabel,
    this.submitLabel,
    this.backLabel,
  });

  final String title;
  final List<String> stepTitles;
  final int currentStep;
  final Widget child;
  final VoidCallback onClose;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isLastStep;
  final bool isLoading;
  final String? nextLabel;
  final String? submitLabel;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final showBackButton = onBack != null;

    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Style.getTextColor(),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Style.getHeaderThree(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 12.h),
              child: _stepsRow(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 12.h),
                child: child,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
              decoration: BoxDecoration(
                color: Style.getBackgroundColor(),
                border: Border(
                  top: BorderSide(
                    color: Style.getBorderColor().withValues(alpha: .2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (showBackButton)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onBack,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          side: BorderSide(
                            color: Style.getPrimaryColor().withValues(alpha: .45),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          backLabel ??
                              (MultiLanguages.of(context)?.translate('back') ??
                                  'Atras'),
                          style: Style.getTextStyle(
                            color: Style.getPrimaryColor(),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (showBackButton) SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Style.getPrimaryColor(),
                        foregroundColor: Style.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Style.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastStep
                                      ? (submitLabel ??
                                          (MultiLanguages.of(context)
                                                  ?.translate('save_changes') ??
                                              'Guardar'))
                                      : (nextLabel ??
                                          (MultiLanguages.of(context)
                                                  ?.translate('next') ??
                                              'Siguiente')),
                                  style: Style.getTextStyle(
                                    color: Style.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!isLastStep) ...[
                                  SizedBox(width: 6.w),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepsRow() {
    final total = stepTitles.length;
    return Row(
      children: List<Widget>.generate(total * 2 - 1, (index) {
        if (index.isOdd) {
          final connectorIndex = (index - 1) ~/ 2;
          final done = connectorIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2.h,
              color: done
                  ? Style.getPrimaryColor()
                  : Style.getBorderColor().withValues(alpha: .25),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final done = stepIndex < currentStep;
        final active = stepIndex == currentStep;
        final color = done || active
            ? Style.getPrimaryColor()
            : Style.getBorderColor().withValues(alpha: .35);

        return Column(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? color : Style.getBackgroundColor(),
                border: Border.all(color: color, width: 2),
              ),
              child: done
                  ? Icon(Icons.check_rounded, color: Style.white, size: 12.w)
                  : null,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: 70.w,
              child: Text(
                stepTitles[stepIndex],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Style.getTextStyle(
                  color: active
                      ? Style.getTextColor()
                      : Style.getObscureTextColor(),
                  fontSize: 7,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
