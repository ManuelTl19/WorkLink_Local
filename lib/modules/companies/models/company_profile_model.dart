class CompanyProfileModel {
  final int id;
  final int? userId;
  final String companyName;
  final String description;
  final String industry;
  final String location;
  final double averageRate;
  final String ownerName;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyProfileModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.description,
    required this.industry,
    required this.location,
    required this.averageRate,
    required this.ownerName,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  CompanyProfileModel copyWith({
    int? id,
    int? userId,
    String? companyName,
    String? description,
    String? industry,
    String? location,
    double? averageRate,
    String? ownerName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      averageRate: averageRate ?? this.averageRate,
      ownerName: ownerName ?? this.ownerName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    final ownerName = _composeOwnerName(user, json);

    return CompanyProfileModel(
      id: _intValue(json['id']),
      userId: _intNullable(json['user_id'] ?? json['userId'] ?? user['id']),
      companyName: _stringValue(
        json['company_name'] ?? json['companyName'] ?? json['name'],
      ),
      description: _stringValue(json['description']),
      industry: _stringValue(json['industry']),
      location: _stringValue(json['location']),
      averageRate: _doubleValue(
        json['average_rate'] ?? json['averageRating'] ?? json['average_rate'],
      ),
      ownerName: ownerName,
      photoUrl: _composePhotoUrl(user, json),
      createdAt: _dateValue(json['created_at'] ?? json['createdAt']),
      updatedAt: _dateValue(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateJson({int? userId}) {
    return {
      'company_name': companyName.trim(),
      'description': description.trim(),
      'industry': industry.trim(),
      'location': location.trim(),
      if (userId != null) 'user_id': userId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'company_name': companyName.trim(),
      'description': description.trim(),
      'industry': industry.trim(),
      'location': location.trim(),
    };
  }

  String get initials {
    final normalized = companyName.trim();
    if (normalized.isEmpty) return 'WL';

    final parts = normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'WL';

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts[1].substring(0, 1).toUpperCase()
        : '';
    return '$first$second';
  }

  static String _composeOwnerName(
    Map<String, dynamic> user,
    Map<String, dynamic> json,
  ) {
    final candidateValues = <String>[
      user['name']?.toString() ?? '',
      user['first_name']?.toString() ?? '',
      user['last_name']?.toString() ?? '',
      user['apellidoP']?.toString() ?? '',
      user['apellidoM']?.toString() ?? '',
      json['owner_name']?.toString() ?? '',
      json['company_owner_name']?.toString() ?? '',
    ];

    final joined = candidateValues
        .where((value) => value.trim().isNotEmpty)
        .join(' ')
        .trim();

    if (joined.isNotEmpty) return joined;

    final fallback = user['email']?.toString().trim() ?? '';
    return fallback.isNotEmpty ? fallback : 'Empresa';
  }

  static String _composePhotoUrl(
    Map<String, dynamic> user,
    Map<String, dynamic> json,
  ) {
    final candidateValues = <String>[
      user['profile_photo_url']?.toString() ?? '',
      user['profile_photo']?.toString() ?? '',
      user['foto_perfil']?.toString() ?? '',
      user['avatar_url']?.toString() ?? '',
      user['photo_url']?.toString() ?? '',
      json['photo_url']?.toString() ?? '',
      json['logo_url']?.toString() ?? '',
      json['avatar_url']?.toString() ?? '',
    ];

    for (final value in candidateValues) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) return normalized;
    }

    return '';
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _intNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _doubleValue(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
