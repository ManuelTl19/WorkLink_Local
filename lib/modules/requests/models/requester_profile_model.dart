class RequesterProfileModel {
  final int id;
  final String name;
  final String description;
  final String accountType;
  final String location;
  final double rating;
  final String avatarUrl;
  final String relevantInfo;
  final String website;

  const RequesterProfileModel({
    required this.id,
    required this.name,
    required this.description,
    required this.accountType,
    required this.location,
    required this.rating,
    required this.avatarUrl,
    required this.relevantInfo,
    required this.website,
  });

  RequesterProfileModel copyWith({
    int? id,
    String? name,
    String? description,
    String? accountType,
    String? location,
    double? rating,
    String? avatarUrl,
    String? relevantInfo,
    String? website,
  }) {
    return RequesterProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      accountType: accountType ?? this.accountType,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      relevantInfo: relevantInfo ?? this.relevantInfo,
      website: website ?? this.website,
    );
  }

  factory RequesterProfileModel.fromJson(Map<String, dynamic> json) {
    return RequesterProfileModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      avatarUrl: json['avatar_url']?.toString() ?? '',
      relevantInfo: json['relevant_info']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'account_type': accountType,
      'location': location,
      'rating': rating,
      'avatar_url': avatarUrl,
      'relevant_info': relevantInfo,
      'website': website,
    };
  }
}
