import 'dart:async' show TimeoutException;
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/constants.dart';
import 'package:worklink_local/helpers/services/secure_storage_service.dart';
import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/portfolio/models/portfolio_model.dart';
import 'package:worklink_local/modules/portfolio/models/project_model.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioService {
  Future<PortfolioModel> getPortfolioByFreelancerId(int? freelancerId) async {
    try {
      final payload = await _getBriefcasesPayload(freelancerId: freelancerId);
      final freelancer = _extractFreelancerProfile(payload);
      final projects = _extractBriefcasesList(payload)
          .whereType<Map<String, dynamic>>()
          .map(mapBriefcaseToProject)
          .toList();

      final resolvedFreelancerId =
          freelancer?.id ??
          freelancerId ??
          _parseInt(payload['data']?['freelancer_profile']?['id']) ??
          0;

      if (freelancer == null) {
        return _emptyPortfolio(resolvedFreelancerId, projects: projects);
      }

      return _buildPortfolioFromProfile(
        profile: freelancer,
        projects: projects,
      );
    } on TimeoutException {
      return _emptyPortfolio(freelancerId ?? 0);
    } catch (_) {
      return _emptyPortfolio(freelancerId ?? 0);
    }
  }

  Future<FreelancerModel> getFreelancerById(int freelancerId) async {
    return await FreelancersService.getFreelancerById(freelancerId) ??
        _fallbackFreelancer(1);
  }

  Future<Map<String, dynamic>> _getBriefcasesPayload({int? freelancerId}) async {
    try {
      final token = await SecureStorageService.getToken();
      final targetUri =
          freelancerId != null && freelancerId > 0
              ? Apis.briefcasesByFreelancerId(freelancerId)
              : Apis.briefcasesMe;

      final response = await http
          .get(
            targetUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return <String, dynamic>{};
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return <String, dynamic>{};
      }

      return body;
    } on TimeoutException {
      rethrow;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  FreelancerModel? _extractFreelancerProfile(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final profileRaw = data['freelancer_profile'];
    if (profileRaw is! Map<String, dynamic>) {
      return null;
    }

    try {
      return FreelancerModel.fromJson(profileRaw);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractBriefcasesList(Map<String, dynamic> body) {
    final data = body['data'];

    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final briefcases = data['briefcases'];
      if (briefcases is List<dynamic>) {
        return briefcases;
      }
    }

    return const [];
  }

  PortfolioModel _buildPortfolioFromProfile({
    required FreelancerModel profile,
    required List<ProjectModel> projects,
  }) {
    final rate = profile.hourlyRate <= 0
        ? 'No especificado'
        : '\$${profile.hourlyRate.toStringAsFixed(0)}/h';

    return PortfolioModel(
      freelancerId: profile.id ?? profile.userId ?? 0,
      about: profile.description.trim().isEmpty
          ? 'Aun sin descripcion profesional.'
          : profile.description,
      skills: _extractSkills(profile),
      hourlyRate: rate,
      experience: _normalizeExperience(profile),
      availabilityNote: profile.available
          ? 'Disponible para nuevos proyectos.'
          : 'No disponible actualmente.',
      projects: projects,
    );
  }

  List<String> _extractSkills(FreelancerModel profile) {
    final skills = <String>[];

    skills.addAll(profile.languages.where((item) => item.trim().isNotEmpty));
    if (profile.serviceArea != null && profile.serviceArea!.trim().isNotEmpty) {
      skills.addAll(
        profile.serviceArea!
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty),
      );
    }

    if (skills.isNotEmpty) {
      return skills;
    }

    if (profile.specialty.trim().isNotEmpty) {
      return [profile.specialty.trim()];
    }

    return const ['Sin habilidades registradas'];
  }

  String _normalizeExperience(FreelancerModel profile) {
    final value = (profile.experience ?? '').trim();
    if (value.isNotEmpty) {
      return value;
    }
    return 'Experiencia no especificada';
  }

  ProjectModel mapBriefcaseToProject(Map<String, dynamic> raw) {
    final title =
        (raw['title'] ??
                raw['name'] ??
                raw['project_name'] ??
                'Proyecto sin titulo')
            .toString();

    final description =
        (raw['description'] ?? raw['summary'] ?? 'Sin descripcion').toString();

    final fullDescription =
        (raw['full_description'] ?? raw['content'] ?? description).toString();

    final imageUrl =
        (raw['image_url'] ?? raw['cover_url'] ?? raw['thumbnail'] ?? '')
            .toString();

    final technologies = _extractProjectTags(raw);

    return ProjectModel(
      id: _parseInt(raw['id']) ?? DateTime.now().millisecondsSinceEpoch,
      freelancerId: _parseInt(
        raw['freelancer_id'] ??
            raw['profile_id'] ??
            raw['freelancer_profile_id'],
      ),
      title: title,
      description: description,
      imageUrl: imageUrl,
      projectUrl:
          (raw['project_url'] ?? raw['project_link'] ?? raw['url'] ?? '')
              .toString(),
      dateLabel: _formatDateLabel(
        raw['created_at'] ?? raw['date'] ?? raw['updated_at'],
      ),
      fullDescription: fullDescription,
      technologies: technologies,
    );
  }

  Future<ProjectModel> createProject({
    required ProjectModel project,
    int? freelancerId,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
      }

      final profileId = await _resolveFreelancerProfileId(
        fallbackFreelancerId: freelancerId,
      );

      final request = http.MultipartRequest('POST', Apis.briefcases);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['freelancer_id'] = profileId.toString();
      request.fields['title'] = project.title.trim();
      if (project.description.trim().isNotEmpty) {
        request.fields['description'] = project.description.trim();
      }
      if (project.projectUrl.trim().isNotEmpty) {
        request.fields['project_url'] = project.projectUrl.trim();
        request.fields['project_link'] = project.projectUrl.trim();
      }

      final localImagePath = project.imageUrl.trim();
      final canAttachImage =
          localImagePath.isNotEmpty &&
          !localImagePath.toLowerCase().startsWith('http') &&
          File(localImagePath).existsSync();

      if (canAttachImage) {
        request.files.add(
          await http.MultipartFile.fromPath('image_url', localImagePath),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          body['success'] == true) {
        final data =
            body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        return mapBriefcaseToProject(data);
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo crear el proyecto',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ProjectModel> updateProject({
    required int projectId,
    required ProjectModel project,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
      }

      final response = await http
          .put(
            Apis.briefcaseById(projectId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'title': project.title.trim(),
              'description': project.description.trim(),
              'project_url': project.projectUrl.trim(),
              'project_link': project.projectUrl.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final data =
            body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
        return mapBriefcaseToProject(data);
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar el proyecto',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> updateProjectImage({
    required int projectId,
    required String imagePath,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
      }

      final path = imagePath.trim();
      if (path.isEmpty || !File(path).existsSync()) {
        throw Exception('No se encontró la imagen seleccionada.');
      }

      final request = http.MultipartRequest(
        'POST',
        Apis.briefcaseImageById(projectId),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.files.add(await http.MultipartFile.fromPath('image_url', path));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 201;
      if (isSuccessStatus && body['success'] == true) {
        return;
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        final firstError = _extractFirstValidationError(body);
        if (firstError != null && firstError.trim().isNotEmpty) {
          throw Exception(firstError);
        }
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo actualizar la imagen',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteProjectImage(int projectId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
      }

      final response = await http
          .delete(
            Apis.briefcaseImageById(projectId),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = response.body.trim().isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 204;
      final successFlag = body['success'];

      if (isSuccessStatus && (successFlag == null || successFlag == true)) {
        return;
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo eliminar la imagen',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible. Inicia sesión de nuevo.');
      }

      final response = await http
          .delete(
            Apis.briefcaseById(projectId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if ((response.statusCode == 200 || response.statusCode == 204) &&
          (body['success'] == true || response.statusCode == 204)) {
        return;
      }

      throw Exception(
        body['message']?.toString() ?? 'No se pudo eliminar el proyecto',
      );
    } on TimeoutException {
      throw TimeoutException(
        'La solicitud tardó demasiado. Intenta nuevamente.',
      );
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  List<String> _extractProjectTags(Map<String, dynamic> raw) {
    final dynamic tags = raw['technologies'] ?? raw['tags'] ?? raw['stack'];

    if (tags is List) {
      return tags
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (tags is String && tags.trim().isNotEmpty) {
      return tags
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const ['Sin tags'];
  }

  String _formatDateLabel(dynamic rawDate) {
    if (rawDate == null) {
      return 'Fecha no disponible';
    }

    final raw = rawDate.toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  PortfolioModel _emptyPortfolio(
    int freelancerId, {
    List<ProjectModel> projects = const [],
  }) {
    return PortfolioModel(
      freelancerId: freelancerId,
      about: 'Aun sin informacion profesional.',
      skills: const ['Sin habilidades registradas'],
      hourlyRate: 'No especificado',
      experience: 'Experiencia no especificada',
      availabilityNote: 'Disponibilidad no especificada',
      projects: projects,
    );
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<int> _resolveFreelancerProfileId({int? fallbackFreelancerId}) async {
    final currentUserId = await _getCurrentUserId();

    if (currentUserId != null && currentUserId > 0) {
      final profile = await FreelancersService.getProfileByUserId(currentUserId);
      final profileId = profile?.id;
      if (profileId != null && profileId > 0) {
        return profileId;
      }
    }

    if (fallbackFreelancerId != null && fallbackFreelancerId > 0) {
      return fallbackFreelancerId;
    }

    throw Exception(
      'No se encontró el perfil freelancer del usuario. Crea o completa tu perfil profesional para continuar.',
    );
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString(Constants.userEmailKey);
    if (userRaw == null || userRaw.trim().isEmpty) {
      return null;
    }

    try {
      final user = UserModel.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
      if (user.id > 0) {
        return user.id;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractFirstValidationError(Map<String, dynamic> body) {
    final errors = body['errors'] as Map<String, dynamic>?;
    if (errors == null || errors.isEmpty) {
      return null;
    }

    final firstValue = errors.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first?.toString();
    }

    return firstValue?.toString();
  }

  static FreelancerModel _fallbackFreelancer(int id) {
    return FreelancerModel(
      id: id,
      fullName: 'Juan Pérez',
      specialty: 'Flutter Developer',
      description: 'Desarrollador móvil especializado en Flutter y Firebase.',
      hourlyRate: 50.0,
      available: true,
      location: 'Monterrey, México',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      rating: 4.8,
      availability: 'Disponible',
      shortDescription:
          'Desarrollador móvil especializado en Flutter y Firebase.',
    );
  }
}
