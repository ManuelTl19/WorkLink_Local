import 'package:worklink_local/helpers/apis.dart';

class FreelancerModel {
  final int? id;
  final int? userId;
  final String fullName;
  final String specialty;
  final String description;
  final double hourlyRate;
  final bool available;
  final String location;
  final String avatarUrl;
  final double? averageRate;

  // Campos legados para compatibilidad con otros módulos
  final double? rating;
  final String? availability;
  final String? shortDescription;

  // Campos opcionales para futuro
  final String? serviceArea;
  final String? workMode;
  final String? experience;
  final String? rateType;
  final List<String> languages;
  final String? website;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? github;
  final String? portfolioUrl;

  const FreelancerModel({
    this.id,
    this.userId,
    required this.fullName,
    required this.specialty,
    required this.description,
    required this.hourlyRate,
    required this.available,
    required this.location,
    required this.avatarUrl,
    this.averageRate,
    this.rating,
    this.availability,
    this.shortDescription,
    this.serviceArea,
    this.workMode,
    this.experience,
    this.rateType,
    this.languages = const [],
    this.website,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.github,
    this.portfolioUrl,
  });

  factory FreelancerModel.fromJson(Map<String, dynamic> json) {
    final rate = _parseDouble(
      json['rate'] ?? json['hourly_rate'] ?? json['hourlyRate'] ?? 0,
    );
    final links = json['professional_links'];
    final professionalLinks = links is Map<String, dynamic>
        ? links
        : <String, dynamic>{};

    return FreelancerModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int? ?? json['userId'] as int?,
      fullName: _parseFullName(json),
      specialty: json['specialty'] as String? ?? '',
      description: json['description'] as String? ?? '',
      hourlyRate: rate,
      available: json['available'] == true || json['available'] == 1,
      location: json['location'] as String? ?? '',
      avatarUrl: _parseAvatar(json),
      averageRate: _parseNullableDouble(
        json['average_rate'] ?? json['averageRate'],
      ),
      rating:
          _parseNullableDouble(json['rating']) ??
          _parseNullableDouble(json['average_rate'] ?? json['averageRate']),
      availability:
          json['availability'] as String? ??
          ((json['available'] == true || json['available'] == 1)
              ? 'Disponible'
              : 'No disponible'),
      shortDescription:
          json['short_description'] as String? ??
          json['shortDescription'] as String?,
      serviceArea:
          json['service_area'] as String? ?? json['serviceArea'] as String?,
      workMode: json['work_mode'] as String? ?? json['workMode'] as String?,
      experience: json['experience'] as String?,
      rateType: json['rate_type'] as String? ?? json['rateType'] as String?,
      languages: _parseLanguages(json['languages']),
      website: (json['website'] ?? professionalLinks['website']) as String?,
      facebook: (json['facebook'] ?? professionalLinks['facebook']) as String?,
      instagram:
          (json['instagram'] ?? professionalLinks['instagram']) as String?,
      linkedin: (json['linkedin'] ?? professionalLinks['linkedin']) as String?,
      github: (json['github'] ?? professionalLinks['github']) as String?,
      portfolioUrl:
          (json['portfolio_url'] ??
                  json['portfolioUrl'] ??
                  professionalLinks['portfolio_url'])
              as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'full_name': fullName,
      'specialty': specialty,
      'description': description,
      'rate': hourlyRate,
      'hourly_rate': hourlyRate,
      'available': available,
      'location': location,
      'avatar_url': avatarUrl,
      if (averageRate != null) 'average_rate': averageRate,
      if (rating != null) 'rating': rating,
      if (availability != null) 'availability': availability,
      if (shortDescription != null) 'short_description': shortDescription,
      if (serviceArea != null) 'service_area': serviceArea,
      if (workMode != null) 'work_mode': _toApiWorkMode(workMode!),
      if (experience != null) 'experience': experience,
      if (rateType != null) 'rate_type': rateType,
      'languages': languages,
      if (website != null) 'website': website,
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
      if (linkedin != null) 'linkedin': linkedin,
      if (github != null) 'github': github,
      if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
    };
  }

  FreelancerModel copyWith({
    int? id,
    int? userId,
    String? fullName,
    String? specialty,
    String? description,
    double? hourlyRate,
    bool? available,
    String? location,
    String? avatarUrl,
    double? averageRate,
    double? rating,
    String? availability,
    String? shortDescription,
    String? serviceArea,
    String? workMode,
    String? experience,
    String? rateType,
    List<String>? languages,
    String? website,
    String? facebook,
    String? instagram,
    String? linkedin,
    String? github,
    String? portfolioUrl,
  }) {
    return FreelancerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      available: available ?? this.available,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      averageRate: averageRate ?? this.averageRate,
      rating: rating ?? this.rating,
      availability: availability ?? this.availability,
      shortDescription: shortDescription ?? this.shortDescription,
      serviceArea: serviceArea ?? this.serviceArea,
      workMode: workMode ?? this.workMode,
      experience: experience ?? this.experience,
      rateType: rateType ?? this.rateType,
      languages: languages ?? this.languages,
      website: website ?? this.website,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseLanguages(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }

  static String _toApiWorkMode(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'remote' || normalized == 'remoto') {
      return 'remote';
    }

    if (normalized == 'on_site' ||
        normalized == 'onsite' ||
        normalized == 'presencial') {
      return 'on_site';
    }

    if (normalized == 'hybrid' ||
        normalized == 'hibrido' ||
        normalized == 'hibrida') {
      return 'hybrid';
    }

    if (normalized == 'home_service' ||
        normalized == 'servicio a domicilio' ||
        normalized == 'a domicilio') {
      return 'home_service';
    }

    return normalized;
  }

  static String _parseFullName(Map<String, dynamic> json) {
    final direct =
        json['full_name'] as String? ?? json['fullName'] as String? ?? '';
    if (direct.trim().isNotEmpty) {
      return direct;
    }

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final name = (user['name'] ?? '').toString().trim();
      final lastName = (user['last_name'] ?? '').toString().trim();
      final maternal = (user['maternal_last_name'] ?? '').toString().trim();
      return [
        name,
        lastName,
        maternal,
      ].where((part) => part.isNotEmpty).join(' ');
    }

    return '';
  }

  static String _parseAvatar(Map<String, dynamic> json) {
    final direct =
        json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '';
    if (direct.trim().isNotEmpty) {
      return _toAbsoluteUrl(direct);
    }

    final user = json['user'];
    if (user is Map<String, dynamic>) {
      final raw = (user['profile_photo_url'] ?? user['profile_photo'] ?? '')
          .toString();
      return _toAbsoluteUrl(raw);
    }

    return '';
  }

  static String _toAbsoluteUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '${Apis.baseUrl}/storage/$path';
  }
}
