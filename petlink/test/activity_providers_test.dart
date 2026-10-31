import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petlink/features/activity/providers/activity_providers.dart';
import 'package:petlink/features/auth/providers/auth_provider.dart';
import 'package:petlink/shared/models/activity_item.dart';
import 'package:petlink/shared/repositories/activity_repository.dart';

class _FakeActivityRepository implements ActivityRepository {
  List<ActivityItem> items;
  final List<String> markedReadIds = [];
  bool markedAllReadCalled = false;

  _FakeActivityRepository(this.items);

  @override
  Future<List<ActivityItem>> getActivity() async => items;

  @override
  Future<void> markAsRead(String notificationId) async {
    markedReadIds.add(notificationId);
    items = items.map((item) {
      if (item.id == notificationId) {
        return item.copyWith(isRead: true, readAt: DateTime.now());
      }
      return item;
    }).toList();
  }

  @override
  Future<void> markAllAsRead() async {
    markedAllReadCalled = true;
    items = items
        .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
  }
}

void main() {
  test('activityProvider marks single notification as read', () async {
    final fakeRepo = _FakeActivityRepository([
      ActivityItem(
        id: 'notif-1',
        reportId: 'rep-1',
        type: 'sighting',
        title: 'Nuevo avistamiento de Toby',
        body: 'Lo vieron cerca del parque',
        status: 'active',
        reportType: 'lost',
        isRead: false,
        createdAt: DateTime.now(),
      ),
      ActivityItem(
        id: 'rep-2',
        reportId: 'rep-2',
        type: 'report',
        title: 'Reporte de Michi',
        status: 'active',
        reportType: 'lost',
        isRead: true,
        createdAt: DateTime.now(),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        currentUserEmailProvider.overrideWithValue('test@petlink.app'),
        activityRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    // Initial load
    final initialList = await container.read(activityProvider.future);
    expect(initialList.length, 2);
    expect(container.read(unreadActivityCountProvider), 1);

    // Mark notif-1 as read
    await container.read(activityProvider.notifier).markAsRead('notif-1');

    final updatedList = container.read(activityProvider).value!;
    expect(updatedList.firstWhere((i) => i.id == 'notif-1').isRead, isTrue);
    expect(container.read(unreadActivityCountProvider), 0);
    expect(fakeRepo.markedReadIds, contains('notif-1'));
  });

  test('activityProvider marks all notifications as read', () async {
    final fakeRepo = _FakeActivityRepository([
      ActivityItem(
        id: 'notif-1',
        reportId: 'rep-1',
        type: 'sighting',
        title: 'Avistamiento 1',
        status: 'active',
        reportType: 'lost',
        isRead: false,
        createdAt: DateTime.now(),
      ),
      ActivityItem(
        id: 'notif-2',
        reportId: 'rep-2',
        type: 'sighting',
        title: 'Avistamiento 2',
        status: 'active',
        reportType: 'lost',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        currentUserEmailProvider.overrideWithValue('test@petlink.app'),
        activityRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(container.dispose);

    await container.read(activityProvider.future);
    expect(container.read(unreadActivityCountProvider), 2);

    await container.read(activityProvider.notifier).markAllAsRead();

    final updatedList = container.read(activityProvider).value!;
    expect(updatedList.every((i) => i.isRead), isTrue);
    expect(container.read(unreadActivityCountProvider), 0);
    expect(fakeRepo.markedAllReadCalled, isTrue);
  });
}
