enum ServiceContractRequestStatus {
  pending,
  accepted,
  rejected,
  canceled,
  contracted,
}

extension ServiceContractRequestStatusX on ServiceContractRequestStatus {
  String get label {
    switch (this) {
      case ServiceContractRequestStatus.pending:
        return 'Pendiente';
      case ServiceContractRequestStatus.accepted:
        return 'Aceptada';
      case ServiceContractRequestStatus.rejected:
        return 'Rechazada';
      case ServiceContractRequestStatus.canceled:
        return 'Cancelada';
      case ServiceContractRequestStatus.contracted:
        return 'Contratada';
    }
  }

  String get apiValue {
    switch (this) {
      case ServiceContractRequestStatus.pending:
        return 'pending';
      case ServiceContractRequestStatus.accepted:
        return 'accepted';
      case ServiceContractRequestStatus.rejected:
        return 'rejected';
      case ServiceContractRequestStatus.canceled:
        return 'canceled';
      case ServiceContractRequestStatus.contracted:
        return 'contracted';
    }
  }
}

ServiceContractRequestStatus serviceContractRequestStatusFromString(
  Object? value,
) {
  final text = value?.toString().trim().toLowerCase() ?? '';
  if (text.contains('accept')) return ServiceContractRequestStatus.accepted;
  if (text.contains('reject')) return ServiceContractRequestStatus.rejected;
  if (text.contains('cancel')) return ServiceContractRequestStatus.canceled;
  if (text.contains('contract')) return ServiceContractRequestStatus.contracted;
  return ServiceContractRequestStatus.pending;
}

class ServiceRequestModel {
  final int id;
  final int serviceId;
  final String serviceTitle;
  final int requesterId;
  final String requesterName;
  final String accountType;
  final String avatarUrl;
  final String description;
  final double? budget;
  final int? freelancerId;
  final int? contractId;
  final ServiceContractRequestStatus status;
  final DateTime requestedAt;

  const ServiceRequestModel({
    required this.id,
    required this.serviceId,
    this.serviceTitle = '',
    required this.requesterId,
    required this.requesterName,
    required this.accountType,
    required this.avatarUrl,
    this.description = '',
    this.budget,
    this.freelancerId,
    this.contractId,
    this.status = ServiceContractRequestStatus.pending,
    required this.requestedAt,
  });

  ServiceRequestModel copyWith({
    int? id,
    int? serviceId,
    String? serviceTitle,
    int? requesterId,
    String? requesterName,
    String? accountType,
    String? avatarUrl,
    String? description,
    double? budget,
    int? freelancerId,
    int? contractId,
    ServiceContractRequestStatus? status,
    DateTime? requestedAt,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      accountType: accountType ?? this.accountType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      freelancerId: freelancerId ?? this.freelancerId,
      contractId: contractId ?? this.contractId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  bool get isPending => status == ServiceContractRequestStatus.pending;
  bool get isAccepted => status == ServiceContractRequestStatus.accepted;
  bool get isRejected => status == ServiceContractRequestStatus.rejected;
  bool get isCanceled => status == ServiceContractRequestStatus.canceled;
  bool get isContracted => status == ServiceContractRequestStatus.contracted;

  String get budgetLabel {
    final value = budget;
    if (value == null || value <= 0) return 'Sin presupuesto';
    if (value == value.roundToDouble()) return '\$${value.toInt()}';
    return '\$${value.toStringAsFixed(2)}';
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? parseNullableInt(Object? value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? parseDouble(Object? value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String readString(Object? value) {
      if (value == null) return '';
      if (value is String) return value.trim();
      if (value is Map<String, dynamic>) {
        return readString(
          value['name'] ??
              value['nombre'] ??
              value['title'] ??
              value['label'] ??
              value['description'] ??
              value['role'],
        );
      }
      if (value is List) {
        return value.map(readString).where((item) => item.isNotEmpty).join(', ');
      }
      return value.toString().trim();
    }

    final requester = json['client'] is Map<String, dynamic>
      ? json['client'] as Map<String, dynamic>
      : (json['requester'] is Map<String, dynamic>
          ? json['requester'] as Map<String, dynamic>
          : <String, dynamic>{});

    final service = json['service'] is Map<String, dynamic>
        ? json['service'] as Map<String, dynamic>
        : <String, dynamic>{};

    return ServiceRequestModel(
      id: parseInt(json['id']),
      serviceId: parseInt(json['service_id'] ?? service['id']),
      serviceTitle:
          json['service_title']?.toString() ??
          service['title']?.toString() ??
          '',
      requesterId: parseInt(
        json['client_id'] ?? json['requester_id'] ?? requester['id'],
      ),
      requesterName:
          readString(json['client_name'])
            .ifEmpty(readString(json['requester_name']))
            .ifEmpty(readString(requester['name']))
            .ifEmpty(readString(requester['nombre']))
            .ifEmpty('Cliente'),
      accountType:
          readString(json['account_type'])
            .ifEmpty(readString(json['client_type']))
            .ifEmpty(readString(requester['account_type']))
            .ifEmpty(readString(requester['role']))
            .ifEmpty(readString(requester['name']))
            .ifEmpty('Cliente'),
      avatarUrl:
          readString(json['avatar_url'])
            .ifEmpty(readString(json['client_avatar_url']))
            .ifEmpty(readString(requester['profile_photo_url']))
            .ifEmpty(readString(requester['avatar_url'])),
        description:
          readString(json['description'])
            .ifEmpty(readString(requester['description'])),
      budget: parseDouble(json['budget']),
      freelancerId: parseNullableInt(
        json['freelancer_id'] ?? service['freelancer_id'],
      ),
      contractId: parseNullableInt(
        json['contract_id'] ?? json['contract']?['id'],
      ),
      status: serviceContractRequestStatusFromString(json['status']),
      requestedAt:
          DateTime.tryParse(
            json['created_at']?.toString() ?? json['requested_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'client_id': requesterId,
      'requester_id': requesterId,
      'client_name': requesterName,
      'requester_name': requesterName,
      'account_type': accountType,
      'avatar_url': avatarUrl,
      'description': description,
      'budget': budget,
      'freelancer_id': freelancerId,
      'contract_id': contractId,
      'status': status.apiValue,
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}

extension _StringFallbackX on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}