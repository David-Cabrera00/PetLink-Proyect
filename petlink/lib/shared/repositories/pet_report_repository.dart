import '../models/pet_report.dart';

abstract class PetReportRepository {
  Future<List<PetReport>> getNearbyReports();
  Future<List<PetReport>> getMyReports();
  Future<PetReport?> getReportById(String id);
}
