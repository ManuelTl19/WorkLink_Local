import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/vacancies/models/application_model.dart';

class ApplicantModel {
  final int id;
  final int vacancyId;
  final int freelancerId;
  final String message;
  final FreelancerModel freelancer;
  final ApplicationStatus applicationStatus;
  final DateTime appliedAt;

  const ApplicantModel({
    required this.id,
    required this.vacancyId,
    required this.freelancerId,
    this.message = '',
    required this.freelancer,
    required this.applicationStatus,
    required this.appliedAt,
  });

  ApplicantModel copyWith({
    int? id,
    int? vacancyId,
    int? freelancerId,
    String? message,
    FreelancerModel? freelancer,
    ApplicationStatus? applicationStatus,
    DateTime? appliedAt,
  }) {
    return ApplicantModel(
      id: id ?? this.id,
      vacancyId: vacancyId ?? this.vacancyId,
      freelancerId: freelancerId ?? this.freelancerId,
      message: message ?? this.message,
      freelancer: freelancer ?? this.freelancer,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
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

    final profile = json['freelancer_profile'] is Map<String, dynamic>
        ? json['freelancer_profile'] as Map<String, dynamic>
        : (json['freelancer'] is Map<String, dynamic>
              ? json['freelancer'] as Map<String, dynamic>
              : const <String, dynamic>{});

    final user = json['freelancer_user'] is Map<String, dynamic>
        ? json['freelancer_user'] as Map<String, dynamic>
        : (profile['user'] is Map<String, dynamic>
              ? profile['user'] as Map<String, dynamic>
              : const <String, dynamic>{});

    return ApplicantModel(
      id: parseInt(json['id']),
      vacancyId: parseInt(json['vacancy_id']),
      freelancerId: parseInt(json['freelancer_id'] ?? profile['id']),
      message: readString(json['message']),
      freelancer: FreelancerModel(
        id: parseInt(json['freelancer_id'] ?? profile['id']),
        userId: parseInt(profile['user_id']) == 0 ? null : parseInt(profile['user_id']),
        fullName: readString(json['full_name']).isNotEmpty
            ? readString(json['full_name'])
            : [
                readString(user['name']),
                readString(user['last_name']),
                readString(user['maternal_last_name']),
              ].where((part) => part.isNotEmpty).join(' ').trim(),
        specialty: readString(json['specialty']).isNotEmpty
            ? readString(json['specialty'])
            : readString(profile['specialty']),
        description: readString(json['short_description']).isNotEmpty
            ? readString(json['short_description'])
            : readString(profile['description']),
        hourlyRate: parseDouble(json['hourly_rate'] ?? profile['hourly_rate'] ?? profile['rate']),
        available: true,
        location: readString(json['location']).isNotEmpty
            ? readString(json['location'])
            : readString(profile['location']),
        avatarUrl: readString(json['avatar_url']).isNotEmpty
            ? readString(json['avatar_url'])
            : readString(user['profile_photo_url']),
        rating: parseDouble(json['rating'] ?? profile['average_rate']),
        availability: readString(json['availability']).isNotEmpty
            ? readString(json['availability'])
            : 'Disponible',
        shortDescription: readString(json['short_description']).isNotEmpty
            ? readString(json['short_description'])
            : readString(profile['description']),
      ),
      applicationStatus: applicationStatusFromString(
        json['application_status'] ?? json['status'],
      ),
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