import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pet_report.dart';
import '../../auth/providers/auth_provider.dart';
import '../../radar/providers/radar_providers.dart';

enum ReportsFilter { active, recovered, all }

final reportsFilterProvider = StateProvider<ReportsFilter>(
  (ref) => ReportsFilter.active,
);

final savedReportIdsProvider = StateProvider<Set<String>>((ref) => <String>{});

final myReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  // Makes Riverpod discard the previous account's cached reports when the
  // authenticated user changes.
  ref.watch(authProvider.select((state) => state.user?.email));
  final repository = ref.watch(petReportRepositoryProvider);
  final filter = ref.watch(reportsFilterProvider);

  final reports = await repository.getMyReports();

  return reports.where((report) {
    switch (filter) {
      case ReportsFilter.active:
        return report.status == ReportStatus.active;
      case ReportsFilter.recovered:
        return report.status == ReportStatus.recovered;
      case ReportsFilter.all:
        return true;
    }
  }).toList();
});

final reportByIdProvider = FutureProvider.family<PetReport?, String>((
  ref,
  id,
) async {
  // Never reuse the ownership state from another authenticated account.
  ref.watch(authProvider.select((state) => state.user?.email));
  final repository = ref.watch(petReportRepositoryProvider);
  return repository.getReportById(id);
});
