import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
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
  final ServicesService _service = ServicesService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  String _query = '';
  String _selectedCategory = 'Todas';
  String _selectedPrice = 'Todos';
  String _selectedRating = 'Todas';
  List<String> _categories = const ['Todas'];
  List<String> _priceFilters = const ['Todos', 'Menos de 35', '35 - 50', 'Más de 50'];
  List<String> _ratingFilters = const ['Todas', '4.0+', '4.5+', '4.8+'];
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
    final categories = await _service.getCategories();
    final services = await _service.getServices(
      query: _query,
      category: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
    if (!mounted) return;
    setState(() {
      _categories = ['Todas', ...categories];
      _services = services;
      _loading = false;
      if (!_categories.contains(_selectedCategory)) _selectedCategory = 'Todas';
    });
  }

  double? get _minPrice {
    switch (_selectedPrice) {
      case 'Menos de 35':
        return null;
      case '35 - 50':
        return 35;
      case 'Más de 50':
        return 50;
      default:
        return null;
    }
  }

  double? get _maxPrice {
    switch (_selectedPrice) {
      case 'Menos de 35':
        return 35;
      case '35 - 50':
        return 50;
      default:
        return null;
    }
  }

  double? get _minRating {
    switch (_selectedRating) {
      case '4.0+':
        return 4.0;
      case '4.5+':
        return 4.5;
      case '4.8+':
        return 4.8;
      default:
        return null;
    }
  }

  Future<void> _refreshList() async {
    final services = await _service.getServices(
      query: _query,
      category: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
    if (!mounted) return;
    setState(() => _services = services);
  }

  Future<void> _requestService(ServiceModel serviceModel) async {
    try {
      await _service.requestService(
        serviceId: serviceModel.id,
        requesterId: ServicesService.currentRequesterId,
        requesterName: ServicesService.currentRequesterName,
        accountType: ServicesService.currentRequesterAccountType,
        avatarUrl: ServicesService.currentRequesterAvatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada a ${serviceModel.freelancerName}.')),
      );
      await _refreshList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo solicitar el servicio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Style.getBackgroundColor(),
              surfaceTintColor: Style.transparent,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Style.getTextColor()),
              ),
              actions: [
                IconButton(onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: Style.getTextColor())),
              ],
              title: Text('Servicios', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 8.h, Style.horizontalPadding.w, 16.h),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Style.getPrimaryColor().withValues(alpha: .18),
                        Style.getPrimaryColor().withValues(alpha: .06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: Style.getCircularBorderRadius(24),
                    border: Border.all(color: Style.getPrimaryColor().withValues(alpha: .10)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Style.getPrimaryColor().withValues(alpha: .12),
                          borderRadius: Style.getCircularBorderRadius(16),
                        ),
                        child: Icon(Icons.design_services_rounded, color: Style.getPrimaryColor(), size: 22.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explora servicios profesionales', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800, fontSize: 15)),
                            SizedBox(height: 4.h),
                            Text('Busca, filtra y revisa servicios ofrecidos por freelancers dentro de la plataforma.', style: Style.getTextStyle(color: Style.getObscureTextColor()).copyWith(height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Style.horizontalPadding.w),
                child: ServiceFiltersBar(
                  searchController: _searchController,
                  selectedCategory: _selectedCategory,
                  selectedPriceFilter: _selectedPrice,
                  selectedRatingFilter: _selectedRating,
                  categories: _categories,
                  priceFilters: _priceFilters,
                  ratingFilters: _ratingFilters,
                  onSearchChanged: (value) {
                    _query = value;
                    _refreshList();
                  },
                  onCategoryChanged: (value) {
                    setState(() => _selectedCategory = value ?? 'Todas');
                    _refreshList();
                  },
                  onPriceChanged: (value) {
                    setState(() => _selectedPrice = value ?? 'Todos');
                    _refreshList();
                  },
                  onRatingChanged: (value) {
                    setState(() => _selectedRating = value ?? 'Todas');
                    _refreshList();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            if (_loading)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())))
            else if (_services.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text('No hay servicios que coincidan con tu búsqueda.', textAlign: TextAlign.center, style: Style.getTextStyle(color: Style.getObscureTextColor(), fontWeight: FontWeight.w600)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 0, Style.horizontalPadding.w, 20.h),
                sliver: SliverList.separated(
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final serviceModel = _services[index];
                    return ServiceCard(
                      service: serviceModel,
                      mode: ServiceCardMode.browse,
                      onTap: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(ServiceDetailScreen(serviceId: serviceModel.id)));
                      },
                      onRequest: serviceModel.isActive ? () => _requestService(serviceModel) : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
