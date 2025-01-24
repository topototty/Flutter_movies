import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String genre;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String imagePath;

  Movie({
    this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.imagePath,
  });
}
