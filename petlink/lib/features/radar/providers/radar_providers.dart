import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pet_report.dart';
import '../../../shared/models/pet_match.dart';
import '../../../shared/repositories/pet_report_repository.dart';
import '../../../shared/repositories/match_repository.dart';
import '../../../shared/repositories/mock/mock_pet_report_repository.dart';
import '../../../shared/repositories/mock/mock_match_repository.dart';

final petReportRepositoryProvider = Provider<PetReportRepository>((ref) {
  return MockPetReportRepository();
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MockMatchRepository();
});

final nearbyReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  final repository = ref.watch(petReportRepositoryProvider);
  return repository.getNearbyReports();
});

final matchesProvider = FutureProvider<List<PetMatch>>((ref) async {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatchesForUser();
});

final radarSummaryProvider = Provider<RadarSummary>((ref) {
  final nearbyAsync = ref.watch(nearbyReportsProvider);
  final matchesAsync = ref.watch(matchesProvider);

  return nearbyAsync.when(
    data: (reports) {
      final last24h = reports.where((r) {
        return DateTime.now().difference(r.createdAt).inHours <= 24;
      }).length;

      return RadarSummary(
        totalReports: reports.length,
        recentReports: last24h,
        matchesCount: matchesAsync.valueOrNull?.length ?? 0,
      );
    },
    loading: () =>
        const RadarSummary(totalReports: 0, recentReports: 0, matchesCount: 0),
    error: (Object _, StackTrace _) =>
        const RadarSummary(totalReports: 0, recentReports: 0, matchesCount: 0),
  );
});

class RadarSummary {
  final int totalReports;
  final int recentReports;
  final int matchesCount;

  const RadarSummary({
    required this.totalReports,
    required this.recentReports,
    required this.matchesCount,
  });
}
