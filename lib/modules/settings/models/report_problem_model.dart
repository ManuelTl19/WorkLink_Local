import 'package:image_picker/image_picker.dart';

class ReportProblemModel {
  final String title;
  final String description;
  final XFile? evidence;

  ReportProblemModel({
    required this.title,
    required this.description,
    this.evidence,
  });
}
