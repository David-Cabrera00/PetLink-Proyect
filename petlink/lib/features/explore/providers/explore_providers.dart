import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/pet_report.dart';
import '../../radar/providers/radar_providers.dart';

enum ExploreFilter { all, lost, found, nearby }

final exploreFilterProvider = StateProvider<ExploreFilter>(
  (ref) => ExploreFilter.all,
);

final exploreLocationProvider = StateProvider<LatLng?>((ref) => null);

final exploreReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  final repository = ref.watch(petReportRepositoryProvider);
  final filter = ref.watch(exploreFilterProvider);
  final currentLocation = ref.watch(exploreLocationProvider);

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
        if (currentLocation != null) {
          final reportLocation = LatLng(report.latitude, report.longitude);
          final distance = Distance().as(
            LengthUnit.Kilometer,
            currentLocation,
            reportLocation,
          );
          return distance <= AppConstants.searchRadiusKm;
        }
        return report.distanceKm <= AppConstants.searchRadiusKm;
    }
  }).toList();
});

final selectedReportProvider = StateProvider<PetReport?>((ref) => null);
