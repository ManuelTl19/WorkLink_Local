import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/requests/models/requester_profile_model.dart';
import 'package:worklink_local/modules/requests/models/work_request_model.dart';

class RequestsService {
  static const int currentRequesterId = 1;
  static const String currentRequesterName = 'WorkLink Studio';
  static const String currentRequesterAccountType = 'Empresa';
  static const String currentRequesterAvatarUrl =
      'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80';

  static final FreelancersService _freelancersService = FreelancersService();

  static final List<RequesterProfileModel> _requesters = [
    const RequesterProfileModel(
      id: 1,
      name: 'WorkLink Studio',
      description:
          'Equipo de producto y tecnología enfocado en lanzar soluciones digitales con rapidez y calidad visual.',
      accountType: 'Empresa',
      location: 'Monterrey, México',
      rating: 4.8,
      avatarUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      relevantInfo: 'Equipo ágil, proyectos móviles y necesidades de soporte continuo.',
      website: 'worklinkstudio.com',
    ),
    const RequesterProfileModel(
      id: 2,
      name: 'Laura Gómez',
      description:
          'Cliente independiente con un negocio en crecimiento que necesita apoyo técnico puntual.',
      accountType: 'Cliente',
      location: 'Bogotá, Colombia',
      rating: 4.6,
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=600&q=80',
      relevantInfo: 'Proyecto comercial en fase de expansión y validación de producto.',
      website: 'lauragomez.co',
    ),
    const RequesterProfileModel(
      id: 3,
      name: 'North Peak Labs',
      description:
          'Laboratorio de innovación con necesidades de desarrollo backend, automatización y datos.',
      accountType: 'Empresa',
      location: 'Madrid, España',
      rating: 4.7,
      avatarUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      relevantInfo: 'Buscan talento freelance para sprints de producto y mejoras incrementales.',
      website: 'northpeaklabs.io',
    ),
  ];

  static final List<WorkRequestModel> _requests = [
    WorkRequestModel(
      id: 1,
      requesterId: 1,
      title: 'Rediseño de app móvil para clientes',
      category: 'Diseño UX/UI',
      shortDescription: 'Necesitamos modernizar la experiencia visual de una app ya publicada.',
      description:
          'Buscamos apoyo para rediseñar pantallas clave, mejorar la jerarquía visual y preparar un sistema de diseño que podamos mantener a futuro.',
      budgetValue: 1800,
      budgetLabel: r'$1,800',
      location: 'Monterrey, México',
      modality: RequestModality.hibrido,
      status: RequestStatus.abierta,
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      requesterName: 'WorkLink Studio',
      requesterAccountType: 'Empresa',
      requesterAvatarUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      requesterRating: 4.8,
      requesterDescription:
          'Equipo de producto y tecnología enfocado en lanzar soluciones digitales con rapidez y calidad visual.',
      requesterLocation: 'Monterrey, México',
      requesterRelevantInfo: 'Equipo ágil, proyectos móviles y necesidades de soporte continuo.',
      requesterWebsite: 'worklinkstudio.com',
      interestedCount: 6,
      featured: true,
    ),
    WorkRequestModel(
      id: 2,
      requesterId: 2,
      title: 'Desarrollo de landing page para campaña',
      category: 'Desarrollo Web',
      shortDescription: 'Buscamos una landing optimizada para conversión y rápida carga.',
      description:
          'Necesitamos una landing page moderna con formulario, secciones informativas y enfoque total en conversión y rendimiento.',
      budgetValue: 950,
      budgetLabel: r'$950',
      location: 'Bogotá, Colombia',
      modality: RequestModality.remoto,
      status: RequestStatus.abierta,
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
      requesterName: 'Laura Gómez',
      requesterAccountType: 'Cliente',
      requesterAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=600&q=80',
      requesterRating: 4.6,
      requesterDescription:
          'Cliente independiente con un negocio en crecimiento que necesita apoyo técnico puntual.',
      requesterLocation: 'Bogotá, Colombia',
      requesterRelevantInfo: 'Proyecto comercial en fase de expansión y validación de producto.',
      requesterWebsite: 'lauragomez.co',
      interestedCount: 3,
    ),
    WorkRequestModel(
      id: 3,
      requesterId: 3,
      title: 'Automatización de procesos internos',
      category: 'Backend',
      shortDescription: 'Se requiere un flujo estable para automatizar tareas operativas.',
      description:
          'Buscamos un freelancer que nos ayude a conectar servicios internos, automatizar reportes y mejorar tiempos de respuesta.',
      budgetValue: 2500,
      budgetLabel: r'$2,500',
      location: 'Madrid, España',
      modality: RequestModality.remoto,
      status: RequestStatus.enProceso,
      postedAt: DateTime.now().subtract(const Duration(days: 6)),
      requesterName: 'North Peak Labs',
      requesterAccountType: 'Empresa',
      requesterAvatarUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      requesterRating: 4.7,
      requesterDescription:
          'Laboratorio de innovación con necesidades de desarrollo backend, automatización y datos.',
      requesterLocation: 'Madrid, España',
      requesterRelevantInfo: 'Buscan talento freelance para sprints de producto y mejoras incrementales.',
      requesterWebsite: 'northpeaklabs.io',
      interestedCount: 4,
    ),
    WorkRequestModel(
      id: 4,
      requesterId: 1,
      title: 'Soporte mensual para app en producción',
      category: 'Soporte',
      shortDescription: 'Requerimos mejoras pequeñas, correcciones y seguimiento mensual.',
      description:
          'Necesitamos un freelancer para soporte continuo, mantenimiento correctivo y pequeñas mejoras de la app principal.',
      budgetValue: 1200,
      budgetLabel: r'$1,200',
      location: 'Remoto',
      modality: RequestModality.remoto,
      status: RequestStatus.abierta,
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      requesterName: 'WorkLink Studio',
      requesterAccountType: 'Empresa',
      requesterAvatarUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      requesterRating: 4.8,
      requesterDescription:
          'Equipo de producto y tecnología enfocado en lanzar soluciones digitales con rapidez y calidad visual.',
      requesterLocation: 'Monterrey, México',
      requesterRelevantInfo: 'Equipo ágil, proyectos móviles y necesidades de soporte continuo.',
      requesterWebsite: 'worklinkstudio.com',
      interestedCount: 2,
    ),
  ];

