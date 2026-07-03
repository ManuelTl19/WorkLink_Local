enum ServiceStatus { activo, pausado, archivado }

extension ServiceStatusX on ServiceStatus {
  String get label {
    switch (this) {
      case ServiceStatus.activo:
        return 'Activo';
      case ServiceStatus.pausado:
        return 'Pausado';
      case ServiceStatus.archivado:
        return 'Archivado';
    }
  }
}

ServiceStatus serviceStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text.contains('paus')) return ServiceStatus.pausado;
  if (text.contains('arch')) return ServiceStatus.archivado;
  return ServiceStatus.activo;
}

enum ServiceModality { remoto, presencial, hibrido, porProyecto }

extension ServiceModalityX on ServiceModality {
  String get label {
    switch (this) {
      case ServiceModality.remoto:
        return 'Remoto';
      case ServiceModality.presencial:
        return 'Presencial';
      case ServiceModality.hibrido:
        return 'Híbrido';
      case ServiceModality.porProyecto:
        return 'Por proyecto';
    }
  }
}

ServiceModality serviceModalityFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text.contains('pres')) return ServiceModality.presencial;
  if (text.contains('hibr')) return ServiceModality.hibrido;
  if (text.contains('proy')) return ServiceModality.porProyecto;
  return ServiceModality.remoto;
}

class ServiceModel {
  final int id;
  final int freelancerId;
  final String title;
  final String category;
  final String shortDescription;
  final String description;
  final double priceValue;
  final String priceLabel;
  final ServiceModality modality;
  final String estimatedTime;
  final ServiceStatus status;
  final String mainImageUrl;
  final List<String> galleryImages;
  final List<String> tags;
  final double averageRating;
  final int reviewCount;
  final int interestedCount;
  final String freelancerName;
  final String freelancerSpecialty;
  final double freelancerRating;
  final String freelancerAvailability;
  final String freelancerShortDescription;
  final String freelancerAvatarUrl;
  final DateTime createdAt;
  final bool featured;

  const ServiceModel({
    required this.id,
    required this.freelancerId,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.priceValue,
    required this.priceLabel,
    required this.modality,
    required this.estimatedTime,
    required this.status,
    required this.mainImageUrl,
    required this.galleryImages,
    required this.tags,
    required this.averageRating,
    required this.reviewCount,
    required this.interestedCount,
    required this.freelancerName,
    required this.freelancerSpecialty,
    required this.freelancerRating,
    required this.freelancerAvailability,
    required this.freelancerShortDescription,
    required this.freelancerAvatarUrl,
    required this.createdAt,
    this.featured = false,
  });

  bool get isActive => status == ServiceStatus.activo;

  ServiceModel copyWith({
    int? id,
    int? freelancerId,
    String? title,
    String? category,
    String? shortDescription,
    String? description,
    double? priceValue,
    String? priceLabel,
    ServiceModality? modality,
    String? estimatedTime,
    ServiceStatus? status,
    String? mainImageUrl,
    List<String>? galleryImages,
    List<String>? tags,
    double? averageRating,
    int? reviewCount,
    int? interestedCount,
    String? freelancerName,
    String? freelancerSpecialty,
    double? freelancerRating,
    String? freelancerAvailability,
    String? freelancerShortDescription,
    String? freelancerAvatarUrl,
    DateTime? createdAt,
    bool? featured,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      freelancerId: freelancerId ?? this.freelancerId,
      title: title ?? this.title,
      category: category ?? this.category,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      priceValue: priceValue ?? this.priceValue,
      priceLabel: priceLabel ?? this.priceLabel,
      modality: modality ?? this.modality,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      status: status ?? this.status,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      interestedCount: interestedCount ?? this.interestedCount,
      freelancerName: freelancerName ?? this.freelancerName,
      freelancerSpecialty: freelancerSpecialty ?? this.freelancerSpecialty,
      freelancerRating: freelancerRating ?? this.freelancerRating,
      freelancerAvailability: freelancerAvailability ?? this.freelancerAvailability,
      freelancerShortDescription: freelancerShortDescription ?? this.freelancerShortDescription,
      freelancerAvatarUrl: freelancerAvatarUrl ?? this.freelancerAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      featured: featured ?? this.featured,
    );
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final rawGallery = (json['gallery_images'] as List?) ?? const [];
    final rawTags = (json['tags'] as List?) ?? const [];

    return ServiceModel(
      id: json['id'] ?? 0,
      freelancerId: json['freelancer_id'] ?? 0,
      title: json['title']?.toString() ?? json['titulo']?.toString() ?? '',
      category: json['category']?.toString() ?? json['categoria']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? json['descripcion_corta']?.toString() ?? '',
      description: json['description']?.toString() ?? json['descripcion']?.toString() ?? '',
      priceValue: (json['price_value'] as num?)?.toDouble() ??
          double.tryParse(json['price_value']?.toString() ?? json['price']?.toString() ?? '') ??
          0,
      priceLabel: json['price_label']?.toString() ?? json['precio']?.toString() ?? '',
      modality: serviceModalityFromString(json['modality'] ?? json['modalidad']),
      estimatedTime: json['estimated_time']?.toString() ?? json['tiempo_estimado']?.toString() ?? '',
      status: serviceStatusFromString(json['status'] ?? json['estado']),
      mainImageUrl: json['main_image_url']?.toString() ?? json['imagen_principal']?.toString() ?? '',
      galleryImages: rawGallery.map((item) => item.toString()).toList(),
      tags: rawTags.map((item) => item.toString()).toList(),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] ?? 0,
      interestedCount: json['interested_count'] ?? 0,
      freelancerName: json['freelancer_name']?.toString() ?? '',
      freelancerSpecialty: json['freelancer_specialty']?.toString() ?? '',
      freelancerRating: (json['freelancer_rating'] as num?)?.toDouble() ?? 0,
      freelancerAvailability: json['freelancer_availability']?.toString() ?? '',
      freelancerShortDescription: json['freelancer_short_description']?.toString() ?? '',
      freelancerAvatarUrl: json['freelancer_avatar_url']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      featured: json['featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'freelancer_id': freelancerId,
      'title': title,
      'category': category,
      'short_description': shortDescription,
      'description': description,
      'price_value': priceValue,
      'price_label': priceLabel,
      'modality': modality.label,
      'estimated_time': estimatedTime,
      'status': status.label,
      'main_image_url': mainImageUrl,
      'gallery_images': galleryImages,
      'tags': tags,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'interested_count': interestedCount,
      'freelancer_name': freelancerName,
      'freelancer_specialty': freelancerSpecialty,
      'freelancer_rating': freelancerRating,
      'freelancer_availability': freelancerAvailability,
      'freelancer_short_description': freelancerShortDescription,
      'freelancer_avatar_url': freelancerAvatarUrl,
      'created_at': createdAt.toIso8601String(),
      'featured': featured,
    };
  }
}