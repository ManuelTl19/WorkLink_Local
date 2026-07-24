class FreelancerAvailabilityModel {
  final int? id;
  final int freelancerId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  const FreelancerAvailabilityModel({
    this.id,
    required this.freelancerId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory FreelancerAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return FreelancerAvailabilityModel(
      id: _parseNullableInt(json['id']),
      freelancerId:
          _parseNullableInt(json['freelancer_id'] ?? json['freelancerId']) ?? 0,
      startDate: DateTime.parse(
        json['start_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      status: (json['status']?.toString() ?? 'available').toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'freelancer_id': freelancerId,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'status': status,
    };
  }

  FreelancerAvailabilityModel copyWith({
    int? id,
    int? freelancerId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return FreelancerAvailabilityModel(
      id: id ?? this.id,
      freelancerId: freelancerId ?? this.freelancerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
