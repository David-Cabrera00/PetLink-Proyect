class Sighting {
  final String id;
  final String reportId;
  final double latitude;
  final double longitude;
  final String description;
  final String? photoUrl;
  final DateTime createdAt;

  const Sighting({
    required this.id,
    required this.reportId,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.photoUrl,
    required this.createdAt,
  });
}
