import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';

class ServiceFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedPriceFilter;
  final String selectedRatingFilter;
  final List<CustomPickerOption<String>> categoryOptions;
  final List<CustomPickerOption<String>> priceOptions;
  final List<CustomPickerOption<String>> ratingOptions;
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
    required this.categoryOptions,
    required this.priceOptions,
    required this.ratingOptions,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MultiLanguages.of(context)?.translate('services_search_label') ??
              'Buscar servicios',
          style: Style.getHeaderThree(
            color: Style.getObscureTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomInputField(
          controller: searchController,
          hintText:
              MultiLanguages.of(context)?.translate('services_search_hint') ??
              'Buscar servicios',
          onChanged: onSearchChanged,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Style.getObscureTextColor(),
          ),
        ),
      ],
    );
  }
}
