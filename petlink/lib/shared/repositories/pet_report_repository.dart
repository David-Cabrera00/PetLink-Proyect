import '../models/pet_report.dart';
import '../models/report_draft.dart';

abstract class PetReportRepository {
  Future<List<PetReport>> getNearbyReports();
  Future<List<PetReport>> getMyReports();
  Future<PetReport?> getReportById(String id);
  Future<PetReport> createReport(ReportDraft draft);
}
