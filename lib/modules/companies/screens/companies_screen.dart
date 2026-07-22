import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/companies/components/company_card.dart';
import 'package:worklink_local/modules/companies/components/company_filters_bar.dart';
import 'package:worklink_local/modules/companies/screens/company_profile_screen.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final CompaniesService _service = CompaniesService();
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  List<CompanyModel> _companies = const [];
  List<String> _industries = const ['Todas'];
  List<String> _locations = const ['Todas'];

  String _selectedIndustry = 'Todas';
  String _selectedLocation = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final industries = await _service.getIndustries();
    final locations = await _service.getLocations();
    final companies = await _service.getCompanies(
      query: _searchController.text,
      industry: _selectedIndustry,
      location: _selectedLocation,
    );

    if (!mounted) return;

    setState(() {
      _industries = ['Todas', ...industries];
      _locations = ['Todas', ...locations];
      _companies = companies;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Style.getBackgroundColor(),
            surfaceTintColor: Style.transparent,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Style.getTextColor(),
              ),
            ),
            title: Text(
              'Empresas',
              style: Style.getHeaderTwo(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Style.horizontalPadding.w,
                8.h,
                Style.horizontalPadding.w,
                14.h,
              ),
              child: CompanyFiltersBar(
                searchController: _searchController,
                selectedIndustry: _selectedIndustry,
                selectedLocation: _selectedLocation,
                industries: _industries,
                locations: _locations,
                onSearchChanged: (_) => _loadData(),
                onIndustryChanged: (value) {
                  setState(() => _selectedIndustry = value ?? 'Todas');
                  _loadData();
                },
                onLocationChanged: (value) {
                  setState(() => _selectedLocation = value ?? 'Todas');
                  _loadData();
                },
              ),
            ),
          ),
          if (_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CustomWidgets.mProgress(Style.getPrimaryColor()),
              ),
            )
          else if (_companies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No hay empresas con los filtros aplicados.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                Style.horizontalPadding.w,
                0,
                Style.horizontalPadding.w,
                20.h,
              ),
              sliver: SliverList.separated(
                itemCount: _companies.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final company = _companies[index];
                  return CompanyCard(
                    company: company,
                    onTap: () {
                      Navigator.of(context).push(
                        Transitions.slideUpTransition(
                          CompanyProfileScreen(companyId: company.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
