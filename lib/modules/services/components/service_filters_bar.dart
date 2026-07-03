import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class ServiceFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedPriceFilter;
  final String selectedRatingFilter;
  final List<String> categories;
  final List<String> priceFilters;
  final List<String> ratingFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onPriceChanged;
  final ValueChanged<String?> onRatingChanged;

  const ServiceFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedPriceFilter,
    required this.selectedRatingFilter,
    required this.categories,
    required this.priceFilters,
    required this.ratingFilters,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          controller: searchController,
          label: 'Buscar servicios, freelancers o tecnologías',
          hintText: 'Buscar servicios, freelancers o tecnologías',
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
                label: 'Categoría',
                value: selectedCategory,
                items: categories
                    .map((item) => CustomPickerOption(value: item, label: item))
                    .toList(),
                onChanged: onCategoryChanged,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomPickerField<String>(
                label: 'Precio',
                value: selectedPriceFilter,
                items: priceFilters
                    .map((item) => CustomPickerOption(value: item, label: item))
                    .toList(),
                onChanged: onPriceChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CustomPickerField<String>(
          label: 'Calificación',
          value: selectedRatingFilter,
          items: ratingFilters
              .map((item) => CustomPickerOption(value: item, label: item))
              .toList(),
          onChanged: onRatingChanged,
        ),
      ],
    );
  }
}
