enum ApplicationStatus { pendiente, enRevision, aceptada, rechazada }

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.pendiente:
        return 'Pendiente';
      case ApplicationStatus.enRevision:
        return 'En revisión';
      case ApplicationStatus.aceptada:
        return 'Aceptada';
      case ApplicationStatus.rechazada:
        return 'Rechazada';
    }
  }
}

ApplicationStatus applicationStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';

  if (text.contains('revisión') || text.contains('revision')) {
    return ApplicationStatus.enRevision;
  }
  if (text.contains('acept')) return ApplicationStatus.aceptada;
  if (text.contains('rech')) return ApplicationStatus.rechazada;
  return ApplicationStatus.pendiente;
}

class VacancyApplicationModel {
  final int id;
  final int vacancyId;
  final int freelancerId;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const VacancyApplicationModel({
    required this.id,
    required this.vacancyId,
    required this.freelancerId,
    required this.status,
    required this.appliedAt,
  });

  VacancyApplicationModel copyWith({
    int? id,
    int? vacancyId,
    int? freelancerId,
    ApplicationStatus? status,
    DateTime? appliedAt,
  }) {
    return VacancyApplicationModel(
      id: id ?? this.id,
      vacancyId: vacancyId ?? this.vacancyId,
      freelancerId: freelancerId ?? this.freelancerId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  factory VacancyApplicationModel.fromJson(Map<String, dynamic> json) {
    return VacancyApplicationModel(
      id: json['id'] ?? 0,
      vacancyId: json['vacancy_id'] ?? 0,
      freelancerId: json['freelancer_id'] ?? 0,
      status: applicationStatusFromString(json['status'] ?? json['estado']),
      appliedAt: DateTime.tryParse(json['applied_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vacancy_id': vacancyId,
      'freelancer_id': freelancerId,
      'status': status.label,
      'applied_at': appliedAt.toIso8601String(),
    };
  }
}