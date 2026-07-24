import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/companies/models/company_profile_model.dart';
import 'package:worklink_local/modules/companies/services/companies_service.dart';
import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';
import 'package:worklink_local/modules/vacancies/models/applicant_model.dart';
import 'package:worklink_local/modules/vacancies/models/company_model.dart';
import 'package:worklink_local/modules/vacancies/models/vacancy_model.dart';

class VacanciesFlowException implements Exception {
  final int? statusCode;
  final String message;

  const VacanciesFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class VacanciesService {
  final CompaniesService _companyProfilesService = CompaniesService();
  final Map<int, CompanyProfileModel?> _companyProfileCache = {};

  Future<List<VacancyModel>> getFreelancerVacancies({
    String query = '',
    String? category,
    String? location,
    int? minSalary,
    int? maxSalary,
    int? perPage,
  }) {
    return getPublicVacancies(
      query: query,
      category: category,
      location: location,
      minSalary: minSalary,
      maxSalary: maxSalary,
      perPage: perPage,
    );
  }

  Future<List<VacancyModel>> getPublicVacancies({
    String query = '',
    String? category,
    String? location,
    int? minSalary,
    int? maxSalary,
    int? perPage,
  }) async {
    final vacancies = await _fetchVacancies(
      _vacanciesUri(
        Apis.publicVacancies,
        query: query,
        category: category,
        location: location,
        minSalary: minSalary,
        maxSalary: maxSalary,
        perPage: perPage,
      ),
      public: true,
    );
    return _hydrateVacancies(vacancies);
  }

  Future<List<VacancyModel>> getPublicVacanciesByCompanyId(
    int companyId, {
    String query = '',
    String? category,
    String? location,
    int? minSalary,
    int? maxSalary,
    int? perPage,
  }) async {
    final vacancies = await _fetchVacancies(
      _vacanciesUri(
        Apis.publicVacanciesByCompanyId(companyId),
        query: query,
        category: category,
        location: location,
        minSalary: minSalary,
        maxSalary: maxSalary,
        perPage: perPage,
      ),
      public: true,
    );
    return _hydrateVacancies(vacancies);
  }

  Future<List<VacancyModel>> getVacancies({
    String query = '',
    String? category,
    String? location,
    String? status,
    int? perPage,
  }) async {
    final vacancies = await _fetchVacancies(
      _vacanciesUri(
        Apis.vacancies,
        query: query,
        category: category,
        location: location,
        status: status,
        perPage: perPage,
      ),
      public: false,
    );
    return _hydrateVacancies(vacancies);
  }

  Future<List<VacancyModel>> getCompanyVacancies({int? companyId}) async {
    final vacancies = await _fetchVacancies(
      companyId == null
          ? Apis.vacanciesMe
          : Apis.publicVacanciesByCompanyId(companyId),
      public: companyId != null,
    );
    return _hydrateVacancies(vacancies);
  }

  Future<VacancyModel?> getVacancyById(int id) async {
    final vacancy = await _fetchVacancyById(
      Apis.vacancyById(id),
      public: false,
    );
    if (vacancy == null) return null;
    return _hydrateVacancy(vacancy);
  }

  Future<VacancyModel?> getPublicVacancyById(int id) async {
    final vacancy = await _fetchVacancyById(
      Apis.publicVacancyById(id),
      public: true,
    );
    if (vacancy == null) return null;
    return _hydrateVacancy(vacancy);
  }

  Future<CompanyModel?> getCompanyById(int id) async {
    final profile = await _cachedPublicCompanyProfile(id);
    if (profile == null) return null;
    return _companyModelFromProfile(profile);
  }

  Future<List<CompanyModel>> getCompanies({
    String query = '',
    String industry = 'Todas',
    String location = 'Todas',
  }) async {
    final companies = await _companyProfilesService.getCompanies(
      query: query,
      industry: industry,
      location: location,
    );
    return companies.map(_companyModelFromProfile).toList();
  }

  Future<List<String>> getIndustries() {
    return _companyProfilesService.getIndustries();
  }

  Future<List<String>> getLocations() {
    return _companyProfilesService.getLocations();
  }

  Future<List<String>> getCategories() async {
    final vacancies = await getPublicVacancies(perPage: 200);
    final categories = vacancies
        .map((vacancy) => vacancy.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort(
      (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
    );
    return categories;
  }

  Future<List<VacancyApplicationModel>> getApplications({
    ApplicationStatus? status,
    int? vacancyId,
    int? freelancerId,
    String search = '',
    int? perPage,
  }) async {
    try {
      final response = await http
          .get(
            _applicationsUri(
              Apis.applications,
              status: status,
              vacancyId: vacancyId,
              freelancerId: freelancerId,
              search: search,
              perPage: perPage,
            ),
            headers: await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudieron cargar las postulaciones.'),
          statusCode: response.statusCode,
        );
      }

      return _extractApplicationsDataList(
        body,
      ).map(VacancyApplicationModel.fromJson).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<List<VacancyApplicationModel>> getMyApplications({
    ApplicationStatus? status,
    int? vacancyId,
    String search = '',
    int? perPage,
  }) async {
    try {
      final response = await http
          .get(
            _applicationsUri(
              Apis.applicationsMe,
              status: status,
              vacancyId: vacancyId,
              search: search,
              perPage: perPage,
            ),
            headers: await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudieron cargar tus postulaciones.'),
          statusCode: response.statusCode,
        );
      }

      return _extractApplicationsDataList(
        body,
      ).map(VacancyApplicationModel.fromJson).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<List<VacancyApplicationModel>> getApplicationsByFreelancerId(
    int freelancerId,
  ) {
    return getApplications(freelancerId: freelancerId);
  }

  Future<List<ApplicantModel>> getApplicantsByVacancyId(
    int vacancyId, {
    ApplicationStatus? status,
    String search = '',
    int? perPage,
  }) async {
    try {
      final response = await http
          .get(
            _applicationsUri(
              Apis.applicationsByVacancyId(vacancyId),
              status: status,
              search: search,
              perPage: perPage,
            ),
            headers: await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudieron cargar los postulantes.'),
          statusCode: response.statusCode,
        );
      }

      final rawItems = _extractApplicationsDataList(body);
      return rawItems.map((item) {
        final normalized = <String, dynamic>{...item, 'vacancy_id': vacancyId};
        return ApplicantModel.fromJson(normalized);
      }).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyApplicationModel?> getApplicationById(int id) async {
    try {
      final response = await http
          .get(Apis.applicationById(id), headers: await _headersWithToken())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) return null;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo cargar la postulación.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isEmpty) return null;
      return VacancyApplicationModel.fromJson(data);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyApplicationModel> applyToVacancy({
    required int vacancyId,
    String message = '',
  }) async {
    try {
      final response = await http
          .post(
            Apis.applications,
            headers: await _headersWithToken(),
            body: jsonEncode({
              'vacancy_id': vacancyId,
              if (message.trim().isNotEmpty) 'message': message.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo registrar la postulación.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return VacancyApplicationModel.fromJson(data);

      return VacancyApplicationModel(
        id: 0,
        vacancyId: vacancyId,
        freelancerId: 0,
        message: message.trim(),
        status: ApplicationStatus.pendiente,
        appliedAt: DateTime.now(),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyApplicationModel> updateApplicationMessage({
    required int applicationId,
    required String message,
  }) async {
    try {
      final response = await http
          .patch(
            Apis.applicationById(applicationId),
            headers: await _headersWithToken(),
            body: jsonEncode({'message': message.trim()}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo actualizar la postulación.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return VacancyApplicationModel.fromJson(data);

      final current = await getApplicationById(applicationId);
      if (current != null) return current.copyWith(message: message.trim());

      throw VacanciesFlowException(
        'No se pudo obtener la postulación actualizada.',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyApplicationModel> updateApplicationStatus({
    required int applicationId,
    required ApplicationStatus status,
  }) async {
    try {
      final response = await http
          .patch(
            Apis.applicationById(applicationId),
            headers: await _headersWithToken(),
            body: jsonEncode({'status': status.apiValue}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(
            body,
            'No se pudo actualizar el estado de la postulación.',
          ),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return VacancyApplicationModel.fromJson(data);

      final current = await getApplicationById(applicationId);
      if (current != null) return current.copyWith(status: status);

      throw VacanciesFlowException(
        'No se pudo obtener la postulación actualizada.',
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<void> deleteApplication(int applicationId) async {
    try {
      final response = await http
          .delete(
            Apis.applicationById(applicationId),
            headers: await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) return;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo eliminar la postulación.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyModel> createVacancy({
    int? companyId,
    required String title,
    required String description,
    required String category,
    required String location,
    String salary = '',
    VacancyStatus status = VacancyStatus.abierta,
  }) async {
    try {
      final token = await _requireToken();
      final response = await http
          .post(
            Apis.vacancies,
            headers: _headers(token),
            body: jsonEncode({
              if (companyId != null) 'company_id': companyId,
              'title': title.trim(),
              'description': description.trim(),
              'category': category.trim(),
              'location': location.trim(),
              if (salary.trim().isNotEmpty) 'salary': salary.trim(),
              if (status != VacancyStatus.abierta)
                'status': _statusToApi(status),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo crear la vacante.'),
          statusCode: response.statusCode,
        );
      }

      final vacancy = await _resolveVacancyFromResponse(
        body,
        fallback: VacancyModel(
          id: 0,
          companyId: companyId ?? (await getCurrentCompanyProfileId() ?? 0),
          title: title.trim(),
          description: description.trim(),
          category: category.trim(),
          location: location.trim(),
          salary: salary.trim(),
          status: status,
          applicantsCount: 0,
          companyName: '',
          companyDescription: '',
          companyIndustry: '',
          companyRating: 0,
          companyLocation: '',
          companyLogoUrl: '',
          postedAt: DateTime.now(),
          featured: false,
        ),
      );

      return _hydrateVacancy(vacancy);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyModel> updateVacancy(VacancyModel vacancy) async {
    try {
      final current = await getVacancyById(vacancy.id);
      if (current == null) {
        throw VacanciesFlowException('No se pudo actualizar la vacante.');
      }
      if (current.status == VacancyStatus.cerrada) {
        throw VacanciesFlowException(
          'La vacante está cerrada y no puede modificarse.',
        );
      }

      final token = await _requireToken();
      final response = await http
          .patch(
            Apis.vacancyById(vacancy.id),
            headers: _headers(token),
            body: jsonEncode({
              'title': vacancy.title.trim(),
              'description': vacancy.description.trim(),
              'category': vacancy.category.trim(),
              'location': vacancy.location.trim(),
              if (vacancy.salary.trim().isNotEmpty)
                'salary': vacancy.salary.trim(),
              'status': _statusToApi(vacancy.status),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo actualizar la vacante.'),
          statusCode: response.statusCode,
        );
      }

      final updated = await _resolveVacancyFromResponse(
        body,
        fallback: vacancy,
      );

      return _hydrateVacancy(updated);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<void> deleteVacancy(int vacancyId) async {
    try {
      final token = await _requireToken();
      final response = await http
          .delete(Apis.vacancyById(vacancyId), headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) return;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo eliminar la vacante.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyModel> changeVacancyStatus({
    required int vacancyId,
    required VacancyStatus status,
  }) async {
    try {
      final current = await getVacancyById(vacancyId);
      if (current == null) {
        throw VacanciesFlowException('La vacante no existe.');
      }
      if (current.status == VacancyStatus.cerrada &&
          status != VacancyStatus.cerrada) {
        throw VacanciesFlowException('La vacante cerrada no puede reabrirse.');
      }

      final token = await _requireToken();
      final response = await http
          .patch(
            Apis.vacancyById(vacancyId),
            headers: _headers(token),
            body: jsonEncode({'status': _statusToApi(status)}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(
            body,
            'No se pudo actualizar el estado de la vacante.',
          ),
          statusCode: response.statusCode,
        );
      }

      final updated = await _resolveVacancyFromResponse(
        body,
        fallback: current.copyWith(status: status),
      );

      return _hydrateVacancy(updated);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<int?> getCurrentCompanyProfileId() async {
    final profile = await _companyProfilesService.getMyCompanyProfile();
    return profile?.id;
  }

  Future<int?> getCurrentFreelancerProfileId() async {
    final user = await _currentUser();
    if (user == null) return null;

    final profile = await FreelancersService.getProfileByUserId(user.id);
    return profile?.id;
  }

  Future<List<VacancyModel>> _fetchVacancies(
    Uri uri, {
    required bool public,
  }) async {
    try {
      final response = await http
          .get(
            uri,
            headers: public ? _publicHeaders() : await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudieron cargar las vacantes.'),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(body).map(VacancyModel.fromJson).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyModel?> _fetchVacancyById(
    Uri uri, {
    required bool public,
  }) async {
    try {
      final response = await http
          .get(
            uri,
            headers: public ? _publicHeaders() : await _headersWithToken(),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 404) return null;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw VacanciesFlowException(
          _extractMessage(body, 'No se pudo cargar la vacante.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return VacancyModel.fromJson(data);

      final list = _extractDataList(body);
      if (list.isNotEmpty) return VacancyModel.fromJson(list.first);

      return null;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      if (e is VacanciesFlowException) rethrow;
      throw VacanciesFlowException(_normalizeError(e), statusCode: null);
    }
  }

  Future<VacancyModel> _hydrateVacancy(VacancyModel vacancy) async {
    final profile = await _cachedPublicCompanyProfile(vacancy.companyId);
    if (profile == null) return vacancy;

    return vacancy.copyWith(
      companyName: profile.companyName.isNotEmpty
          ? profile.companyName
          : vacancy.companyName,
      companyDescription: profile.description.isNotEmpty
          ? profile.description
          : vacancy.companyDescription,
      companyIndustry: profile.industry.isNotEmpty
          ? profile.industry
          : vacancy.companyIndustry,
      companyRating: profile.averageRate > 0
          ? profile.averageRate
          : vacancy.companyRating,
      companyLocation: profile.location.isNotEmpty
          ? profile.location
          : vacancy.companyLocation,
      companyLogoUrl: profile.photoUrl.isNotEmpty
          ? profile.photoUrl
          : vacancy.companyLogoUrl,
    );
  }

  Future<List<VacancyModel>> _hydrateVacancies(
    List<VacancyModel> vacancies,
  ) async {
    return Future.wait(vacancies.map(_hydrateVacancy));
  }

  Future<CompanyProfileModel?> _cachedPublicCompanyProfile(
    int companyId,
  ) async {
    if (_companyProfileCache.containsKey(companyId)) {
      return _companyProfileCache[companyId];
    }

    final profile = await _companyProfilesService.getPublicCompanyById(
      companyId,
    );
    _companyProfileCache[companyId] = profile;
    return profile;
  }

  CompanyModel _companyModelFromProfile(CompanyProfileModel profile) {
    return CompanyModel(
      id: profile.id,
      name: profile.companyName,
      description: profile.description,
      industry: profile.industry,
      location: profile.location,
      averageRating: profile.averageRate,
      logoUrl: profile.photoUrl,
      status: 'Activa',
      corporateInfo: '',
      website: '',
      foundedYear: '',
      size: '',
      activeVacanciesCount: 0,
    );
  }

  Future<UserModel?> _currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(Constants.userEmailKey);
    if (rawUser == null || rawUser.trim().isEmpty) return null;

    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<String> _requireToken() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      throw VacanciesFlowException('No se encontró un token de acceso.');
    }
    return token;
  }

  Future<Map<String, String>> _headersWithToken() async {
    final token = await _requireToken();
    return _headers(token);
  }

  Map<String, String> _publicHeaders() {
    return const {'Accept': 'application/json'};
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Uri _vacanciesUri(
    Uri base, {
    String query = '',
    String? category,
    String? location,
    String? status,
    int? minSalary,
    int? maxSalary,
    int? perPage,
  }) {
    final params = <String, String>{};

    if (query.trim().isNotEmpty) params['search'] = query.trim();
    if (category != null && category.trim().isNotEmpty && category != 'Todas') {
      params['category'] = category.trim();
    }
    if (location != null && location.trim().isNotEmpty && location != 'Todas') {
      params['location'] = location.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      params['status'] = status.trim();
    }
    if (minSalary != null) params['min_salary'] = minSalary.toString();
    if (maxSalary != null) params['max_salary'] = maxSalary.toString();
    if (perPage != null) params['per_page'] = perPage.toString();

    if (params.isEmpty) return base;
    return base.replace(queryParameters: params);
  }

  Uri _applicationsUri(
    Uri base, {
    ApplicationStatus? status,
    int? vacancyId,
    int? freelancerId,
    String search = '',
    int? perPage,
  }) {
    final params = <String, String>{};

    if (status != null) params['status'] = status.apiValue;
    if (vacancyId != null) params['vacancy_id'] = vacancyId.toString();
    if (freelancerId != null) params['freelancer_id'] = freelancerId.toString();
    if (search.trim().isNotEmpty) params['search'] = search.trim();
    if (perPage != null) params['per_page'] = perPage.toString();

    if (params.isEmpty) return base;
    return base.replace(queryParameters: params);
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  bool _isSuccessful(int statusCode, dynamic body) {
    if (statusCode >= 200 && statusCode < 300) return true;
    if (body is Map<String, dynamic>) {
      final success = body['success'];
      if (success is bool) return success;
    }
    return false;
  }

  List<Map<String, dynamic>> _extractDataList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();

      final results = body['results'];
      if (results is List) {
        return results.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractApplicationsDataList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();

      if (data is Map<String, dynamic>) {
        final nestedApps = data['applications'];
        if (nestedApps is List) {
          return nestedApps.whereType<Map<String, dynamic>>().toList();
        }

        final nestedData = data['data'];
        if (nestedData is List) {
          return nestedData.whereType<Map<String, dynamic>>().toList();
        }
      }

      final applications = body['applications'];
      if (applications is List) {
        return applications.whereType<Map<String, dynamic>>().toList();
      }

      final items = body['items'];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractDataMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      final result = body['result'];
      if (result is Map<String, dynamic>) return result;

      return body;
    }

    if (body is List && body.isNotEmpty && body.first is Map<String, dynamic>) {
      return body.first as Map<String, dynamic>;
    }

    return const <String, dynamic>{};
  }

  String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return fallback;
  }

  String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  String _statusToApi(VacancyStatus status) {
    switch (status) {
      case VacancyStatus.abierta:
        return 'open';
      case VacancyStatus.pausada:
        return 'paused';
      case VacancyStatus.cerrada:
        return 'closed';
    }
  }

  Future<VacancyModel> _resolveVacancyFromResponse(
    dynamic body, {
    required VacancyModel fallback,
  }) async {
    final data = _extractDataMap(body);
    final list = _extractDataList(body);

    VacancyModel vacancy = fallback;
    if (data.isNotEmpty) {
      vacancy = VacancyModel.fromJson(data);
    } else if (list.isNotEmpty) {
      vacancy = VacancyModel.fromJson(list.first);
    }

    return _hydrateVacancy(vacancy);
  }
}
