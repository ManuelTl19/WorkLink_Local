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
    int parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(Object? value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    String readString(Object? value) {
      if (value == null) return '';
      if (value is String) return value.trim();
      return value.toString().trim();
    }

    final payload = json['vacancy'] is Map<String, dynamic>
        ? json['vacancy'] as Map<String, dynamic>
        : json;

    final companyProfile = payload['company_profile'] is Map<String, dynamic>
        ? payload['company_profile'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final companyUser = companyProfile['user'] is Map<String, dynamic>
        ? companyProfile['user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final salaryValue = readString(payload['salary']).isNotEmpty
        ? readString(payload['salary'])
        : readString(payload['salario']);

    final parsedPostedAt =
        DateTime.tryParse(readString(payload['posted_at']).isNotEmpty
            ? readString(payload['posted_at'])
            : readString(payload['created_at'])) ??
        DateTime.now();

    return VacancyModel(
      id: parseInt(payload['id']),
      companyId: parseInt(payload['company_id'] ?? payload['empresa_id']),
      title: readString(payload['title']).isNotEmpty
          ? readString(payload['title'])
          : readString(payload['titulo']),
      description: readString(payload['description']).isNotEmpty
          ? readString(payload['description'])
          : readString(payload['descripcion']),
      category: readString(payload['category']).isNotEmpty
          ? readString(payload['category'])
          : readString(payload['categoria']),
      location: readString(payload['location']).isNotEmpty
          ? readString(payload['location'])
          : readString(payload['ubicacion']),
      salary: salaryValue,
      status: vacancyStatusFromString(payload['status'] ?? payload['estado']),
      applicantsCount: parseInt(
        payload['applicants_count'] ?? payload['postulantes_count'] ?? payload['applications_count'],
      ),
      companyName: readString(payload['company_name']).isNotEmpty
          ? readString(payload['company_name'])
          : readString(payload['empresa_nombre']).isNotEmpty
          ? readString(payload['empresa_nombre'])
          : readString(companyProfile['company_name']).isNotEmpty
          ? readString(companyProfile['company_name'])
          : [
              readString(companyUser['name']),
              readString(companyUser['last_name']),
              readString(companyUser['maternal_last_name']),
            ].where((part) => part.isNotEmpty).join(' ').trim(),
      companyDescription: readString(payload['company_description']).isNotEmpty
          ? readString(payload['company_description'])
          : readString(companyProfile['description']),
      companyIndustry: readString(payload['company_industry']).isNotEmpty
          ? readString(payload['company_industry'])
          : readString(companyProfile['industry']),
      companyRating: parseDouble(
        payload['company_rating'] ?? companyProfile['average_rate'],
      ),
      companyLocation: readString(payload['company_location']).isNotEmpty
          ? readString(payload['company_location'])
          : readString(companyProfile['location']),
      companyLogoUrl: readString(payload['company_logo_url']).isNotEmpty
          ? readString(payload['company_logo_url'])
          : readString(companyProfile['photo_url']).isNotEmpty
          ? readString(companyProfile['photo_url'])
          : readString(companyUser['profile_photo_url']),
      postedAt: parsedPostedAt,
      featured: payload['featured'] == true,
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