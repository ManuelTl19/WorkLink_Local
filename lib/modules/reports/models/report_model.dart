enum ReportStatus { pending, reviewed, resolved }

extension ReportStatusX on ReportStatus {
  String get apiValue {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.reviewed:
        return 'reviewed';
      case ReportStatus.resolved:
        return 'resolved';
    }
  }

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.reviewed:
        return 'Revisado';
      case ReportStatus.resolved:
        return 'Resuelto';
    }
  }
}

ReportStatus reportStatusFromString(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';
  if (text.contains('review')) return ReportStatus.reviewed;
  if (text.contains('resolv')) return ReportStatus.resolved;
  return ReportStatus.pending;
}

class ReportedUserSummaryModel {
  final int userId;
  final String name;
  final int reportsCount;

  const ReportedUserSummaryModel({
    required this.userId,
    required this.name,
    required this.reportsCount,
  });

  factory ReportedUserSummaryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String readString(Object? value) {
      if (value == null) return '';
      if (value is String) return value.trim();
      if (value is Map<String, dynamic>) {
        return readString(
          value['name'] ??
              value['nombre'] ??
              value['full_name'] ??
              value['label'],
        );
      }
      return value.toString().trim();
    }

    return ReportedUserSummaryModel(
      userId: parseInt(json['user_id'] ?? json['reported_id'] ?? json['id']),
      name: readString(
        json['name'] ??
            json['reported_user_name'] ??
            json['user_name'] ??
            json['reported_name'],
      ),
      reportsCount: parseInt(
        json['reports_count'] ??
            json['total_reports'] ??
            json['count'] ??
            json['reports'],
      ),
    );
  }
}

class ReportSummaryModel {
  final int total;
  final int pending;
  final int reviewed;
  final int resolved;
  final List<ReportedUserSummaryModel> topReportedUsers;

  const ReportSummaryModel({
    required this.total,
    required this.pending,
    required this.reviewed,
    required this.resolved,
    required this.topReportedUsers,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final topUsersSource =
        json['top_reported_users'] ??
        json['users_most_reported'] ??
        json['reported_users'] ??
        json['most_reported_users'] ??
        const [];

    final topUsers = topUsersSource is List
        ? topUsersSource
              .whereType<Map>()
              .map(
                (item) => ReportedUserSummaryModel.fromJson(
                  item.cast<String, dynamic>(),
                ),
              )
              .toList()
        : <ReportedUserSummaryModel>[];

    return ReportSummaryModel(
      total: parseInt(
        json['total_reports'] ?? json['total'] ?? json['reports_total'],
      ),
      pending: parseInt(
        json['pending'] ?? json['pending_reports'] ?? json['pending_count'],
      ),
      reviewed: parseInt(
        json['reviewed'] ?? json['reviewed_reports'] ?? json['reviewed_count'],
      ),
      resolved: parseInt(
        json['resolved'] ?? json['resolved_reports'] ?? json['resolved_count'],
      ),
      topReportedUsers: topUsers,
    );
  }
}

class UserReportModel {
  final int id;
  final int reportedId;
  final int reporterId;
  final String reportedName;
  final String reporterName;
  final String reason;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserReportModel({
    required this.id,
    required this.reportedId,
    required this.reporterId,
    required this.reportedName,
    required this.reporterName,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == ReportStatus.pending;
  bool get isReviewed => status == ReportStatus.reviewed;
  bool get isResolved => status == ReportStatus.resolved;

  String get statusLabel => status.label;

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    int parseInt(Object? value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
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
      if (value is List) {
        return value
            .map(readString)
            .where((item) => item.isNotEmpty)
            .join(', ');
      }
      return value.toString().trim();
    }

    final reportedUser = json['reported_user'] is Map<String, dynamic>
        ? json['reported_user'] as Map<String, dynamic>
        : json['reported'] is Map<String, dynamic>
        ? json['reported'] as Map<String, dynamic>
        : <String, dynamic>{};

    final reporterUser = json['reporter'] is Map<String, dynamic>
        ? json['reporter'] as Map<String, dynamic>
        : json['creator'] is Map<String, dynamic>
        ? json['creator'] as Map<String, dynamic>
        : <String, dynamic>{};

    final reportedName = readString(
      json['reported_user_name'] ??
          json['reported_name'] ??
          reportedUser['name'] ??
          reportedUser['full_name'] ??
          reportedUser['nombre'] ??
          reportedUser['email'] ??
          reportedUser['correo'],
    );

    final reporterName = readString(
      json['reporter_name'] ??
          json['created_by_name'] ??
          reporterUser['name'] ??
          reporterUser['full_name'] ??
          reporterUser['nombre'] ??
          reporterUser['email'] ??
          reporterUser['correo'],
    );

    return UserReportModel(
      id: parseInt(json['id']),
      reportedId: parseInt(
        json['reported_id'] ?? json['reported_user_id'] ?? reportedUser['id'],
      ),
      reporterId: parseInt(
        json['reporter_id'] ??
            json['user_id'] ??
            json['created_by'] ??
            reporterUser['id'],
      ),
      reportedName: reportedName,
      reporterName: reporterName,
      reason: readString(json['reason']),
      description: readString(json['description']),
      status: reportStatusFromString(json['status']),
      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            json['updated_at']?.toString() ??
                json['updatedAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}
