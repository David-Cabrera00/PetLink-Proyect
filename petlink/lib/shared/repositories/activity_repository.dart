import '../models/activity_item.dart';

abstract class ActivityRepository {
  Future<List<ActivityItem>> getActivity();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
