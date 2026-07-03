import 'package:worklink_local/modules/portfolio/models/project_model.dart';

class PortfolioModel {
  final int freelancerId;
  final String about;
  final List<String> skills;
  final String hourlyRate;
  final String experience;
  final String availabilityNote;
  final List<ProjectModel> projects;

  const PortfolioModel({
    required this.freelancerId,
    required this.about,
    required this.skills,
    required this.hourlyRate,
    required this.experience,
    required this.availabilityNote,
    required this.projects,
  });
}