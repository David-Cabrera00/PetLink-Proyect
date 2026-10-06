import 'pet_report.dart';

enum MatchLevel { low, medium, high }

class PetMatch {
  final String id;
  final PetReport lostReport;
  final PetReport foundReport;
  final MatchLevel level;
  final double distanceKm;
  final Duration timeDifference;
  final List<String> matchingTraits;

  const PetMatch({
    required this.id,
    required this.lostReport,
    required this.foundReport,
    required this.level,
    required this.distanceKm,
    required this.timeDifference,
    required this.matchingTraits,
  });
}
