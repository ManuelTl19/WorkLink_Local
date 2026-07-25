import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/modules/vacancies/screens/applicants_screen.dart';
import 'package:worklink_local/modules/companies/screens/company_profile_screen.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_form_screen.dart';
import 'package:worklink_local/utils/utils.dart';

class VacancyDetailScreen extends StatefulWidget {
  const VacancyDetailScreen({super.key, required this.vacancyId});

  final int vacancyId;

  @override
  State<VacancyDetailScreen> createState() => _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends State<VacancyDetailScreen> {
  final VacanciesService _service = VacanciesService();
  final CompaniesService _companyProfilesService = CompaniesService();

  bool _loading = true;
  bool _isOwner = false;
  VacancyModel? _vacancy;

  @override
  void initState() {
    super.initState();
    _loadVacancy();
  }

  Future<void> _loadVacancy() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final companyProfileId = await _service.getCurrentCompanyProfileId();
      final publicVacancy = await _service.getPublicVacancyById(widget.vacancyId);
      final vacancy =
          publicVacancy ?? await _service.getVacancyById(widget.vacancyId);

      if (!mounted) return;
      setState(() {
        _vacancy = vacancy;
        _isOwner =
            vacancy != null &&
            companyProfileId != null &&
            vacancy.companyId == companyProfileId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vacancy = null;
        _isOwner = false;
        _loading = false;
      });
      Dialogs.showSimpleDialog(
        context,
        title: 'Vacantes',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _apply() async {
    final vacancy = _vacancy;
    if (vacancy == null || !vacancy.isOpen) return;

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
      await _loadVacancy();
    } catch (e) {
      if (!mounted) return;
      Dialogs.showSimpleDialog(
        context,
        title: 'Postulaciones',
        message: e.toString().replaceFirst('Exception: ', ''),
        color: Style.getErrorColor(),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _contactCompany() async {
    final vacancy = _vacancy;
    if (vacancy == null) return;

    final companyProfile = await _companyProfilesService.getPublicCompanyById(
      vacancy.companyId,
    );

    final chat = await MessageService.getOrCreateChat(
      name: vacancy.companyName,
      avatarSeed: vacancy.companyName,
      subtitle: vacancy.companyIndustry,
      avatarUrl: companyProfile?.photoUrl.isNotEmpty == true
          ? companyProfile!.photoUrl
          : vacancy.companyLogoUrl,
      relatedEntityId: vacancy.companyId,
      relatedEntityType: 'company',
    );

    if (!mounted) return;
    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
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
            expandedHeight: 240.h,
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
                onPressed: _loadVacancy,
                icon: Icon(Icons.refresh_rounded, color: Style.getTextColor()),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _loading
                  ? Center(
                      child: CustomWidgets.mProgress(Style.getPrimaryColor()),
                    )
                  : _hero(),
            ),
          ),
          if (_loading)
            SliverToBoxAdapter(child: SizedBox(height: 24.h))
          else if (_vacancy == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  MultiLanguages.of(context)?.translate('vacancy_not_found') ??
                      'La vacante no existe.',
                  style: Style.getTextStyle(color: Style.getObscureTextColor()),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  16.h,
                  Style.horizontalPadding.w,
                  12.h,
                ),
                child: _buildActions(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Style.horizontalPadding.w,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(context)?.translate('description') ??
                      'Descripción',
                  child: Text(
                    _vacancy!.description,
                    style: Style.getTextStyle(
                      color: Style.getTextColor(),
                    ).copyWith(height: 1.55),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _infoCard(
                  title:
                      MultiLanguages.of(
                        context,
                      )?.translate('vacancy_details_title') ??
                      'Detalles de la vacante',
                  child: Column(
                    children: [
                      _detailRow(
                        MultiLanguages.of(
                              context,
                            )?.translate('services_category') ??
                            'Categoría',
                        _vacancy!.category,
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('location') ??
                            'Ubicación',
                        _vacancy!.location,
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('salary') ??
                            'Salario',
                        _vacancy!.salary,
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('published') ??
                            'Publicada',
                        DateFormat('dd MMM yyyy').format(_vacancy!.postedAt),
                      ),
                      _detailRow(
                        MultiLanguages.of(context)?.translate('applicants') ??
                            'Postulantes',
                        '${_vacancy!.applicantsCount} ${MultiLanguages.of(context)?.translate('candidates') ?? 'candidatos'}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Style.horizontalPadding.w,
                  12.h,
                  Style.horizontalPadding.w,
                  0,
                ),
                child: _companyCard(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 18.h)),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    final vacancy = _vacancy;
    if (vacancy == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Style.getPrimaryColor().withValues(alpha: .92),
            Style.getSecondaryColor().withValues(alpha: .82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Style.horizontalPadding.w,
            18.h,
            Style.horizontalPadding.w,
            20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                vacancy.title,
                style: Style.getHeaderTwo(
                  color: Style.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _pill(vacancy.companyName),
                  _pill(vacancy.category),
                  _pill(vacancy.location),
                  _pill(vacancy.status.label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    final vacancy = _vacancy!;
    final isOwner = _isOwner;
    final canEdit = isOwner && vacancy.status != VacancyStatus.cerrada;

    return Row(
      children: [
        Expanded(
          child: CustomWidgets.button(
            onTap: () {
              if (canEdit) {
                Navigator.of(context).push(
                  Transitions.slideUpTransition(
                    VacancyFormScreen(vacancy: vacancy),
                  ),
                );
                return;
              }

              if (isOwner) return;

              _contactCompany();
            },
            color: Style.getPrimaryColor(),
            child: Text(
              canEdit
                  ? 'Editar vacante'
                  : isOwner
                  ? 'Vacante cerrada'
                  : 'Contactar empresa',
              style: Style.getHeaderThree(
                color: Style.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CustomWidgets.button(
            onTap: () {
              if (isOwner) {
                Navigator.of(context).push(
                  Transitions.slideUpTransition(
                    ApplicantsScreen(vacancyId: vacancy.id),
                  ),
                );
                return;
              }

              if (vacancy.isOpen) {
                _apply();
              }
            },
            color: Style.getCardColor(),
            isFilled: false,
            withBorder: true,
            child: Text(
              isOwner
                  ? 'Ver postulantes'
                  : vacancy.isOpen
                  ? 'Aplicar ahora'
                  : 'Vacante cerrada',
              style: Style.getHeaderThree(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyCard() {
    final vacancy = _vacancy!;
    final companyPhotoUrl = vacancy.companyLogoUrl;
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: () {
          Navigator.of(context).push(
            Transitions.slideUpTransition(
              CompanyProfileScreen(companyId: vacancy.companyId),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28.w,
                backgroundImage: companyPhotoUrl.isNotEmpty
                    ? NetworkImage(companyPhotoUrl)
                    : null,
                backgroundColor: Style.getPrimaryColor().withValues(alpha: .10),
                child: companyPhotoUrl.isEmpty
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
                      vacancy.companyName,
                      style: Style.getHeaderThree(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      vacancy.companyIndustry,
                      style: Style.getTextStyle(
                        color: Style.getObscureTextColor(),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      vacancy.companyLocation,
                      style: Style.getTextStyle(
                        color: Style.getTextColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Style.getObscureTextColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Card(
      color: Style.getCardColor(),
      elevation: 4,
      shadowColor: Style.getShadowColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Style.getHeaderThree(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Style.getTextStyle(
                color: Style.getObscureTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: Style.getTextStyle(
                color: Style.getTextColor(),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Style.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Style.white.withValues(alpha: .22)),
      ),
      child: Text(
        label,
        style: Style.getTextStyle(
          color: Style.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
