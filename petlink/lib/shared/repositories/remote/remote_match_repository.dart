import '../../../core/network/api_client.dart';
import '../../models/pet_match.dart';
import '../../models/pet_report.dart';
import '../match_repository.dart';

class RemoteMatchRepository implements MatchRepository {
  final ApiClient client;

  RemoteMatchRepository(this.client);

  @override
  Future<List<PetMatch>> getMatchesForUser() async {
    final response = await client.get('/matches');
    final items = response is List ? response : (response as Map)['data'];
    return (items as List<dynamic>? ?? [])
        .map((item) => _parse((item as Map).cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<PetMatch?> getMatchById(String id) async {
    final matches = await getMatchesForUser();
    for (final match in matches) {
      if (match.id == id) return match;
    }
    return null;
  }

  PetMatch _parse(Map<String, dynamic> json) {
    final lost = PetReport.fromJson(
      (json['lostReport'] as Map).cast<String, dynamic>(),
    );
    final found = PetReport.fromJson(
      (json['foundReport'] as Map).cast<String, dynamic>(),
    );
    final score = (json['score'] as num?)?.toDouble() ?? 0;
    final level = switch ((json['level'] as String? ?? '').toLowerCase()) {
      'high' => MatchLevel.high,
      'medium' => MatchLevel.medium,
      _ => MatchLevel.low,
    };
    final distance = (json['distanceKm'] as num?)?.toDouble() ?? 0;
    return PetMatch(
      id: json['id'] as String? ?? '${lost.id}:${found.id}',
      lostReport: lost,
      foundReport: found,
      level: level,
      distanceKm: distance,
      timeDifference: found.createdAt.difference(lost.createdAt).abs(),
      matchingTraits: (json['matchingTraits'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
    );
  }
}
