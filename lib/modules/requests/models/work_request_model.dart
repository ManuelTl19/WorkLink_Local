enum RequestStatus { abierta, enProceso, cerrada }

extension RequestStatusX on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.abierta:
        return 'Abierta';
      case RequestStatus.enProceso:
        return 'En proceso';
      case RequestStatus.cerrada:
        return 'Cerrada';
    }
  }
}

RequestStatus requestStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text.contains('proceso')) return RequestStatus.enProceso;
  if (text.contains('cerr')) return RequestStatus.cerrada;
  return RequestStatus.abierta;
}

enum RequestModality { remoto, presencial, hibrido }

extension RequestModalityX on RequestModality {
  String get label {
    switch (this) {
      case RequestModality.remoto:
        return 'Remoto';
      case RequestModality.presencial:
        return 'Presencial';
      case RequestModality.hibrido:
        return 'Híbrido';
    }
  }
}

RequestModality requestModalityFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';
  if (text.contains('pres')) return RequestModality.presencial;
  if (text.contains('hibr')) return RequestModality.hibrido;
  return RequestModality.remoto;
}

class WorkRequestModel {
  final int id;
  final int requesterId;
  final String title;
  final String category;
  final String shortDescription;
  final String description;
  final double budgetValue;
  final String budgetLabel;
  final String location;
  final RequestModality modality;
  final RequestStatus status;
  final DateTime postedAt;
  final String requesterName;
  final String requesterAccountType;
  final String requesterAvatarUrl;
  final double requesterRating;
  final String requesterDescription;
  final String requesterLocation;
  final String requesterRelevantInfo;
  final String requesterWebsite;
  final int interestedCount;
  final bool featured;

  const WorkRequestModel({
    required this.id,
    required this.requesterId,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.budgetValue,
    required this.budgetLabel,
    required this.location,
    required this.modality,
    required this.status,
    required this.postedAt,
    required this.requesterName,
    required this.requesterAccountType,
    required this.requesterAvatarUrl,
    required this.requesterRating,
    required this.requesterDescription,
    required this.requesterLocation,
    required this.requesterRelevantInfo,
    required this.requesterWebsite,
    required this.interestedCount,
    this.featured = false,
  });

  bool get isOpen => status == RequestStatus.abierta;

  WorkRequestModel copyWith({
    int? id,
    int? requesterId,
    String? title,
    String? category,
    String? shortDescription,
    String? description,
    double? budgetValue,
    String? budgetLabel,
    String? location,
    RequestModality? modality,
    RequestStatus? status,
    DateTime? postedAt,
    String? requesterName,
    String? requesterAccountType,
    String? requesterAvatarUrl,
    double? requesterRating,
    String? requesterDescription,
    String? requesterLocation,
    String? requesterRelevantInfo,
    String? requesterWebsite,
    int? interestedCount,
    bool? featured,
  }) {
    return WorkRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      title: title ?? this.title,
      category: category ?? this.category,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      budgetValue: budgetValue ?? this.budgetValue,
      budgetLabel: budgetLabel ?? this.budgetLabel,
      location: location ?? this.location,
      modality: modality ?? this.modality,
      status: status ?? this.status,
      postedAt: postedAt ?? this.postedAt,
      requesterName: requesterName ?? this.requesterName,
      requesterAccountType: requesterAccountType ?? this.requesterAccountType,
      requesterAvatarUrl: requesterAvatarUrl ?? this.requesterAvatarUrl,
      requesterRating: requesterRating ?? this.requesterRating,
      requesterDescription: requesterDescription ?? this.requesterDescription,
      requesterLocation: requesterLocation ?? this.requesterLocation,
      requesterRelevantInfo: requesterRelevantInfo ?? this.requesterRelevantInfo,
      requesterWebsite: requesterWebsite ?? this.requesterWebsite,
      interestedCount: interestedCount ?? this.interestedCount,
      featured: featured ?? this.featured,
    );
  }

  factory WorkRequestModel.fromJson(Map<String, dynamic> json) {
    return WorkRequestModel(
      id: json['id'] ?? 0,
      requesterId: json['requester_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      budgetValue: (json['budget_value'] as num?)?.toDouble() ?? 0,
      budgetLabel: json['budget_label']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      modality: requestModalityFromString(json['modality'] ?? json['modalidad']),
      status: requestStatusFromString(json['status'] ?? json['estado']),
      postedAt: DateTime.tryParse(json['posted_at']?.toString() ?? '') ?? DateTime.now(),
      requesterName: json['requester_name']?.toString() ?? '',
      requesterAccountType: json['requester_account_type']?.toString() ?? '',
      requesterAvatarUrl: json['requester_avatar_url']?.toString() ?? '',
      requesterRating: (json['requester_rating'] as num?)?.toDouble() ?? 0,
      requesterDescription: json['requester_description']?.toString() ?? '',
      requesterLocation: json['requester_location']?.toString() ?? '',
      requesterRelevantInfo: json['requester_relevant_info']?.toString() ?? '',
      requesterWebsite: json['requester_website']?.toString() ?? '',
      interestedCount: json['interested_count'] ?? 0,
      featured: json['featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'title': title,
      'category': category,
      'short_description': shortDescription,
      'description': description,
      'budget_value': budgetValue,
      'budget_label': budgetLabel,
      'location': location,
      'modality': modality.label,
      'status': status.label,
      'posted_at': postedAt.toIso8601String(),
      'requester_name': requesterName,
      'requester_account_type': requesterAccountType,
      'requester_avatar_url': requesterAvatarUrl,
      'requester_rating': requesterRating,
      'requester_description': requesterDescription,
      'requester_location': requesterLocation,
      'requester_relevant_info': requesterRelevantInfo,
      'requester_website': requesterWebsite,
      'interested_count': interestedCount,
      'featured': featured,
    };
  }
}
