import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/app/components/general/form/form_widgets.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/messages/services/message_service.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/utils/utils.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/screens/vacancy_detail_screen.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/widgets/widgets.dart';

class CompanyProfileScreen extends StatefulWidget {
  final int? companyId;

  const CompanyProfileScreen({
    super.key,
    this.companyId,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final CompaniesService _service = CompaniesService();

  bool _loading = true;
  int _currentUserId = 0;
  CompanyModel? _company;
  List<VacancyModel> _vacancies = const [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _industryCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _websiteCtrl = TextEditingController();
  final TextEditingController _corporateInfoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _industryCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _websiteCtrl.dispose();
    _corporateInfoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(Constants.userEmailKey);

    if (userRaw != null && userRaw.isNotEmpty) {
      final userMap = jsonDecode(userRaw) as Map<String, dynamic>;
      _currentUserId = UserModel.fromJson(userMap).id;
    }

    CompanyModel? company;
    if (widget.companyId != null) {
      company = await _service.getCompanyById(widget.companyId!);
    } else if (_currentUserId > 0) {
      company = await _service.getMyCompanyProfile(_currentUserId);
    }

    List<VacancyModel> vacancies = const [];
    if (company != null) {
      vacancies = await _service.getCompanyVacancies(company.id);
      _syncForm(company);
    }

    if (!mounted) return;

    setState(() {
      _company = company;
      _vacancies = vacancies;
      _loading = false;
    });
  }

  void _syncForm(CompanyModel company) {
    _nameCtrl.text = company.name;
    _industryCtrl.text = company.industry;
    _locationCtrl.text = company.location;
    _descriptionCtrl.text = company.description;
    _websiteCtrl.text = company.website;
    _corporateInfoCtrl.text = company.corporateInfo;
  }

  bool get _canEdit {
    final company = _company;
    if (company == null || _currentUserId == 0) return false;
    return _service.canEditCompany(userId: _currentUserId, companyId: company.id);
  }

  Future<void> _saveProfile() async {
    final company = _company;
    if (company == null) return;
    if (!_canEdit) return;
    if (!_formKey.currentState!.validate()) return;

    final updated = company.copyWith(
      name: _nameCtrl.text.trim(),
      industry: _industryCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      corporateInfo: _corporateInfoCtrl.text.trim(),
    );

    setState(() => _loading = true);
    final saved = await _service.updateCompanyProfile(updated);

    if (!mounted) return;

    setState(() {
      _company = saved;
      _loading = false;
    });

    Dialogs.showSimpleDialog(
      context,
      title: 'Perfil actualizado',
      message: 'La información empresarial se guardó correctamente.',
      color: Style.getPrimaryColor(),
      icon: Icons.check_circle_outline_rounded,
    );
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

    Navigator.of(
      context,
    ).push(Transitions.slideUpTransition(ConversationScreen(chat: chat)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : _company == null
          ? Center(
              child: Text(
                'No se encontró información empresarial.',
                style: Style.getTextStyle(color: Style.getObscureTextColor()),
              ),
            )
          : CustomScrollView(
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
                    'Perfil empresarial',
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
                      10.h,
                      Style.horizontalPadding.w,
                      0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomInputField(
                            controller: _nameCtrl,
                            label: 'Nombre de la empresa',
                            enabled: _canEdit,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Ingresa el nombre de la empresa';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  controller: _industryCtrl,
                                  label: 'Industria',
                                  enabled: _canEdit,
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Ingresa la industria';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CustomInputField(
                                  controller: _locationCtrl,
                                  label: 'Ubicación',
                                  enabled: _canEdit,
                                  validator: (value) {
                                    if ((value ?? '').trim().isEmpty) {
                                      return 'Ingresa la ubicación';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          CustomInputField(
                            controller: _websiteCtrl,
                            label: 'Sitio web',
                            enabled: _canEdit,
                          ),
                          SizedBox(height: 10.h),
                          CustomInputField(
                            controller: _descriptionCtrl,
                            label: 'Descripción',
                            maxLines: 4,
                            enabled: _canEdit,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Ingresa una descripción';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          CustomInputField(
                            controller: _corporateInfoCtrl,
                            label: 'Información general',
                            maxLines: 4,
                            enabled: _canEdit,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: CustomWidgets.button(
                                  onTap: _contactCompany,
                                  color: Style.getPrimaryColor(),
                                  child: Text(
                                    'Contactar',
                                    style: Style.getHeaderThree(
                                      color: Style.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              if (_canEdit) ...[
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: CustomWidgets.button(
                                    onTap: _saveProfile,
                                    color: Style.getSecondaryColor(),
                                    child: Text(
                                      'Guardar',
                                      style: Style.getHeaderThree(
                                        color: Style.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                      20.h,
                      Style.horizontalPadding.w,
                      10.h,
                    ),
                    child: Text(
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
                        vertical: 8.h,
                      ),
                      child: Text(
                        'No hay vacantes activas para esta empresa.',
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
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final vacancy = _vacancies[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              Transitions.slideUpTransition(
                                VacancyDetailScreen(vacancyId: vacancy.id),
                              ),
                            );
                          },
                          borderRadius: Style.getBorderRadius(),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Style.getCardColor(),
                              borderRadius: Style.getBorderRadius(),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.work_outline_rounded,
                                  color: Style.getPrimaryColor(),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vacancy.title,
                                        style: Style.getTextStyle(
                                          color: Style.getTextColor(),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '${vacancy.category} • ${vacancy.location}',
                                        style: Style.getTextStyle(
                                          color: Style.getObscureTextColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
