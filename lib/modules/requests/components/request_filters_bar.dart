import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/utils/utils.dart';

class RequestFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final String selectedLocation;
  final String selectedBudget;
  final List<String> categories;
  final List<String> locations;
  final List<String> budgetFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onBudgetChanged;

  const RequestFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.selectedBudget,
    required this.categories,
    required this.locations,
    required this.budgetFilters,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onBudgetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          controller: searchController,
          label: 'Buscar solicitudes o categorías',
          hintText: 'Buscar solicitudes o categorías',
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
        SizedBox(height: 12.h),
        CustomPickerField<String>(
          label: 'Presupuesto',
          value: selectedBudget,
          items: budgetFilters
              .map((item) => CustomPickerOption(value: item, label: item))
              .toList(),
          onChanged: onBudgetChanged,
        ),
      ],
    );
  }
}
