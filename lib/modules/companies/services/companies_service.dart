import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';
import 'package:worklink_local/modules/vacancies/services/vacancies_service.dart';

class CompaniesService {
  final VacanciesService _vacanciesService = VacanciesService();

  // Mock para ownership mientras no exista endpoint dedicado.
  static const Map<int, int> _companyOwnerByUser = {
    1: 1,
    2: 2,
  };

  Future<List<CompanyModel>> getCompanies({
    String query = '',
    String industry = 'Todas',
    String location = 'Todas',
  }) {
    return _vacanciesService.getCompanies(
      query: query,
      industry: industry,
      location: location,
    );
  }

  Future<List<String>> getIndustries() {
    return _vacanciesService.getCompanyIndustries();
  }

  Future<List<String>> getLocations() {
    return _vacanciesService.getCompanyLocations();
  }

  Future<CompanyModel?> getCompanyById(int companyId) {
    return _vacanciesService.getCompanyById(companyId);
  }

  Future<List<VacancyModel>> getCompanyVacancies(int companyId) {
    return _vacanciesService.getCompanyVacancies(companyId: companyId);
  }

  Future<CompanyModel?> getMyCompanyProfile(int userId) async {
    final companyId = _companyOwnerByUser[userId];
    if (companyId == null) return null;
    return _vacanciesService.getCompanyById(companyId);
  }

  Future<CompanyModel> updateCompanyProfile(CompanyModel company) {
    return _vacanciesService.updateCompany(company);
  }

  bool canEditCompany({required int userId, required int companyId}) {
    return _companyOwnerByUser[userId] == companyId;
  }
}