  Future<List<WorkRequestModel>> getRequests({
    String query = '',
    String? category,
    String? location,
    double? minBudget,
    double? maxBudget,
  }) async {
    await Future.delayed(const Duration(milliseconds: 360));
    final normalizedQuery = query.trim().toLowerCase();

    return _requests.where((request) {
      final matchesQuery = normalizedQuery.isEmpty ||
          request.title.toLowerCase().contains(normalizedQuery) ||
          request.description.toLowerCase().contains(normalizedQuery) ||
          request.shortDescription.toLowerCase().contains(normalizedQuery) ||
          request.requesterName.toLowerCase().contains(normalizedQuery) ||
          request.category.toLowerCase().contains(normalizedQuery);

      final matchesCategory = category == null || category.isEmpty || category == 'Todas'
          ? true
          : request.category == category;

      final matchesLocation = location == null || location.isEmpty || location == 'Todas'
          ? true
          : request.location == location;

      final matchesMinBudget = minBudget == null ? true : request.budgetValue >= minBudget;
      final matchesMaxBudget = maxBudget == null ? true : request.budgetValue <= maxBudget;

      return matchesQuery && matchesCategory && matchesLocation && matchesMinBudget && matchesMaxBudget;
    }).toList()
      ..sort((a, b) {
        if (a.featured != b.featured) return b.featured ? 1 : -1;
        return b.postedAt.compareTo(a.postedAt);
      });
  }

  Future<List<WorkRequestModel>> getMyRequests({int requesterId = currentRequesterId}) async {
    await Future.delayed(const Duration(milliseconds: 280));
    return _requests.where((request) => request.requesterId == requesterId).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  Future<WorkRequestModel?> getRequestById(int id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  Future<RequesterProfileModel?> getRequesterById(int id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    for (final requester in _requesters) {
      if (requester.id == id) return requester;
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final categories = _requests.map((request) => request.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final locations = _requests.map((request) => request.location).toSet().toList();
    locations.sort();
    return locations;
  }

  Future<WorkRequestModel> createRequest({
    required int requesterId,
    required String title,
    required String category,
    required String shortDescription,
    required String description,
    required double budgetValue,
    required String budgetLabel,
    required String location,
    required RequestModality modality,
    required RequestStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 320));

    final requester = await getRequesterById(requesterId) ?? _requesters.first;
    final nextId = _requests.isEmpty ? 1 : _requests.last.id + 1;
    final request = WorkRequestModel(
      id: nextId,
      requesterId: requester.id,
      title: title.trim(),
      category: category.trim(),
      shortDescription: shortDescription.trim(),
      description: description.trim(),
      budgetValue: budgetValue,
      budgetLabel: budgetLabel.trim(),
      location: location.trim(),
      modality: modality,
      status: status,
      postedAt: DateTime.now(),
      requesterName: requester.name,
      requesterAccountType: requester.accountType,
      requesterAvatarUrl: requester.avatarUrl,
      requesterRating: requester.rating,
      requesterDescription: requester.description,
      requesterLocation: requester.location,
      requesterRelevantInfo: requester.relevantInfo,
      requesterWebsite: requester.website,
      interestedCount: 0,
      featured: false,
    );

    _requests.insert(0, request);
    return request;
  }

  Future<WorkRequestModel> updateRequest(WorkRequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 280));
    final requestIndex = _requests.indexWhere((item) => item.id == request.id);
    if (requestIndex == -1) {
      throw Exception('No se pudo actualizar la solicitud.');
    }

    _requests[requestIndex] = request;
    return request;
  }

  Future<WorkRequestModel> changeRequestStatus({
    required int requestId,
    required RequestStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final requestIndex = _requests.indexWhere((item) => item.id == requestId);
    if (requestIndex == -1) {
      throw Exception('La solicitud no existe.');
    }

    final request = _requests[requestIndex].copyWith(status: status);
    _requests[requestIndex] = request;
    return request;
  }

  Future<void> deleteRequest(int requestId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    _requests.removeWhere((request) => request.id == requestId);
  }

  static FreelancerModel get fallbackFreelancer => const FreelancerModel(
        id: 1,
        fullName: 'Juan Pérez',
        specialty: 'Flutter Developer',
        rating: 4.8,
        availability: 'Disponible',
        shortDescription: 'Desarrollador móvil especializado en Flutter y Firebase.',
        location: 'Monterrey, México',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      );
}
