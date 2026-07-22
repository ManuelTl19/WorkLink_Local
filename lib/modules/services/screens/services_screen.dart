import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/services/components/service_card.dart';
import 'package:worklink_local/modules/services/components/service_filters_bar.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/services_service.dart';
import 'package:worklink_local/modules/services/screens/service_detail_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const String _allFilter = '__all__';
  static const String _priceAll = 'all';
  static const String _priceLt35 = 'lt_35';
  static const String _price35To50 = 'between_35_50';
  static const String _priceGt50 = 'gt_50';
  static const String _ratingAll = 'all';
  static const String _rating40 = 'rating_4_0';
  static const String _rating45 = 'rating_4_5';
  static const String _rating48 = 'rating_4_8';

  final ServicesService _service = ServicesService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  String _query = '';
  String _selectedCategory = _allFilter;
  String _selectedPrice = _priceAll;
  String _selectedRating = _ratingAll;
  List<String> _categories = const <String>[_allFilter];
  List<ServiceModel> _services = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final services = await _service.getServices(
      query: _query,
      category: _selectedCategory == _allFilter ? null : _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );

    final categories =
        services
            .map((service) => service.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (!mounted) return;
    setState(() {
      _categories = [_allFilter, ...categories];
      _services = services;
      _loading = false;
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _allFilter;
      }
    });
  }

  double? get _minPrice {
    switch (_selectedPrice) {
      case _priceLt35:
        return null;
      case _price35To50:
        return 35;
      case _priceGt50:
        return 50;
      default:
        return null;
    }
  }

  double? get _maxPrice {
    switch (_selectedPrice) {
      case _priceLt35:
        return 35;
      case _price35To50:
        return 50;
      default:
        return null;
    }
  }

  double? get _minRating {
    switch (_selectedRating) {
      case _rating40:
        return 4.0;
      case _rating45:
        return 4.5;
      case _rating48:
        return 4.8;
      default:
        return null;
    }
  }

  Future<void> _refreshList() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: RefreshIndicator(
          onRefresh: _refreshList,
          color: Style.getPrimaryColor(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Style.getBackgroundColor(),
                surfaceTintColor: Style.transparent,
                elevation: 0,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Style.getTextColor(),
                  ),
                ),
                title: Text(
                  MultiLanguages.of(context)?.translate('services') ??
                      'Servicios',
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    8.h,
                    Style.horizontalPadding.w,
                    8.h,
                  ),
                  child: const SizedBox.shrink(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Style.horizontalPadding.w,
                  ),
                  child: ServiceFiltersBar(
                    searchController: _searchController,
                    selectedCategory: _selectedCategory,
                    selectedPriceFilter: _selectedPrice,
                    selectedRatingFilter: _selectedRating,
                    categoryOptions: _categories
                        .map(
                          (item) => CustomPickerOption(
                            value: item,
                            label: item == _allFilter
                                ? (MultiLanguages.of(
                                        context,
                                      )?.translate('all') ??
                                      'Todas')
                                : item,
                          ),
                        )
                        .toList(),
                    priceOptions: [
                      CustomPickerOption(
                        value: _priceAll,
                        label:
                            MultiLanguages.of(context)?.translate('all') ??
                            'Todas',
                      ),
                      CustomPickerOption(
                        value: _priceLt35,
                        label:
                            MultiLanguages.of(
                              context,
                            )?.translate('services_price_under_35') ??
                            'Menos de 35',
                      ),
                      CustomPickerOption(
                        value: _price35To50,
                        label:
                            MultiLanguages.of(
                              context,
                            )?.translate('services_price_35_50') ??
                            '35 - 50',
                      ),
                      CustomPickerOption(
                        value: _priceGt50,
                        label:
                            MultiLanguages.of(
                              context,
                            )?.translate('services_price_over_50') ??
                            'Más de 50',
                      ),
                    ],
                    ratingOptions: [
                      CustomPickerOption(
                        value: _ratingAll,
                        label:
                            MultiLanguages.of(context)?.translate('all') ??
                            'Todas',
                      ),
                      const CustomPickerOption(value: _rating40, label: '4.0+'),
                      const CustomPickerOption(value: _rating45, label: '4.5+'),
                      const CustomPickerOption(value: _rating48, label: '4.8+'),
                    ],
                    onSearchChanged: (value) {
                      _query = value;
                      _refreshList();
                    },
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategory = value ?? _allFilter);
                      _refreshList();
                    },
                    onPriceChanged: (value) {
                      setState(() => _selectedPrice = value ?? _priceAll);
                      _refreshList();
                    },
                    onRatingChanged: (value) {
                      setState(() => _selectedRating = value ?? _ratingAll);
                      _refreshList();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 14.h)),
              if (_loading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                  ),
                )
              else if (_services.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_no_results') ??
                            'No hay servicios que coincidan con tu búsqueda.',
                        textAlign: TextAlign.center,
                        style: Style.getTextStyle(
                          color: Style.getObscureTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Style.horizontalPadding.w,
                    0,
                    Style.horizontalPadding.w,
                    24.h,
                  ),
                  sliver: SliverList.separated(
                    itemCount: _services.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final serviceModel = _services[index];
                      return ServiceCard(
                        service: serviceModel,
                        mode: ServiceCardMode.browse,
                        onTap: () {
                          Navigator.of(context).push(
                            Transitions.slideUpTransition(
                              ServiceDetailScreen(serviceId: serviceModel.id),
                            ),
                          );
                        },
                        onRequest: () {
                          Navigator.of(context).push(
                            Transitions.slideUpTransition(
                              ServiceDetailScreen(serviceId: serviceModel.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
