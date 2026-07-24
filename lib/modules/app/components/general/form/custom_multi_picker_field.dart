import 'package:worklink_local/modules/app/components/general/form/custom_picker_field.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class CustomMultiPickerField<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final List<CustomPickerOption<T>> items;
  final ValueChanged<List<T>> onChanged;
  final String? hintText;
  final bool enabled;
  final bool readOnly;
  final bool showError;
  final String? errorText;

  const CustomMultiPickerField({
    super.key,
    required this.label,
    required this.values,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.enabled = true,
    this.readOnly = false,
    this.showError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Style.getHeaderThree(
            color: Style.getObscureTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: enabled && !readOnly ? () => _openPicker(context) : null,
          borderRadius: Style.getBorderRadius(),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 56.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Style.getCardColor().withValues(alpha: .16),
              borderRadius: Style.getBorderRadius(),
              border: Border.all(
                color: showError && errorText != null
                    ? Style.getErrorColor().withValues(alpha: .28)
                    : Style.getFormFieldBorderColor(),
              ),
            ),
            child: values.isEmpty
                ? Text(
                    hintText ?? label,
                    style: Style.getHintStyle(
                      color: Style.getObscureTextColor(),
                      fontSize: 10,
                    ),
                  )
                : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: values
                        .map(
                          (value) => Chip(
                            label: Text(
                              items.firstWhere((item) => item.value == value).label,
                            ),
                            backgroundColor: Style.getPrimaryColor().withValues(alpha: .12),
                            labelStyle: Style.getTextStyle(
                              color: Style.getPrimaryColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        if (showError && errorText != null) ...[
          SizedBox(height: 6.h),
          Text(
            errorText!,
            style: Style.getTextStyle(color: Style.getErrorColor(), fontSize: 8),
          ),
        ],
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = <T>{...values};

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Style.getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Style.getHeaderTwo(
                        color: Style.getPrimaryColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 360.h),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = selected.contains(item.value);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (checked) {
                              setSheetState(() {
                                if (checked == true) {
                                  selected.add(item.value);
                                } else {
                                  selected.remove(item.value);
                                }
                              });
                            },
                            title: item.child ?? Text(item.label),
                            activeColor: Style.getPrimaryColor(),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomWidgets.button(
                        onTap: () {
                          onChanged(selected.toList());
                          Navigator.pop(sheetContext);
                        },
                        color: Style.getPrimaryColor(),
                        child: Text(
                          'Aceptar',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
