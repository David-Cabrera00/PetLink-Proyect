import '../../../core/network/api_client.dart';
import '../../models/activity_item.dart';
import '../activity_repository.dart';

class RemoteActivityRepository implements ActivityRepository {
  final ApiClient client;

  RemoteActivityRepository(this.client);

  @override
  Future<List<ActivityItem>> getActivity() async {
    final response = await client.get('/activity');
    final items = response is List ? response : (response as Map)['data'];
    return (items as List<dynamic>? ?? [])
        .map((item) => ActivityItem.fromJson((item as Map).cast<String, dynamic>()))
        .toList();
  }
}
