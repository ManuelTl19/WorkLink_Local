enum VacancyStatus { abierta, cerrada, pausada }

extension VacancyStatusX on VacancyStatus {
  String get label {
    switch (this) {
      case VacancyStatus.abierta:
        return 'Abierta';
      case VacancyStatus.cerrada:
        return 'Cerrada';
      case VacancyStatus.pausada:
        return 'Pausada';
    }
  }
}

VacancyStatus vacancyStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text.contains('cerr')) return VacancyStatus.cerrada;
  if (text.contains('paus')) return VacancyStatus.pausada;
  return VacancyStatus.abierta;
}

class VacancyModel {
  final int id;
  final int companyId;
  final String title;
  final String description;
  final String category;
  final String location;
  final String salary;
  final VacancyStatus status;
  final int applicantsCount;
  final String companyName;
  final String companyDescription;
  final String companyIndustry;
  final double companyRating;
  final String companyLocation;
  final String companyLogoUrl;
  final DateTime postedAt;
  final bool featured;

  const VacancyModel({
    required this.id,
    required this.companyId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.salary,
    required this.status,
    required this.applicantsCount,
    required this.companyName,
    required this.companyDescription,
    required this.companyIndustry,
    required this.companyRating,
    required this.companyLocation,
    required this.companyLogoUrl,
    required this.postedAt,
    this.featured = false,
  });

  bool get isOpen => status == VacancyStatus.abierta;

  VacancyModel copyWith({
    int? id,
    int? companyId,
    String? title,
    String? description,
    String? category,
    String? location,
    String? salary,
    VacancyStatus? status,
    int? applicantsCount,
    String? companyName,
    String? companyDescription,
    String? companyIndustry,
    double? companyRating,
    String? companyLocation,
    String? companyLogoUrl,
    DateTime? postedAt,
    bool? featured,
  }) {
    return VacancyModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      companyName: companyName ?? this.companyName,
      companyDescription: companyDescription ?? this.companyDescription,
      companyIndustry: companyIndustry ?? this.companyIndustry,
      companyRating: companyRating ?? this.companyRating,
      companyLocation: companyLocation ?? this.companyLocation,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      postedAt: postedAt ?? this.postedAt,
      featured: featured ?? this.featured,
    );
  }

  factory VacancyModel.fromJson(Map<String, dynamic> json) {
    return VacancyModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? json['empresa_id'] ?? 0,
      title: json['title']?.toString() ?? json['titulo']?.toString() ?? '',
      description: json['description']?.toString() ?? json['descripcion']?.toString() ?? '',
      category: json['category']?.toString() ?? json['categoria']?.toString() ?? '',
      location: json['location']?.toString() ?? json['ubicacion']?.toString() ?? '',
      salary: json['salary']?.toString() ?? json['salario']?.toString() ?? '',
      status: vacancyStatusFromString(json['status'] ?? json['estado']),
      applicantsCount: json['applicants_count'] ?? json['postulantes_count'] ?? 0,
      companyName: json['company_name']?.toString() ?? json['empresa_nombre']?.toString() ?? '',
      companyDescription: json['company_description']?.toString() ?? '',
      companyIndustry: json['company_industry']?.toString() ?? '',
      companyRating: (json['company_rating'] as num?)?.toDouble() ?? 0,
      companyLocation: json['company_location']?.toString() ?? '',
      companyLogoUrl: json['company_logo_url']?.toString() ?? '',
      postedAt: DateTime.tryParse(json['posted_at']?.toString() ?? '') ?? DateTime.now(),
      featured: json['featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'salary': salary,
      'status': status.label,
      'applicants_count': applicantsCount,
      'company_name': companyName,
      'company_description': companyDescription,
      'company_industry': companyIndustry,
      'company_rating': companyRating,
      'company_location': companyLocation,
      'company_logo_url': companyLogoUrl,
      'posted_at': postedAt.toIso8601String(),
      'featured': featured,
    };
  }
}