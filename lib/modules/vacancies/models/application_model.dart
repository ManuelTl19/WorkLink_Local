enum ApplicationStatus { pendiente, aceptada, rechazada }

extension ApplicationStatusX on ApplicationStatus {
  String get apiValue {
    switch (this) {
      case ApplicationStatus.pendiente:
        return 'pending';
      case ApplicationStatus.aceptada:
        return 'accepted';
      case ApplicationStatus.rechazada:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case ApplicationStatus.pendiente:
        return 'Pendiente';
      case ApplicationStatus.aceptada:
        return 'Aceptada';
      case ApplicationStatus.rechazada:
        return 'Rechazada';
    }
  }
}

ApplicationStatus applicationStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text == 'accepted' || text.contains('acept')) {
    return ApplicationStatus.aceptada;
  }
  if (text == 'rejected' || text.contains('rech')) {
    return ApplicationStatus.rechazada;
  }
  return ApplicationStatus.pendiente;
}

class VacancyApplicationModel {
  final int id;
  final int vacancyId;
  final int freelancerId;
  final String message;
  final String vacancyTitle;
  final String companyName;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const VacancyApplicationModel({
    required this.id,
    required this.vacancyId,
    required this.freelancerId,
    this.message = '',
    this.vacancyTitle = '',
    this.companyName = '',
    required this.status,
    required this.appliedAt,
  });

  VacancyApplicationModel copyWith({
    int? id,
    int? vacancyId,
    int? freelancerId,
    String? message,
    String? vacancyTitle,
    String? companyName,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return VacancyApplicationModel(
      id: id ?? this.id,
      vacancyId: vacancyId ?? this.vacancyId,
      freelancerId: freelancerId ?? this.freelancerId,
      message: message ?? this.message,
      vacancyTitle: vacancyTitle ?? this.vacancyTitle,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  factory VacancyApplicationModel.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String readString(Object? value) {
      if (value == null) return '';
      if (value is String) return value.trim();
      return value.toString().trim();
    }

    final vacancy = json['vacancy'] is Map<String, dynamic>
        ? json['vacancy'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final company = vacancy['company'] is Map<String, dynamic>
        ? vacancy['company'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return VacancyApplicationModel(
      id: parseInt(json['id']),
      vacancyId: parseInt(json['vacancy_id'] ?? vacancy['id']),
      freelancerId: parseInt(json['freelancer_id']),
      message: readString(json['message']),
      vacancyTitle: readString(json['vacancy_title'])
          .isNotEmpty
          ? readString(json['vacancy_title'])
          : readString(vacancy['title']),
      companyName: readString(json['company_name'])
          .isNotEmpty
          ? readString(json['company_name'])
          : readString(company['company_name']).isNotEmpty
          ? readString(company['company_name'])
          : readString(company['name']),
      status: applicationStatusFromString(json['status'] ?? json['estado']),
      appliedAt:
          DateTime.tryParse(
            json['created_at']?.toString() ?? json['applied_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vacancy_id': vacancyId,
      'freelancer_id': freelancerId,
      'message': message,
      'vacancy_title': vacancyTitle,
      'company_name': companyName,
      'status': status.apiValue,
      'applied_at': appliedAt.toIso8601String(),
    };
  }
}