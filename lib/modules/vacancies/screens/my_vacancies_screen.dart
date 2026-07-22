import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/vacancies/components/vacancy_card.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/modules/vacancies/screens/applicants_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/company_profile_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_form_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class MyVacanciesScreen extends StatefulWidget {
  const MyVacanciesScreen({super.key});

  @override
  State<MyVacanciesScreen> createState() => _MyVacanciesScreenState();
}

class _MyVacanciesScreenState extends State<MyVacanciesScreen> {
  final VacanciesService _service = VacanciesService();
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  List<VacancyModel> _vacancies = const [];

  @override
  void initState() {
    super.initState();
    _loadVacancies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVacancies() async {
    setState(() => _loading = true);
    final vacancies = await _service.getCompanyVacancies();
    if (!mounted) return;
    setState(() {
      _vacancies = vacancies;
      _loading = false;
    });
  }

  Future<void> _openForm({VacancyModel? vacancy}) async {
    final saved = await Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(VacancyFormScreen(vacancy: vacancy)));
    if (saved == true && mounted) {
      await _loadVacancies();
    }
  }

  Future<void> _changeStatus(VacancyModel vacancy) async {
    final selected = await showModalBottomSheet<VacancyStatus>(
      context: context,
      backgroundColor: Style.getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: VacancyStatus.values
                .map(
                  (status) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      status.label,
                      style: Style.getTextStyle(color: Style.getTextColor()),
                    ),
                    trailing: status == vacancy.status
                        ? Icon(
                            Icons.check_rounded,
                            color: Style.getPrimaryColor(),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, status),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selected == null || selected == vacancy.status) return;
    await _service.changeVacancyStatus(vacancyId: vacancy.id, status: selected);
    if (mounted) await _loadVacancies();
  }

  Future<void> _deleteVacancy(VacancyModel vacancy) async {
    final confirmed = await Dialogs.showConfirmDialogDelete(
      context,
      title:
          MultiLanguages.of(context)?.translate('vacancies_delete_title') ??
          'Eliminar vacante',
      message:
          MultiLanguages.of(context)?.translate('vacancies_delete_message') ??
          'Esta acción eliminará la vacante y sus postulaciones asociadas.',
      confirmText:
          MultiLanguages.of(context)?.translate('delete') ?? 'Eliminar',
      cancelText: MultiLanguages.of(context)?.translate('cancel') ?? 'Cancelar',
      confirmColor: Style.getErrorColor(),
      cancelColor: Style.getPrimaryColor(),
    );

    if (confirmed != true) return;
    await _service.deleteVacancy(vacancy.id);
    if (mounted) await _loadVacancies();
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
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Style.getTextColor(),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _loadVacancies,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Style.getTextColor(),
                  ),
                ),
                IconButton(
                  onPressed: () => _openForm(),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: Style.getTextColor(),
                  ),
                ),
              ],
              title: Text(
                MultiLanguages.of(context)?.translate('my_vacancies_title') ??
                    'Mis Vacantes',
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
                  14.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        MultiLanguages.of(
                              context,
                            )?.translate('vacancies_active_count') ??
                            'Vacantes activas',
                        _vacancies
                            .where(
                              (item) => item.status == VacancyStatus.abierta,
                            )
                            .length
                            .toString(),
                        Icons.rocket_launch_rounded,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _summaryCard(
                        MultiLanguages.of(context)?.translate('applications') ??
                            'Postulaciones',
                        _vacancies
                            .fold<int>(
                              0,
                              (sum, item) => sum + item.applicantsCount,
                            )
                            .toString(),
                        Icons.people_alt_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding.w,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomWidgets.button(
                    onTap: () => _openForm(),
                    color: Style.getPrimaryColor(),
                    child: Text(
                      MultiLanguages.of(
                            context,
                          )?.translate('vacancies_create_button') ??
                          'Crear vacante',
                      style: Style.getHeaderThree(
                        color: Style.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                  child: Text(
                    MultiLanguages.of(
                          context,
                        )?.translate('vacancies_empty_owner') ??
                        'Aún no has creado vacantes.',
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
                  6.h,
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
                      mode: VacancyCardMode.company,
                      onTap: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            VacancyDetailScreen(vacancyId: vacancy.id),
                          ),
                        );
                      },
                      onEdit: () => _openForm(vacancy: vacancy),
                      onDelete: () => _deleteVacancy(vacancy),
                      onViewApplicants: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            ApplicantsScreen(vacancyId: vacancy.id),
                          ),
                        );
                      },
                      onStatusPressed: () => _changeStatus(vacancy),
                      onViewCompany: () {
                        Navigator.of(context).push(
                          Transitions.slideUpTransition(
                            CompanyProfileScreen(companyId: vacancy.companyId),
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
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Style.getCardColor(),
        borderRadius: Style.getCircularBorderRadius(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Style.getPrimaryColor(), size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Style.getHeaderTwo(
                    color: Style.getTextColor(),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  title,
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
