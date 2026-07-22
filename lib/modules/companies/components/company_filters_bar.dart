import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';

class CompanyFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedIndustry;
  final String selectedLocation;
  final List<String> industries;
  final List<String> locations;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onIndustryChanged;
  final ValueChanged<String?> onLocationChanged;

  const CompanyFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedIndustry,
    required this.selectedLocation,
    required this.industries,
    required this.locations,
    required this.onSearchChanged,
    required this.onIndustryChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          controller: searchController,
          label: 'Buscar empresas por nombre o industria',
          hintText: 'Buscar empresas por nombre o industria',
          onChanged: onSearchChanged,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Style.getObscureTextColor(),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: CustomPickerField<String>(
                label: 'Industria',
                value: selectedIndustry,
                items: industries
                    .map((item) => CustomPickerOption(value: item, label: item))
                    .toList(),
                onChanged: onIndustryChanged,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomPickerField<String>(
                label: 'Ubicación',
                value: selectedLocation,
                items: locations
                    .map((item) => CustomPickerOption(value: item, label: item))
                    .toList(),
                onChanged: onLocationChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
