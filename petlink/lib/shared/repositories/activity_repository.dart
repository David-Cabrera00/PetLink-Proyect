import '../models/activity_item.dart';

abstract class ActivityRepository {
  Future<List<ActivityItem>> getActivity();
}
