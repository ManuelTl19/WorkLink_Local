import 'package:intl/intl.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/messages/messages.dart';
import 'package:worklink_local/modules/vacancies/components/applicant_card.dart';
import 'package:worklink_local/modules/vacancies/models/applicant_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';
import 'package:worklink_local/utils/widgets/custom_widgets.dart';
import 'package:worklink_local/utils/utils.dart';

class ApplicantsScreen extends StatefulWidget {
  final int vacancyId;

  const ApplicantsScreen({super.key, required this.vacancyId});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final VacanciesService _service = VacanciesService();
  bool _loading = true;
  VacancyModel? _vacancy;
  List<ApplicantModel> _applicants = const [];

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    final vacancy = await _service.getVacancyById(widget.vacancyId);
    final applicants = await _service.getApplicantsByVacancyId(widget.vacancyId);

    if (!mounted) return;
    setState(() {
      _vacancy = vacancy;
      _applicants = applicants;
      _loading = false;
    });
  }

  Future<void> _contactFreelancer(ApplicantModel applicant) async {
    final freelancer = applicant.freelancer;
    final chat = await MessageService.getOrCreateChat(
      name: freelancer.fullName,
      avatarSeed: freelancer.fullName,
      subtitle: freelancer.specialty,
      avatarUrl: freelancer.avatarUrl,
      relatedEntityId: freelancer.id,
      relatedEntityType: 'freelancer',
    );

    if (!mounted) return;
    Navigator.of(context).push(
      Transitions.slideUpTransition(ConversationScreen(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Style.getBackgroundColor(),
        surfaceTintColor: Style.transparent,
        title: Text(
          'Postulantes',
          style: Style.getHeaderTwo(
            color: Style.getTextColor(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CustomWidgets.mProgress(Style.getPrimaryColor()))
          : _vacancy == null
              ? Center(
                  child: Text(
                    'La vacante no existe.',
                    style: Style.getTextStyle(color: Style.getObscureTextColor()),
                  ),
                )
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(Style.horizontalPadding.w),
                  children: [
                    Card(
                      color: Style.getCardColor(),
                      elevation: 4,
                      shadowColor: Style.getShadowColor(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vacancy!.title,
                              style: Style.getHeaderTwo(
                                color: Style.getTextColor(),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '${_applicants.length} candidatos postulados',
                              style: Style.getTextStyle(color: Style.getObscureTextColor()),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Última actualización ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                              style: Style.getTextStyle(color: Style.getObscureTextColor(), fontSize: 7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    if (_applicants.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Text(
                          'Todavía no hay postulantes para esta vacante.',
                          textAlign: TextAlign.center,
                          style: Style.getTextStyle(color: Style.getObscureTextColor()),
                        ),
                      )
                    else
                      ..._applicants.map(
                        (applicant) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ApplicantCard(
                            applicant: applicant,
                            onViewProfile: () {},
                            onContact: () => _contactFreelancer(applicant),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}