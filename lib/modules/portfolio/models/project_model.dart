class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String dateLabel;
  final String fullDescription;
  final List<String> technologies;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.dateLabel,
    required this.fullDescription,
    required this.technologies,
  });
}