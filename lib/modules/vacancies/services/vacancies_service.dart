import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';
import 'package:worklink_local/modules/vacancies/models/applicant_model.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';

class VacanciesService {
  static const int currentCompanyId = 1;
  static const int currentFreelancerId = 1;

  static final List<CompanyModel> _companies = [
    const CompanyModel(
      id: 1,
      name: 'WorkLink Studio',
      description:
          'Empresa enfocada en soluciones digitales, productos móviles y experiencias que conectan talento con oportunidades reales.',
      industry: 'Tecnología / Software',
      location: 'Monterrey, México',
      averageRating: 4.8,
      logoUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      status: 'Activa',
      corporateInfo:
          'Equipo multidisciplinario, cultura de producto y procesos ágiles enfocados en resultados medibles.',
      website: 'worklinkstudio.com',
      foundedYear: '2019',
      size: '11-50 colaboradores',
      activeVacanciesCount: 3,
    ),
    const CompanyModel(
      id: 2,
      name: 'North Peak Labs',
      description:
          'Laboratorio de innovación que diseña plataformas escalables para e-commerce, servicios y operaciones internas.',
      industry: 'Product Engineering',
      location: 'Bogotá, Colombia',
      averageRating: 4.6,
      logoUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      status: 'Activa',
      corporateInfo:
          'Operamos con squads de producto, procesos de QA y una fuerte orientación a experiencia de usuario.',
      website: 'northpeaklabs.io',
      foundedYear: '2021',
      size: '51-200 colaboradores',
      activeVacanciesCount: 2,
    ),
  ];

