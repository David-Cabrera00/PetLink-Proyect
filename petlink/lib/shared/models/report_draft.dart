import 'package:petlink/shared/models/pet_report.dart';

class ReportDraft {
  final ReportType? reportType;
  final String name;
  final String species;
  final String breed;
  final String sex;
  final String age;
  final String size;
  final String color;
  final String description;
  final String traits;
  final List<String> photos;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime? lastSeenAt;
  final bool? isPetWithFinder;

  const ReportDraft({
    this.reportType,
    this.name = '',
    this.species = '',
    this.breed = '',
    this.sex = '',
    this.age = '',
    this.size = '',
    this.color = '',
    this.description = '',
    this.traits = '',
    this.photos = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.address = '',
    this.lastSeenAt,
    this.isPetWithFinder,
  });

  ReportDraft copyWith({
    ReportType? reportType,
    String? name,
    String? species,
    String? breed,
    String? sex,
    String? age,
    String? size,
    String? color,
    String? description,
    String? traits,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? lastSeenAt,
    bool? isPetWithFinder,
    bool clearLastSeenAt = false,
    bool clearIsPetWithFinder = false,
  }) {
    return ReportDraft(
      reportType: reportType ?? this.reportType,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      size: size ?? this.size,
      color: color ?? this.color,
      description: description ?? this.description,
      traits: traits ?? this.traits,
      photos: photos ?? this.photos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      lastSeenAt: clearLastSeenAt ? null : (lastSeenAt ?? this.lastSeenAt),
      isPetWithFinder: clearIsPetWithFinder
          ? null
          : (isPetWithFinder ?? this.isPetWithFinder),
    );
  }

  bool get isPetInfoComplete =>
      name.isNotEmpty &&
      species.isNotEmpty &&
      breed.isNotEmpty &&
      sex.isNotEmpty &&
      age.isNotEmpty &&
      size.isNotEmpty &&
      color.isNotEmpty;

  bool get isLocationComplete =>
      address.isNotEmpty && latitude != 0.0 && longitude != 0.0;

  bool get isDetailsComplete => description.isNotEmpty && lastSeenAt != null;
}
