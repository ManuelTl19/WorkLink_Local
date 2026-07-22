import 'package:worklink_local/modules/settings/models/report_problem_model.dart';

class ReportProblemService {
  static final List<ReportProblemModel> _reportedProblems = [];

  static Future<bool> submitReport(ReportProblemModel report) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _reportedProblems.add(report);
    return true;
  }

  static Future<List<ReportProblemModel>> fetchReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<ReportProblemModel>.from(_reportedProblems);
  }
}
