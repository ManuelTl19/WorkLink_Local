class ReviewModel {
  final int id;
  final int? contractId;
  final int reviewerId;
  final String reviewerName;
  final String reviewerAvatarUrl;
  final int reviewedUserId;
  final String reviewedUserName;
  final String reviewedUserType;
  final double rating;
  final String comment;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.id,
    this.contractId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.reviewedUserId,
    required this.reviewedUserName,
    required this.reviewedUserType,
    required this.rating,
    required this.comment,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasComment => comment.trim().isNotEmpty;

  ReviewModel copyWith({
    int? id,
    int? contractId,
    int? reviewerId,
    String? reviewerName,
    String? reviewerAvatarUrl,
    int? reviewedUserId,
    String? reviewedUserName,
    String? reviewedUserType,
    double? rating,
    String? comment,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatarUrl: reviewerAvatarUrl ?? this.reviewerAvatarUrl,
      reviewedUserId: reviewedUserId ?? this.reviewedUserId,
      reviewedUserName: reviewedUserName ?? this.reviewedUserName,
      reviewedUserType: reviewedUserType ?? this.reviewedUserType,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
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
      if (value is Map<String, dynamic>) {
        return readString(
          value['name'] ??
              value['nombre'] ??
              value['full_name'] ??
              value['title'] ??
              value['label'],
        );
      }
      return value.toString().trim();
    }

    final reviewer = json['reviewer'] is Map<String, dynamic>
        ? json['reviewer'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final reviewedUser = json['reviewed_user'] is Map<String, dynamic>
        ? json['reviewed_user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final createdAt = DateTime.tryParse(
          json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
        ) ??
        DateTime.now();
    final updatedAt = DateTime.tryParse(
          json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '',
        ) ??
        createdAt;

    String firstNonEmpty(List<String> values, String fallback) {
      for (final value in values) {
        if (value.trim().isNotEmpty) return value.trim();
      }
      return fallback;
    }

    return ReviewModel(
      id: parseInt(json['id']),
      contractId: json['contract_id'] != null
          ? parseInt(json['contract_id'])
          : parseInt(
              json['contract'] is Map<String, dynamic>
                  ? json['contract']['id']
                  : null,
            ),
      reviewerId: parseInt(json['reviewer_id'] ?? reviewer['id']),
      reviewerName: firstNonEmpty([
        readString(json['reviewer_name']),
        readString(reviewer['name']),
        readString(reviewer['full_name']),
      ], 'Usuario'),
      reviewerAvatarUrl: firstNonEmpty([
        readString(json['reviewer_avatar_url']),
        readString(reviewer['profile_photo_url']),
        readString(reviewer['avatar_url']),
      ], ''),
      reviewedUserId: parseInt(json['reviewed_user_id'] ?? reviewedUser['id']),
      reviewedUserName: firstNonEmpty([
        readString(json['reviewed_user_name']),
        readString(reviewedUser['name']),
        readString(reviewedUser['full_name']),
      ], 'Participante'),
      reviewedUserType: firstNonEmpty([
        readString(json['reviewed_user_type']),
        readString(reviewedUser['type']),
        readString(reviewedUser['role']),
      ], 'Usuario'),
      rating: parseDouble(json['rating'] ?? json['score']),
      comment: readString(json['comment'] ?? json['message'] ?? json['content']),
      isPublic: json['is_public'] == true || json['isPublic'] == true || json['public'] == true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_avatar_url': reviewerAvatarUrl,
      'reviewed_user_id': reviewedUserId,
      'reviewed_user_name': reviewedUserName,
      'reviewed_user_type': reviewedUserType,
      'rating': rating,
      'comment': comment,
      'is_public': isPublic,
    };
  }
}