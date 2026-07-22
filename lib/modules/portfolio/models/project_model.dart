class ProjectModel {
  final int id;
  final int? freelancerId;
  final String title;
  final String description;
  final String imageUrl;
  final String projectUrl;
  final String dateLabel;
  final String fullDescription;
  final List<String> technologies;

  const ProjectModel({
    required this.id,
    this.freelancerId,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.projectUrl = '',
    required this.dateLabel,
    required this.fullDescription,
    required this.technologies,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: _parseInt(json['id']) ?? 0,
      freelancerId: _parseInt(
        json['freelancer_id'] ??
            json['profile_id'] ??
            json['freelancer_profile_id'],
      ),
      title: (json['title'] ?? json['name'] ?? 'Proyecto sin titulo')
          .toString(),
      description: (json['description'] ?? json['summary'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['cover_url'] ?? '').toString(),
      projectUrl: (json['project_url'] ?? json['url'] ?? '').toString(),
      dateLabel: (json['created_at'] ?? json['date'] ?? '').toString(),
      fullDescription:
          (json['full_description'] ??
                  json['content'] ??
                  json['description'] ??
                  '')
              .toString(),
      technologies: _parseList(
        json['technologies'] ?? json['tags'] ?? json['stack'],
      ),
    );
  }

  Map<String, dynamic> toCreateJson({required int freelancerId}) {
    return {
      'freelancer_id': freelancerId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'project_url': projectUrl,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'project_url': projectUrl,
    };
  }

  ProjectModel copyWith({
    int? id,
    int? freelancerId,
    String? title,
    String? description,
    String? imageUrl,
    String? projectUrl,
    String? dateLabel,
    String? fullDescription,
    List<String>? technologies,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      freelancerId: freelancerId ?? this.freelancerId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      projectUrl: projectUrl ?? this.projectUrl,
      dateLabel: dateLabel ?? this.dateLabel,
      fullDescription: fullDescription ?? this.fullDescription,
      technologies: technologies ?? this.technologies,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return const [];
  }
}
