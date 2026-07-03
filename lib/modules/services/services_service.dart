import 'package:worklink_local/modules/freelancers/freelancers.dart';
import 'package:worklink_local/modules/services/models/service_model.dart';
import 'package:worklink_local/modules/services/models/service_request_model.dart';

class ServicesService {
  static const int currentFreelancerId = 1;
  static const int currentRequesterId = 901;
  static const String currentRequesterName = 'Empresa Demo';
  static const String currentRequesterAccountType = 'Empresa';
  static const String currentRequesterAvatarUrl =
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80';

  static final FreelancersService _freelancersService = FreelancersService();

  static final List<ServiceModel> _services = [
    ServiceModel(
      id: 1,
      freelancerId: 1,
      title: 'Desarrollo Flutter Modular',
      category: 'Desarrollo Móvil',
      shortDescription: 'Construcción de apps móviles escalables con Flutter y arquitectura limpia.',
      description:
          'Desarrollo de aplicaciones móviles completas con enfoque en escalabilidad, experiencia de usuario y estructura mantenible. Incluye componentes reutilizables, integración con APIs y preparación para crecimiento.',
      priceValue: 75,
        priceLabel: r'$45 / hora',
      modality: ServiceModality.remoto,
      estimatedTime: '2-4 semanas',
      status: ServiceStatus.activo,
      mainImageUrl:
          'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9f?auto=format&fit=crop&w=1200&q=80',
      galleryImages: const [
        'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9f?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1526498460520-4c246339dccb?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
      ],
      tags: const ['Flutter', 'Dart', 'Clean Architecture', 'API REST'],
      averageRating: 4.9,
      reviewCount: 31,
      interestedCount: 5,
      freelancerName: 'Juan Pérez',
      freelancerSpecialty: 'Flutter Developer',
      freelancerRating: 4.8,
      freelancerAvailability: 'Disponible',
      freelancerShortDescription: 'Desarrollador móvil especializado en Flutter y productos escalables.',
      freelancerAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      featured: true,
    ),
    ServiceModel(
      id: 2,
      freelancerId: 2,
      title: 'Diseño UI/UX para Productos Digitales',
      category: 'Diseño UX/UI',
      shortDescription: 'Interfaces modernas, sistemas de diseño y prototipos listos para validar.',
      description:
          'Servicio de diseño centrado en producto con investigación rápida, wireframes, UI visual y sistemas consistentes para apps y dashboards.',
      priceValue: 60,
        priceLabel: r'$38 / hora',
      modality: ServiceModality.hibrido,
      estimatedTime: '1-3 semanas',
      status: ServiceStatus.activo,
      mainImageUrl:
          'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
      galleryImages: const [
        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80',
      ],
      tags: const ['Figma', 'UI/UX', 'Design System', 'Prototipado'],
      averageRating: 4.9,
      reviewCount: 42,
      interestedCount: 8,
      freelancerName: 'Mariana López',
      freelancerSpecialty: 'UI/UX Designer',
      freelancerRating: 4.9,
      freelancerAvailability: 'Disponible',
      freelancerShortDescription: 'Diseño de productos digitales con foco en conversión y detalle visual.',
      freelancerAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    ServiceModel(
      id: 3,
      freelancerId: 3,
      title: 'Backend API + MySQL',
      category: 'Backend',
      shortDescription: 'APIs limpias con persistencia relacional, autenticación y reportes.',
      description:
          'Diseño e implementación de backends robustos para servicios digitales, con persistencia MySQL, seguridad básica y rutas listas para escalar.',
      priceValue: 90,
        priceLabel: r'$48 / hora',
      modality: ServiceModality.remoto,
      estimatedTime: '3-5 semanas',
      status: ServiceStatus.pausado,
      mainImageUrl:
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80',
      galleryImages: const [
        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=1200&q=80',
      ],
      tags: const ['Node.js', 'MySQL', 'REST APIs', 'JWT'],
      averageRating: 4.7,
      reviewCount: 27,
      interestedCount: 3,
      freelancerName: 'Carlos Medina',
      freelancerSpecialty: 'Node.js Backend',
      freelancerRating: 4.7,
      freelancerAvailability: 'Ocupado',
      freelancerShortDescription: 'Backend escalable para APIs, automatización y bases de datos relacionales.',
      freelancerAvatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ServiceModel(
      id: 4,
      freelancerId: 1,
      title: 'Mantenimiento y Evolución de Apps',
      category: 'Soporte',
      shortDescription: 'Soporte continuo, correcciones y nuevas iteraciones para apps existentes.',
      description:
          'Ideal para empresas que ya tienen una app en producción y necesitan mantenimiento, mejoras incrementales y soporte técnico continuo.',
      priceValue: 50,
        priceLabel: r'$32 / hora',
      modality: ServiceModality.porProyecto,
      estimatedTime: 'Mensual',
      status: ServiceStatus.activo,
      mainImageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1200&q=80',
      galleryImages: const [
        'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1200&q=80',
      ],
      tags: const ['Flutter', 'Soporte', 'Bugfixing', 'Releases'],
      averageRating: 4.8,
      reviewCount: 19,
      interestedCount: 6,
      freelancerName: 'Juan Pérez',
      freelancerSpecialty: 'Flutter Developer',
      freelancerRating: 4.8,
      freelancerAvailability: 'Disponible',
      freelancerShortDescription: 'Desarrollador móvil especializado en Flutter y productos escalables.',
      freelancerAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  static final List<ServiceRequestModel> _requests = [
    ServiceRequestModel(
      id: 1,
      serviceId: 1,
      requesterId: 501,
      requesterName: 'WorkLink Studio',
      accountType: 'Empresa',
      avatarUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=600&q=80',
      requestedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    ServiceRequestModel(
      id: 2,
      serviceId: 1,
      requesterId: 502,
      requesterName: 'Proyecto Retail',
      accountType: 'Cliente',
      avatarUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      requestedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    ServiceRequestModel(
      id: 3,
      serviceId: 2,
      requesterId: 503,
      requesterName: 'North Peak Labs',
      accountType: 'Empresa',
      avatarUrl:
          'https://images.unsplash.com/photo-1521790361543-f645cf042ec4?auto=format&fit=crop&w=600&q=80',
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<List<ServiceModel>> getServices({
    String query = '',
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 360));

    final normalizedQuery = query.trim().toLowerCase();

    final filtered = _services.where((service) {
      final matchesQuery = normalizedQuery.isEmpty ||
          service.title.toLowerCase().contains(normalizedQuery) ||
          service.shortDescription.toLowerCase().contains(normalizedQuery) ||
          service.description.toLowerCase().contains(normalizedQuery) ||
          service.freelancerName.toLowerCase().contains(normalizedQuery) ||
          service.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));

      final matchesCategory = category == null || category.isEmpty || category == 'Todas'
          ? true
          : service.category == category;

      final matchesMinPrice = minPrice == null ? true : service.priceValue >= minPrice;
      final matchesMaxPrice = maxPrice == null ? true : service.priceValue <= maxPrice;
      final matchesMinRating = minRating == null ? true : service.averageRating >= minRating;

      return matchesQuery && matchesCategory && matchesMinPrice && matchesMaxPrice && matchesMinRating;
    }).toList();

    filtered.sort((a, b) {
      if (a.featured != b.featured) return b.featured ? 1 : -1;
      return b.averageRating.compareTo(a.averageRating);
    });

    return filtered;
  }

  Future<List<ServiceModel>> getFreelancerServices({int freelancerId = currentFreelancerId}) async {
    await Future.delayed(const Duration(milliseconds: 280));
    final services = _services.where((service) => service.freelancerId == freelancerId).toList();
    services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return services;
  }

  Future<ServiceModel?> getServiceById(int id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final categories = _services.map((service) => service.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<String>> getModalities() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return ServiceModality.values.map((modality) => modality.label).toList();
  }

  Future<List<ServiceRequestModel>> getServiceRequestsByServiceId(int serviceId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final requests = _requests.where((request) => request.serviceId == serviceId).toList();
    requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return requests;
  }

  Future<ServiceRequestModel> requestService({
    required int serviceId,
    required int requesterId,
    required String requesterName,
    required String accountType,
    required String avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 320));

    final serviceIndex = _services.indexWhere((service) => service.id == serviceId);
    if (serviceIndex == -1) {
      throw Exception('El servicio no existe.');
    }

    for (final request in _requests) {
      if (request.serviceId == serviceId && request.requesterId == requesterId) {
        return request;
      }
    }

    final nextId = _requests.isEmpty ? 1 : _requests.last.id + 1;
    final request = ServiceRequestModel(
      id: nextId,
      serviceId: serviceId,
      requesterId: requesterId,
      requesterName: requesterName,
      accountType: accountType,
      avatarUrl: avatarUrl,
      requestedAt: DateTime.now(),
    );

    _requests.add(request);

    final service = _services[serviceIndex];
    _services[serviceIndex] = service.copyWith(
      interestedCount: service.interestedCount + 1,
    );

    return request;
  }

  Future<ServiceModel> createService({
    required int freelancerId,
    required String title,
    required String category,
    required String shortDescription,
    required String description,
    required double priceValue,
    required String priceLabel,
    required ServiceModality modality,
    required String estimatedTime,
    required ServiceStatus status,
    required String mainImageUrl,
    List<String> galleryImages = const [],
    List<String> tags = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 320));

    final freelancer = _freelancersService.getFreelancerById(freelancerId) ?? _fallbackFreelancer(freelancerId);
    final nextId = _services.isEmpty ? 1 : _services.last.id + 1;
    final service = ServiceModel(
      id: nextId,
      freelancerId: freelancer.id,
      title: title.trim(),
      category: category.trim(),
      shortDescription: shortDescription.trim(),
      description: description.trim(),
      priceValue: priceValue,
      priceLabel: priceLabel.trim(),
      modality: modality,
      estimatedTime: estimatedTime.trim(),
      status: status,
      mainImageUrl: mainImageUrl.trim(),
      galleryImages: galleryImages,
      tags: tags,
      averageRating: freelancer.rating,
      reviewCount: 0,
      interestedCount: 0,
      freelancerName: freelancer.fullName,
      freelancerSpecialty: freelancer.specialty,
      freelancerRating: freelancer.rating,
      freelancerAvailability: freelancer.availability,
      freelancerShortDescription: freelancer.shortDescription,
      freelancerAvatarUrl: freelancer.avatarUrl,
      createdAt: DateTime.now(),
      featured: false,
    );

    _services.insert(0, service);
    return service;
  }

  Future<ServiceModel> updateService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 280));

    final serviceIndex = _services.indexWhere((item) => item.id == service.id);
    if (serviceIndex == -1) {
      throw Exception('No se pudo actualizar el servicio.');
    }

    _services[serviceIndex] = service;
    return service;
  }

  Future<ServiceModel> changeServiceStatus({
    required int serviceId,
    required ServiceStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final serviceIndex = _services.indexWhere((item) => item.id == serviceId);
    if (serviceIndex == -1) {
      throw Exception('El servicio no existe.');
    }

    final service = _services[serviceIndex].copyWith(status: status);
    _services[serviceIndex] = service;
    return service;
  }

  Future<void> deleteService(int serviceId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    _services.removeWhere((service) => service.id == serviceId);
    _requests.removeWhere((request) => request.serviceId == serviceId);
  }

  static FreelancerModel _fallbackFreelancer(int id) {
    return FreelancerModel(
      id: id,
      fullName: 'Freelancer $id',
      specialty: 'Servicio profesional',
      rating: 4.5,
      availability: 'Disponible',
      shortDescription: 'Perfil listo para integración con API real.',
      location: 'Por definir',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
    );
  }
}