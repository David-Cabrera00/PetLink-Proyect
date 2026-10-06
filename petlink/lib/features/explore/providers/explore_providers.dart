import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/pet_report.dart';
import '../../radar/providers/radar_providers.dart';

enum ExploreFilter { all, lost, found, nearby }

final exploreFilterProvider = StateProvider<ExploreFilter>((ref) => ExploreFilter.all);

final exploreReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  final repository = ref.watch(petReportRepositoryProvider);
  final filter = ref.watch(exploreFilterProvider);

  final reports = await repository.getNearbyReports();

  return reports.where((report) {
    switch (filter) {
      case ExploreFilter.all:
        return true;
      case ExploreFilter.lost:
        return report.type == ReportType.lost;
      case ExploreFilter.found:
        return report.type == ReportType.found;
      case ExploreFilter.nearby:
        return report.distanceKm <= 5.0;
    }
  }).toList();
});

final selectedReportProvider = StateProvider<PetReport?>((ref) => null);
