class ServiceRequestModel {
  final int id;
  final int serviceId;
  final int requesterId;
  final String requesterName;
  final String accountType;
  final String avatarUrl;
  final DateTime requestedAt;

  const ServiceRequestModel({
    required this.id,
    required this.serviceId,
    required this.requesterId,
    required this.requesterName,
    required this.accountType,
    required this.avatarUrl,
    required this.requestedAt,
  });

  ServiceRequestModel copyWith({
    int? id,
    int? serviceId,
    int? requesterId,
    String? requesterName,
    String? accountType,
    String? avatarUrl,
    DateTime? requestedAt,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      accountType: accountType ?? this.accountType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      requesterId: json['requester_id'] ?? 0,
      requesterName: json['requester_name']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      requestedAt: DateTime.tryParse(json['requested_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'account_type': accountType,
      'avatar_url': avatarUrl,
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}