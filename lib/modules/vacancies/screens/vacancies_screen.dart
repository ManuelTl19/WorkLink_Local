import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/vacancies/components/vacancy_card.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class VacanciesScreen extends StatefulWidget {
  const VacanciesScreen({super.key});

  @override
  State<VacanciesScreen> createState() => _VacanciesScreenState();
}

class _VacanciesScreenState extends State<VacanciesScreen> {
  final VacanciesService _service = VacanciesService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  String _query = '';
  String _selectedCategory = 'Todas';
  String _selectedLocation = 'Todas';
  List<String> _categories = const ['Todas'];
  List<String> _locations = const ['Todas'];
  List<VacancyModel> _vacancies = const [];

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

    List<String> categories = const [];
    List<String> locations = const [];
    List<VacancyModel> vacancies = const [];

    try {
      categories = await _service.getCategories();
    } catch (_) {
      categories = const [];
    }

    try {
      locations = await _service.getLocations();
    } catch (_) {
      locations = const [];
    }

    try {
      vacancies = await _service.getFreelancerVacancies(
        query: _query,
        category: _selectedCategory,
        location: _selectedLocation,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar vacantes: $e')),
        );
      }
      vacancies = const [];
    }

    if (!mounted) return;

    setState(() {
      _categories = ['Todas', ...categories];
      _locations = ['Todas', ...locations];
      _vacancies = vacancies;
      if (!_categories.contains(_selectedCategory)) _selectedCategory = 'Todas';
      if (!_locations.contains(_selectedLocation)) _selectedLocation = 'Todas';
      _loading = false;
    });
  }

  Future<void> _refreshList() async {
    final vacancies = await _service.getFreelancerVacancies(
      query: _query,
      category: _selectedCategory,
      location: _selectedLocation,
    );

    if (!mounted) return;
    setState(() => _vacancies = vacancies);
  }

  Future<void> _applyToVacancy(VacancyModel vacancy) async {
    try {
      await _service.applyToVacancy(vacancyId: vacancy.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MultiLanguages.of(context)?.translate('application_sent') ?? 'Tu postulación fue enviada a'} ${vacancy.companyName}.',
          ),
        ),
      );
      await _refreshList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MultiLanguages.of(context)?.translate('application_failed') ?? 'No se pudo aplicar'}: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, app, child) => Scaffold(
        backgroundColor: Style.getBackgroundColor(),
        body: RefreshIndicator(
          onRefresh: _loadData,
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
                'Vacantes',
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
                  12.h,
                  Style.horizontalPadding.w,
                  12.h,
                ),
                child: CustomInputField(
                  controller: _searchController,
                  label:
                      MultiLanguages.of(context)?.translate('vacancies_search_label') ??
                      'Buscar vacantes, empresas o habilidades',
                  hintText:
                      MultiLanguages.of(context)?.translate('vacancies_search_hint') ??
                      'Buscar vacantes, empresas o habilidades',
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    _query = value;
                    _refreshList();
                  },
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Style.getObscureTextColor(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            if (_loading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                ),
              )
            else if (_vacancies.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      'No hay vacantes que coincidan con tu búsqueda.',
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
                  4.h,
                  Style.horizontalPadding.w,
                  20.h,
                ),
                sliver: SliverList.separated(
                  itemCount: _vacancies.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final vacancy = _vacancies[index];
                    return VacancyCard(
                      vacancy: vacancy,
                      mode: VacancyCardMode.freelancer,
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            VacancyDetailScreen(vacancyId: vacancy.id),
                          ),
                        );
                      },
                      onApply: vacancy.isOpen
                          ? () => _applyToVacancy(vacancy)
                          : null,
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
