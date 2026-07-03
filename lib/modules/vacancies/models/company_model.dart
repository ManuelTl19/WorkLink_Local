class CompanyModel {
  final int id;
  final String name;
  final String description;
  final String industry;
  final String location;
  final double averageRating;
  final String logoUrl;
  final String status;
  final String corporateInfo;
  final String website;
  final String foundedYear;
  final String size;
  final int activeVacanciesCount;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.location,
    required this.averageRating,
    required this.logoUrl,
    required this.status,
    required this.corporateInfo,
    required this.website,
    required this.foundedYear,
    required this.size,
    required this.activeVacanciesCount,
  });

  CompanyModel copyWith({
    int? id,
    String? name,
    String? description,
    String? industry,
    String? location,
    double? averageRating,
    String? logoUrl,
    String? status,
    String? corporateInfo,
    String? website,
    String? foundedYear,
    String? size,
    int? activeVacanciesCount,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      averageRating: averageRating ?? this.averageRating,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      corporateInfo: corporateInfo ?? this.corporateInfo,
      website: website ?? this.website,
      foundedYear: foundedYear ?? this.foundedYear,
      size: size ?? this.size,
      activeVacanciesCount: activeVacanciesCount ?? this.activeVacanciesCount,
    );
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      logoUrl: json['logo_url']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      corporateInfo: json['corporate_info']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      foundedYear: json['founded_year']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      activeVacanciesCount: json['active_vacancies_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'industry': industry,
      'location': location,
      'average_rating': averageRating,
      'logo_url': logoUrl,
      'status': status,
      'corporate_info': corporateInfo,
      'website': website,
      'founded_year': foundedYear,
      'size': size,
      'active_vacancies_count': activeVacanciesCount,
    };
  }
}