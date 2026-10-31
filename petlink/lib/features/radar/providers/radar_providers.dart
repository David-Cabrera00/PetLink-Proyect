import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pet_report.dart';
import '../../../shared/models/pet_match.dart';
import '../../../shared/repositories/pet_report_repository.dart';
import '../../../shared/repositories/match_repository.dart';
import '../../../shared/repositories/mock/mock_pet_report_repository.dart';
import '../../../shared/repositories/mock/mock_match_repository.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/repositories/remote/remote_pet_report_repository.dart';
import '../../../shared/repositories/remote/remote_match_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Sin backend configurado solo se permiten mocks en desarrollo. En release
/// es mejor fallar de forma visible que mostrar datos falsos.
Never _missingConfiguration() {
  throw StateError(
    'API_BASE_URL no está configurada. Compila con '
    '--dart-define=API_BASE_URL=https://tu-api/api/v1',
  );
}

final petReportRepositoryProvider = Provider<PetReportRepository>((ref) {
  final client = ApiClient.instance;
  if (client.isConfigured) return RemotePetReportRepository(client);
  if (kDebugMode) return MockPetReportRepository();
  return _missingConfiguration();
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final client = ApiClient.instance;
  if (client.isConfigured) return RemoteMatchRepository(client);
  if (kDebugMode) return MockMatchRepository();
  return _missingConfiguration();
});

final nearbyReportsProvider = FutureProvider<List<PetReport>>((ref) async {
  // Invalida la caché cuando cambia la cuenta autenticada y evita llamar a la
  // API después de cerrar sesión.
  if (ref.watch(currentUserEmailProvider) == null) return const [];
  final repository = ref.watch(petReportRepositoryProvider);
  final reports = await repository.getNearbyReports();
  return reports.where((report) => !report.isOwner).toList();
});

final matchesProvider = FutureProvider<List<PetMatch>>((ref) async {
  if (ref.watch(currentUserEmailProvider) == null) return const [];
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
