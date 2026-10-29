class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final String sex;
  final String age;
  final String size;
  final String color;
  final String description;
  final String? primaryPhotoUrl;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.sex,
    required this.age,
    required this.size,
    required this.color,
    required this.description,
    this.primaryPhotoUrl,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    species: json['species'] as String? ?? '',
    breed: json['breed'] as String? ?? '',
    sex: json['sex'] as String? ?? '',
    age: json['age'] as String? ?? '',
    size: json['size'] as String? ?? '',
    color: json['color'] as String? ?? '',
    description: json['description'] as String? ?? '',
    primaryPhotoUrl: json['primaryPhotoUrl'] as String?,
  );
}
