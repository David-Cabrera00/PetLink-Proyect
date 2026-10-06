import '../models/pet_match.dart';

abstract class MatchRepository {
  Future<List<PetMatch>> getMatchesForUser();
  Future<PetMatch?> getMatchById(String id);
}
