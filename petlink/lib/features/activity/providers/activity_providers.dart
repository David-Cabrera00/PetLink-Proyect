import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/activity_item.dart';
import '../../../shared/repositories/activity_repository.dart';
import '../../../shared/repositories/remote/remote_activity_repository.dart';
import '../../auth/providers/auth_provider.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return RemoteActivityRepository(ApiClient.instance);
});

class ActivityNotifier extends AsyncNotifier<List<ActivityItem>> {
  @override
  Future<List<ActivityItem>> build() async {
    ref.watch(authProvider.select((state) => state.user?.email));
    return ref.read(activityRepositoryProvider).getActivity();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(activityRepositoryProvider).getActivity(),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Actualización optimista inmediata en la UI
    state = AsyncData(
      current.map((item) {
        if (item.id == id && !item.isRead) {
          return item.copyWith(isRead: true, readAt: DateTime.now());
        }
        return item;
      }).toList(),
    );

    // Persistencia en el backend
    await ref.read(activityRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Actualización optimista inmediata en la UI
    state = AsyncData(
      current
          .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
          .toList(),
    );

    // Persistencia en el backend
    await ref.read(activityRepositoryProvider).markAllAsRead();
  }
}

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, List<ActivityItem>>(
      ActivityNotifier.new,
    );

final unreadActivityCountProvider = Provider<int>((ref) {
  final activity = ref.watch(activityProvider);
  return activity.valueOrNull
          ?.where((item) => item.isNotification && !item.isRead)
          .length ??
      0;
});
