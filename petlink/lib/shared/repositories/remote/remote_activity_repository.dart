import '../../../core/network/api_client.dart';
import '../../models/activity_item.dart';
import '../activity_repository.dart';

class RemoteActivityRepository implements ActivityRepository {
  final ApiClient client;

  RemoteActivityRepository(this.client);

  @override
  Future<List<ActivityItem>> getActivity() async {
    if (!client.isConfigured) return [];
    try {
      final response = await client.get('/activity');
      final items = response is List ? response : (response as Map)['data'];
      return (items as List<dynamic>? ?? [])
          .map(
            (item) =>
                ActivityItem.fromJson((item as Map).cast<String, dynamic>()),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (!client.isConfigured) return;
    try {
      await client.patch(
        '/activity/notifications/$notificationId/read',
        body: {},
      );
    } catch (_) {
      // Ignorar errores transitorios de red para no romper el flujo
    }
  }

  @override
  Future<void> markAllAsRead() async {
    if (!client.isConfigured) return;
    try {
      await client.patch('/activity/read-all', body: {});
    } catch (_) {
      // Ignorar errores transitorios de red para no romper el flujo
    }
  }
}
