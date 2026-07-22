import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/vacancies/components/vacancy_card.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_form_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key, required this.companyId});

  final int companyId;

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final VacanciesService _service = VacanciesService();
  bool _loading = true;
  CompanyModel? _company;
  List<VacancyModel> _vacancies = const [];

  bool get _isOwner => widget.companyId == VacanciesService.currentCompanyId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final company = await _service.getCompanyById(widget.companyId);
    final vacancies = await _service.getCompanyVacancies(
      companyId: widget.companyId,
    );
    if (!mounted) return;
    setState(() {
      _company = company;
      _vacancies = vacancies;
      _loading = false;
    });
  }

  Future<void> _contactCompany() async {
    final company = _company;
    if (company == null) return;

    final chat = await MessageService.getOrCreateChat(
      name: company.name,
      avatarSeed: company.name,
      subtitle: company.location,
      avatarUrl: company.logoUrl,
      relatedEntityId: company.id,
      relatedEntityType: 'company',
    );

    if (!mounted) return;
    Navigator.push(
      context,
      Transitions.slideUpTransition(ConversationScreen(chat: chat)),
    );
  }

  Future<void> _openCreateVacancy() async {
    final saved = await Navigator.of(context).push(
      Transitions.slideUpTransition(
        VacancyFormScreen(companyId: widget.companyId),
      ),
    );
    if (saved == true && mounted) {
      await _loadData();
    }
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
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Style.getTextColor(),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _loadData,
                icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
              ),
            ],
            title: Text(
              MultiLanguages.of(context)?.translate('company_profile_title') ??
                  'Perfil de empresa',
              style: Style.getHeaderTwo(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
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
          else if (_company == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('company_not_found') ??
                      'No se encontró la empresa solicitada.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  8.h,
                  Style.horizontalPadding.w,
                  18.h,
                ),
                child: Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: Style.getCardColor(),
                    borderRadius: Style.getCircularBorderRadius(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30.w,
                        backgroundColor: Style.getPrimaryColor().withValues(
                          alpha: .14,
                        ),
                        backgroundImage: _company!.logoUrl.isNotEmpty
                            ? NetworkImage(_company!.logoUrl)
                            : null,
                        child: _company!.logoUrl.isEmpty
                            ? Icon(
                                Icons.apartment_rounded,
                                color: Style.getPrimaryColor(),
                              )
                            : null,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _company!.name,
                              style: Style.getHeaderTwo(
                                color: Style.getTextColor(),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _company!.industry,
                              style: Style.getTextStyle(
                                color: Style.getObscureTextColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _company!.description,
                              style: Style.getTextStyle(
                                color: Style.getTextColor(),
                              ).copyWith(height: 1.45),
                            ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding.w,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomWidgets.button(
                        onTap: _contactCompany,
                        color: Style.getPrimaryColor(),
                        child: Text(
                          MultiLanguages.of(
                                context,
                              )?.translate('contact_company') ??
                              'Contactar empresa',
                          style: Style.getHeaderThree(
                            color: Style.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (_isOwner) ...[
                      SizedBox(width: 10.w),
                      Expanded(
                        child: CustomWidgets.button(
                          onTap: _openCreateVacancy,
                          color: Style.getCardColor(),
                          child: Text(
                            MultiLanguages.of(
                                  context,
                                )?.translate('new_vacancy') ??
                                'Nueva vacante',
                            style: Style.getHeaderThree(
                              color: Style.getTextColor(),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  20.h,
                  Style.horizontalPadding.w,
                  8.h,
                ),
                child: Text(
                  MultiLanguages.of(
                        context,
                      )?.translate('vacancies_active_count') ??
                      'Vacantes activas',
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (_vacancies.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Style.horizontalPadding.w,
                    vertical: 16.h,
                  ),
                  child: Text(
                    MultiLanguages.of(
                          context,
                        )?.translate('company_no_vacancies') ??
                        'La empresa todavía no ha publicado vacantes.',
                    style: Style.getTextStyle(
                      color: Style.getObscureTextColor(),
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
                  20.h,
                ),
                sliver: SliverList.separated(
                  itemCount: _vacancies.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final vacancy = _vacancies[index];
                    return VacancyCard(
                      vacancy: vacancy,
                      mode: _isOwner
                          ? VacancyCardMode.company
                          : VacancyCardMode.freelancer,
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            VacancyDetailScreen(vacancyId: vacancy.id),
                          ),
                        );
                      },
                      onEdit: _isOwner
                          ? () => Navigator.of(context).push(
                              Transitions.slideUpTransition(
                                VacancyFormScreen(vacancy: vacancy),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}
