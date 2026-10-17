import '../../../core/network/api_client.dart';
import '../../models/pet_report.dart';
import '../../models/report_draft.dart';
import '../pet_report_repository.dart';

class RemotePetReportRepository implements PetReportRepository {
  final ApiClient client;
  RemotePetReportRepository(this.client);
  List<PetReport> _list(dynamic value) => ((value is Map ? value['data'] : value) as List<dynamic>? ?? []).map((item) => PetReport.fromJson((item as Map).cast<String, dynamic>())).toList();
  @override Future<List<PetReport>> getNearbyReports() async => _list(await client.get('/reports'));
  @override Future<List<PetReport>> getMyReports() async => _list(await client.get('/reports/mine'));
  @override Future<PetReport?> getReportById(String id) async => PetReport.fromJson((await client.get('/reports/$id') as Map).cast<String, dynamic>());
  @override Future<PetReport> createReport(ReportDraft draft) async => PetReport.fromJson((await client.post('/reports', body: {'type': draft.reportType == null ? 'LOST' : draft.reportType!.name.toUpperCase(), 'name': draft.name, 'species': draft.species, 'breed': draft.breed, 'sex': draft.sex, 'age': draft.age, 'size': draft.size, 'color': draft.color, 'description': draft.description, 'traits': draft.traits, 'latitude': draft.latitude, 'longitude': draft.longitude, 'address': draft.address, 'lastSeenAt': (draft.lastSeenAt ?? DateTime.now()).toIso8601String()} ) as Map).cast<String, dynamic>());
}
