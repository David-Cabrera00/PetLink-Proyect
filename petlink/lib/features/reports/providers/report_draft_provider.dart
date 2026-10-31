import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/report_draft.dart';
import '../../../shared/models/pet_report.dart';

final reportDraftProvider =
    StateNotifierProvider<ReportDraftNotifier, ReportDraft>((ref) {
      return ReportDraftNotifier();
    });

class ReportDraftNotifier extends StateNotifier<ReportDraft> {
  ReportDraftNotifier() : super(const ReportDraft());

  void setReportType(ReportType type) {
    state = state.copyWith(reportType: type);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setSpecies(String species) {
    state = state.copyWith(species: species);
  }

  void setBreed(String breed) {
    state = state.copyWith(breed: breed);
  }

  void setSex(String sex) {
    state = state.copyWith(sex: sex);
  }

  void setAge(String age) {
    state = state.copyWith(age: age);
  }

  void setSize(String size) {
    state = state.copyWith(size: size);
  }

  void setColor(String color) {
    state = state.copyWith(color: color);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setTraits(String traits) {
    state = state.copyWith(traits: traits);
  }

  void addPhoto(String photoUrl) {
    if (state.photos.length < 3) {
      state = state.copyWith(photos: [...state.photos, photoUrl]);
    }
  }

  void removePhoto(int index) {
    final photos = List<String>.from(state.photos);
    photos.removeAt(index);
    state = state.copyWith(photos: photos);
  }

  void setLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  void setLastSeenAt(DateTime dateTime) {
    state = state.copyWith(lastSeenAt: dateTime);
  }

  void setIsPetWithFinder(bool value) {
    state = state.copyWith(isPetWithFinder: value);
  }

  void applyAiAnalysis(Map<String, dynamic> analysis) {
    final species = analysis['species']?.toString();
    final breed = analysis['breed']?.toString();
    final color = analysis['color']?.toString();
    final size = analysis['size']?.toString();
    final sex = analysis['sex']?.toString();
    final traits = analysis['visibleTraits'] is List
        ? (analysis['visibleTraits'] as List).join(', ')
        : analysis['visibleTraits']?.toString();

    state = state.copyWith(
      species: (species != null && species.isNotEmpty) ? species : state.species,
      breed: (breed != null && breed.isNotEmpty) ? breed : state.breed,
      color: (color != null && color.isNotEmpty) ? color : state.color,
      size: (size != null && size.isNotEmpty) ? size : state.size,
      sex: (sex != null && sex.isNotEmpty) ? sex : state.sex,
      traits: (traits != null && traits.isNotEmpty && state.traits.isEmpty)
          ? traits
          : state.traits,
    );
  }

  void clearDraft() {
    state = const ReportDraft();
  }
}
