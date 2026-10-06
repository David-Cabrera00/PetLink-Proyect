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
}
