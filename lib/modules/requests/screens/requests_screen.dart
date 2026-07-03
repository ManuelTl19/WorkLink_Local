import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/requests/components/request_card.dart';
import 'package:worklink_local/modules/requests/components/request_filters_bar.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';
import 'package:worklink_local/modules/requests/services/requests_service.dart';
import 'package:worklink_local/modules/requests/screens/request_detail_screen.dart';
import 'package:worklink_local/modules/requests/screens/requester_profile_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final RequestsService _service = RequestsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  String _query = '';
  String _selectedCategory = 'Todas';
  String _selectedLocation = 'Todas';
  String _selectedBudget = 'Todos';
  List<String> _categories = const ['Todas'];
  List<String> _locations = const ['Todas'];
  List<String> _budgetFilters = const ['Todos', 'Menos de 500', '500 - 1500', 'Más de 1500'];
  List<WorkRequestModel> _requests = const [];

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
    final locations = await _service.getLocations();
    final requests = await _service.getRequests(
      query: _query,
      category: _selectedCategory,
      location: _selectedLocation,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
    );
    if (!mounted) return;
    setState(() {
      _categories = ['Todas', ...categories];
      _locations = ['Todas', ...locations];
      _requests = requests;
      _loading = false;
      if (!_categories.contains(_selectedCategory)) _selectedCategory = 'Todas';
      if (!_locations.contains(_selectedLocation)) _selectedLocation = 'Todas';
    });
  }

  double? get _minBudget {
    switch (_selectedBudget) {
      case 'Menos de 500':
        return null;
      case '500 - 1500':
        return 500;
      case 'Más de 1500':
        return 1500;
      default:
        return null;
    }
  }

  double? get _maxBudget {
    switch (_selectedBudget) {
      case 'Menos de 500':
        return 500;
      case '500 - 1500':
        return 1500;
      default:
        return null;
    }
  }

  Future<void> _refreshList() async {
    final requests = await _service.getRequests(
      query: _query,
      category: _selectedCategory,
      location: _selectedLocation,
      minBudget: _minBudget,
      maxBudget: _maxBudget,
    );
    if (!mounted) return;
    setState(() => _requests = requests);
  }

  Future<void> _contactRequester(WorkRequestModel request) async {
    final chat = await MessageService.getOrCreateChat(
      name: request.requesterName,
      avatarSeed: request.requesterName,
      subtitle: request.requesterAccountType,
      avatarUrl: request.requesterAvatarUrl,
      relatedEntityId: request.requesterId,
      relatedEntityType: 'requester',
    );

    if (!mounted) return;
    Navigator.of(context).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
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
              actions: [IconButton(onPressed: _loadData, icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()))],
              title: Text('Solicitudes', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 8.h, Style.horizontalPadding.w, 16.h),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Style.getPrimaryColor().withValues(alpha: .18), Style.getPrimaryColor().withValues(alpha: .06)],
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
                        child: Icon(Icons.assignment_rounded, color: Style.getPrimaryColor(), size: 22.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explora solicitudes publicadas', style: Style.getHeaderTwo(color: Style.getTextColor(), fontWeight: FontWeight.w800, fontSize: 15)),
                            SizedBox(height: 4.h),
                            Text('Busca oportunidades y contacta directamente al solicitante desde el chat interno.', style: Style.getTextStyle(color: Style.getObscureTextColor()).copyWith(height: 1.35)),
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
                child: RequestFiltersBar(
                  searchController: _searchController,
                  selectedCategory: _selectedCategory,
                  selectedLocation: _selectedLocation,
                  selectedBudget: _selectedBudget,
                  categories: _categories,
                  locations: _locations,
                  budgetFilters: _budgetFilters,
                  onSearchChanged: (value) {
                    _query = value;
                    _refreshList();
                  },
                  onCategoryChanged: (value) {
                    setState(() => _selectedCategory = value ?? 'Todas');
                    _refreshList();
                  },
                  onLocationChanged: (value) {
                    setState(() => _selectedLocation = value ?? 'Todas');
                    _refreshList();
                  },
                  onBudgetChanged: (value) {
                    setState(() => _selectedBudget = value ?? 'Todos');
                    _refreshList();
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            if (_loading)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: CustomWidgets.mProgress(Style.getPrimaryColor())))
            else if (_requests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text('No hay solicitudes que coincidan con tu búsqueda.', textAlign: TextAlign.center, style: Style.getTextStyle(color: Style.getObscureTextColor(), fontWeight: FontWeight.w600)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Style.horizontalPadding.w, 4.h, Style.horizontalPadding.w, 20.h),
                sliver: SliverList.separated(
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return RequestCard(
                      request: request,
                      mode: RequestCardMode.browse,
                      onTap: () {
                        Navigator.of(context).push(Transitions.slideUpTransition(RequestDetailScreen(requestId: request.id)));
                      },
                      onInterested: request.isOpen ? () => _contactRequester(request) : null,
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
