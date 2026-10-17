import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/repositories/activity_repository.dart';
import '../../../shared/repositories/remote/remote_activity_repository.dart';
import '../../auth/providers/auth_provider.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return RemoteActivityRepository(ApiClient.instance);
});

final activityProvider = FutureProvider((ref) async {
  ref.watch(authProvider.select((state) => state.user?.email));
  return ref.read(activityRepositoryProvider).getActivity();
});
