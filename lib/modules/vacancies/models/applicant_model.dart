import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';

class ApplicantModel {
  final int id;
  final int vacancyId;
  final FreelancerModel freelancer;
  final ApplicationStatus applicationStatus;
  final DateTime appliedAt;

  const ApplicantModel({
    required this.id,
    required this.vacancyId,
    required this.freelancer,
    required this.applicationStatus,
    required this.appliedAt,
  });

  ApplicantModel copyWith({
    int? id,
    int? vacancyId,
    FreelancerModel? freelancer,
    ApplicationStatus? applicationStatus,
    DateTime? appliedAt,
  }) {
    return ApplicantModel(
      id: id ?? this.id,
      vacancyId: vacancyId ?? this.vacancyId,
      freelancer: freelancer ?? this.freelancer,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    return ApplicantModel(
      id: json['id'] ?? 0,
      vacancyId: json['vacancy_id'] ?? 0,
      freelancer: FreelancerModel(
        id: json['freelancer_id'] ?? 0,
        fullName: json['full_name']?.toString() ?? '',
        specialty: json['specialty']?.toString() ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        availability: json['availability']?.toString() ?? '',
        shortDescription: json['short_description']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
      ),
      applicationStatus: applicationStatusFromString(
        json['application_status'] ?? json['status'],
      ),
      appliedAt:
          DateTime.tryParse(json['applied_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vacancy_id': vacancyId,
      'freelancer_id': freelancer.id,
      'full_name': freelancer.fullName,
      'specialty': freelancer.specialty,
      'rating': freelancer.rating,
      'availability': freelancer.availability,
      'short_description': freelancer.shortDescription,
      'location': freelancer.location,
      'avatar_url': freelancer.avatarUrl,
      'application_status': applicationStatus.label,
      'applied_at': appliedAt.toIso8601String(),
    };
  }
}