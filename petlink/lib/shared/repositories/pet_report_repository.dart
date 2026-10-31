import '../models/pet_report.dart';
import '../models/report_draft.dart';

/// Excepción que se lanza cuando el reporte se creó con éxito en el servidor,
/// pero falló la subida de una o más fotos adjuntas.
class PartialReportUploadException implements Exception {
  final PetReport report;
  final int failedPhotosCount;
  final int totalPhotosCount;
  final Object? cause;

  const PartialReportUploadException({
    required this.report,
    required this.failedPhotosCount,
    required this.totalPhotosCount,
    this.cause,
  });

  @override
  String toString() =>
      'PartialReportUploadException(reportId: ${report.id}, failedPhotos: $failedPhotosCount/$totalPhotosCount, cause: $cause)';
}

abstract class PetReportRepository {
  Future<List<PetReport>> getNearbyReports();
  Future<List<PetReport>> getMyReports();
  Future<PetReport?> getReportById(String id);
  Future<PetReport> createReport(ReportDraft draft);
  Future<void> deleteReport(String id);
}