  static final List<VacancyModel> _vacancies = [
    VacancyModel(
      id: 1,
      companyId: 1,
      title: 'Senior Flutter Developer',
      description:
          'Buscamos un perfil senior para liderar una app móvil modular con foco en performance, arquitectura limpia y escalabilidad.',
      category: 'Desarrollo Móvil',
      location: 'Monterrey, México',
      salary: 'MXN 65,000 - 85,000',
      status: VacancyStatus.abierta,
      applicantsCount: 8,
      companyName: 'WorkLink Studio',
      companyDescription:
          'Creamos productos digitales para equipos que necesitan velocidad de entrega y calidad visual.',
      companyIndustry: 'Tecnología / Software',
      companyRating: 4.8,
      companyLocation: 'Monterrey, México',
      companyLogoUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      featured: true,
    ),
    VacancyModel(
      id: 2,
      companyId: 1,
      title: 'UI/UX Product Designer',
      description:
          'Perfil creativo para diseñar flujos, componentes y sistemas de interfaz con foco en conversión y accesibilidad.',
      category: 'Diseño UX/UI',
      location: 'Remoto',
      salary: 'MXN 42,000 - 58,000',
      status: VacancyStatus.abierta,
      applicantsCount: 14,
      companyName: 'WorkLink Studio',
      companyDescription:
          'Creamos productos digitales para equipos que necesitan velocidad de entrega y calidad visual.',
      companyIndustry: 'Tecnología / Software',
      companyRating: 4.8,
      companyLocation: 'Monterrey, México',
      companyLogoUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    VacancyModel(
      id: 3,
      companyId: 2,
      title: 'Node.js Backend Engineer',
      description:
          'Se requiere experiencia en APIs REST, persistencia relacional, autenticación y observabilidad de servicios.',
      category: 'Backend',
      location: 'Bogotá, Colombia',
      salary: 'COP 9,000,000 - 12,000,000',
      status: VacancyStatus.pausada,
      applicantsCount: 6,
      companyName: 'North Peak Labs',
      companyDescription:
          'Laboratorio de innovación para sistemas escalables y operaciones internas de alto impacto.',
      companyIndustry: 'Product Engineering',
      companyRating: 4.6,
      companyLocation: 'Bogotá, Colombia',
      companyLogoUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      postedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    VacancyModel(
      id: 4,
      companyId: 2,
      title: 'QA Automation Specialist',
      description:
          'Responsable de construir y mantener automatizaciones de calidad para acelerar entregas y reducir regresiones.',
      category: 'QA / Testing',
      location: 'Remoto',
      salary: 'USD 2,500 - 3,500',
      status: VacancyStatus.abierta,
      applicantsCount: 11,
      companyName: 'North Peak Labs',
      companyDescription:
          'Laboratorio de innovación para sistemas escalables y operaciones internas de alto impacto.',
      companyIndustry: 'Product Engineering',
      companyRating: 4.6,
      companyLocation: 'Bogotá, Colombia',
      companyLogoUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      featured: true,
    ),
  ];

  static final List<VacancyApplicationModel> _applications = [
    VacancyApplicationModel(
      id: 1,
      vacancyId: 1,
      freelancerId: 2,
      status: ApplicationStatus.enRevision,
      appliedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    VacancyApplicationModel(
      id: 2,
      vacancyId: 1,
      freelancerId: 3,
      status: ApplicationStatus.pendiente,
      appliedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    VacancyApplicationModel(
      id: 3,
      vacancyId: 3,
      freelancerId: 1,
      status: ApplicationStatus.pendiente,
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final Map<int, List<ApplicantModel>> _applicantsByVacancy = {
    1: [
      ApplicantModel(
        id: 1,
        vacancyId: 1,
        freelancer: _fallbackFreelancer(2),
        applicationStatus: ApplicationStatus.enRevision,
        appliedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      ApplicantModel(
        id: 2,
        vacancyId: 1,
        freelancer: _fallbackFreelancer(3),
        applicationStatus: ApplicationStatus.pendiente,
        appliedAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
    ],
    3: [
      ApplicantModel(
        id: 3,
        vacancyId: 3,
        freelancer: _fallbackFreelancer(1),
        applicationStatus: ApplicationStatus.pendiente,
        appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  };

  Future<List<VacancyModel>> getFreelancerVacancies({
    String query = '',
    String? category,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final normalizedQuery = query.trim().toLowerCase();

    return _vacancies.where((vacancy) {
      final matchesQuery = normalizedQuery.isEmpty ||
          vacancy.title.toLowerCase().contains(normalizedQuery) ||
          vacancy.description.toLowerCase().contains(normalizedQuery) ||
          vacancy.companyName.toLowerCase().contains(normalizedQuery) ||
          vacancy.category.toLowerCase().contains(normalizedQuery);

      final matchesCategory = category == null || category.isEmpty || category == 'Todas'
          ? true
          : vacancy.category == category;
      final matchesLocation = location == null || location.isEmpty || location == 'Todas'
          ? true
          : vacancy.location == location;

      return matchesQuery && matchesCategory && matchesLocation;
    }).toList();
  }

  Future<List<VacancyModel>> getCompanyVacancies({
    int companyId = currentCompanyId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 280));
    return _vacancies.where((vacancy) => vacancy.companyId == companyId).toList();
  }

  Future<VacancyModel?> getVacancyById(int id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    for (final vacancy in _vacancies) {
      if (vacancy.id == id) return vacancy;
    }
    return null;
  }

  Future<CompanyModel?> getCompanyById(int id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    for (final company in _companies) {
      if (company.id == id) return company;
    }
    return null;
  }

  Future<List<CompanyModel>> getCompanies({
    String query = '',
    String industry = 'Todas',
    String location = 'Todas',
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final normalizedQuery = query.trim().toLowerCase();

    final companies = _companies.where((company) {
      final matchesQuery = normalizedQuery.isEmpty ||
          company.name.toLowerCase().contains(normalizedQuery) ||
          company.description.toLowerCase().contains(normalizedQuery) ||
          company.industry.toLowerCase().contains(normalizedQuery);

      final matchesIndustry = industry == 'Todas' ||
          industry.trim().isEmpty ||
          company.industry == industry;

      final matchesLocation = location == 'Todas' ||
          location.trim().isEmpty ||
          company.location == location;

      return matchesQuery && matchesIndustry && matchesLocation;
    }).toList();

    companies.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return companies;
  }

  Future<List<String>> getCompanyIndustries() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final industries = _companies.map((company) => company.industry).toSet().toList();
    industries.sort();
    return industries;
  }

  Future<List<String>> getCompanyLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final locations = _companies.map((company) => company.location).toSet().toList();
    locations.sort();
    return locations;
  }

  Future<CompanyModel> updateCompany(CompanyModel company) async {
    await Future.delayed(const Duration(milliseconds: 260));

    final companyIndex = _companies.indexWhere((item) => item.id == company.id);
    if (companyIndex == -1) {
      throw Exception('La empresa no existe.');
    }

    _companies[companyIndex] = company;

    for (var i = 0; i < _vacancies.length; i++) {
      final vacancy = _vacancies[i];
      if (vacancy.companyId == company.id) {
        _vacancies[i] = vacancy.copyWith(
          companyName: company.name,
          companyDescription: company.description,
          companyIndustry: company.industry,
          companyRating: company.averageRating,
          companyLocation: company.location,
          companyLogoUrl: company.logoUrl,
        );
      }
    }

    return company;
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final categories = _vacancies.map((vacancy) => vacancy.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final locations = _vacancies.map((vacancy) => vacancy.location).toSet().toList();
    locations.sort();
    return locations;
  }

  Future<List<ApplicantModel>> getApplicantsByVacancyId(int vacancyId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    return List<ApplicantModel>.from(_applicantsByVacancy[vacancyId] ?? const []);
  }

  Future<List<VacancyApplicationModel>> getApplicationsByFreelancerId(
    int freelancerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 220));
    return _applications
        .where((application) => application.freelancerId == freelancerId)
        .toList();
  }

  Future<VacancyApplicationModel> applyToVacancy({
    required int vacancyId,
    required int freelancerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 320));

    final vacancyIndex = _vacancies.indexWhere((vacancy) => vacancy.id == vacancyId);
    if (vacancyIndex == -1) {
      throw Exception('La vacante no existe.');
    }

    for (final application in _applications) {
      if (application.vacancyId == vacancyId && application.freelancerId == freelancerId) {
        return application;
      }
    }

    final nextId = _applications.isEmpty ? 1 : _applications.last.id + 1;
    final application = VacancyApplicationModel(
      id: nextId,
      vacancyId: vacancyId,
      freelancerId: freelancerId,
      status: ApplicationStatus.pendiente,
      appliedAt: DateTime.now(),
    );
    _applications.add(application);

    final freelancer = _fallbackFreelancer(freelancerId);

    final applicant = ApplicantModel(
      id: nextId,
      vacancyId: vacancyId,
      freelancer: freelancer,
      applicationStatus: application.status,
      appliedAt: application.appliedAt,
    );

    final currentApplicants = _applicantsByVacancy[vacancyId] ?? <ApplicantModel>[];
    _applicantsByVacancy[vacancyId] = [...currentApplicants, applicant];

    final vacancy = _vacancies[vacancyIndex];
    _vacancies[vacancyIndex] = vacancy.copyWith(
      applicantsCount: vacancy.applicantsCount + 1,
    );

    return application;
  }

  Future<VacancyModel> createVacancy({
    required int companyId,
    required String title,
    required String description,
    required String category,
    required String location,
    required String salary,
    required VacancyStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 320));

    final company = await getCompanyById(companyId) ?? _companies.first;
    final nextId = _vacancies.isEmpty ? 1 : _vacancies.last.id + 1;
    final vacancy = VacancyModel(
      id: nextId,
      companyId: company.id,
      title: title.trim(),
      description: description.trim(),
      category: category.trim(),
      location: location.trim(),
      salary: salary.trim(),
      status: status,
      applicantsCount: 0,
      companyName: company.name,
      companyDescription: company.description,
      companyIndustry: company.industry,
      companyRating: company.averageRating,
      companyLocation: company.location,
      companyLogoUrl: company.logoUrl,
      postedAt: DateTime.now(),
      featured: false,
    );

    _vacancies.insert(0, vacancy);
    return vacancy;
  }

  Future<VacancyModel> updateVacancy(VacancyModel vacancy) async {
    await Future.delayed(const Duration(milliseconds: 280));

    final vacancyIndex = _vacancies.indexWhere((item) => item.id == vacancy.id);
    if (vacancyIndex == -1) {
      throw Exception('No se pudo actualizar la vacante.');
    }

    _vacancies[vacancyIndex] = vacancy;
    return vacancy;
  }

  Future<void> deleteVacancy(int vacancyId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    _vacancies.removeWhere((vacancy) => vacancy.id == vacancyId);
    _applications.removeWhere((application) => application.vacancyId == vacancyId);
    _applicantsByVacancy.remove(vacancyId);
  }

  Future<VacancyModel> changeVacancyStatus({
    required int vacancyId,
    required VacancyStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final vacancyIndex = _vacancies.indexWhere((vacancy) => vacancy.id == vacancyId);
    if (vacancyIndex == -1) {
      throw Exception('La vacante no existe.');
    }

    final vacancy = _vacancies[vacancyIndex].copyWith(status: status);
    _vacancies[vacancyIndex] = vacancy;
    return vacancy;
  }

  static FreelancerModel _fallbackFreelancer(int id) {
    return FreelancerModel(
      id: id,
      fullName: 'Freelancer $id',
      specialty: 'Perfil profesional',
      description: 'Perfil listo para integración con API real.',
      hourlyRate: 50.0,
      available: true,
      location: 'Por definir',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      rating: 4.5,
      availability: 'Disponible',
      shortDescription: 'Perfil listo para integración con API real.',
    );
  }
}