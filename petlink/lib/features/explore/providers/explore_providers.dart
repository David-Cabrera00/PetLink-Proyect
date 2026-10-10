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

final exploreSearchQueryProvider = StateProvider<String>((ref) => '');

final exploreReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  final repository = ref.watch(petReportRepositoryProvider);
  final filter = ref.watch(exploreFilterProvider);
  final currentLocation = ref.watch(exploreLocationProvider);
  final searchQuery = ref.watch(exploreSearchQueryProvider).trim().toLowerCase();

  final reports = await repository.getNearbyReports();

  return reports.where((report) {
    // 1. Filtrado por tipo o cercanía
    final matchesFilter = switch (filter) {
      ExploreFilter.all => true,
      ExploreFilter.lost => report.type == ReportType.lost,
      ExploreFilter.found => report.type == ReportType.found,
      ExploreFilter.nearby => () {
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
      }(),
    };

    if (!matchesFilter) return false;

    // 2. Filtrado por búsqueda de texto
    if (searchQuery.isNotEmpty) {
      final name = report.pet.name.toLowerCase();
      final breed = report.pet.breed.toLowerCase();
      final species = report.pet.species.toLowerCase();
      final address = report.address.toLowerCase();
      final description = report.description.toLowerCase();

      final matchesQuery = name.contains(searchQuery) ||
          breed.contains(searchQuery) ||
          species.contains(searchQuery) ||
          address.contains(searchQuery) ||
          description.contains(searchQuery);

      if (!matchesQuery) return false;
    }

    return true;
  }).toList();
});

final selectedReportProvider = StateProvider<PetReport?>((ref) => null);
