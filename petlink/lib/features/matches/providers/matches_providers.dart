import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pet_match.dart';
import '../../radar/providers/radar_providers.dart';

final matchByIdProvider = FutureProvider.family<PetMatch?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatchById(id);
});
