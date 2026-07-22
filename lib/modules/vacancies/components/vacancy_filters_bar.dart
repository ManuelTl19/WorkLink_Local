import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';

class VacancyFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedLocation;
  final List<String> categories;
  final List<String> locations;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onLocationChanged;

  const VacancyFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.categories,
    required this.locations,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Style.getCardColor(),
      elevation: 0,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            CustomInputField(
              controller: searchController,
              label:
                  MultiLanguages.of(
                    context,
                  )?.translate('vacancies_search_label') ??
                  'Buscar vacantes, empresas o habilidades',
              hintText:
                  MultiLanguages.of(
                    context,
                  )?.translate('vacancies_search_hint') ??
                  'Buscar vacantes, empresas o habilidades',
              textInputAction: TextInputAction.search,
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
                    label:
                        MultiLanguages.of(
                          context,
                        )?.translate('services_category') ??
                        'Categoría',
                    value: selectedCategory,
                    items: categories
                        .map(
                          (category) => CustomPickerOption<String>(
                            value: category,
                            label: category,
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: CustomPickerField<String>(
                    label:
                        MultiLanguages.of(context)?.translate('location') ??
                        'Ubicación',
                    value: selectedLocation,
                    items: locations
                        .map(
                          (location) => CustomPickerOption<String>(
                            value: location,
                            label: location,
                          ),
                        )
                        .toList(),
                    onChanged: onLocationChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
