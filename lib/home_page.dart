import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_movie_page.dart';
import 'edit_movie_page.dart';
import 'movie_model.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box<Movie>('movies');

  void _deleteMovie(int index) async {
    await box.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильмы'),
        actions: [
          Switch(
            value: widget.isDarkTheme,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Movie> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'Добавьте фильм',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final movie = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: movie.imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(movie.imagePath),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.movie,
                          size: 50,
                          color: Colors.indigo,
                        ),
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${movie.genre}, ${movie.year}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMoviePage(movieIndex: index),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMovie(index),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(movie.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            movie.imagePath.isNotEmpty
                                ? Image.file(File(movie.imagePath))
                                : const Icon(Icons.movie, size: 100),
                            const SizedBox(height: 10),
                            Text('Жанр: ${movie.genre}'),
                            Text('Год: ${movie.year}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMoviePage(),
            ),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
