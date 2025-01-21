import 'dart:io'; // Для работы с локальными файлами
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_movie_page.dart'; // Экран для редактирования фильма
import 'add_movie_page.dart'; // Экран для добавления фильма
import 'movie_model.dart'; // Модель Movie

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
  final box = Hive.box<Movie>('movies'); // Открытие Box для работы с Hive

  // Метод для удаления фильма
  void _deleteMovie(int index) async {
    await box.deleteAt(index); // Удаляем фильм по индексу
    setState(() {}); // Обновляем UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          // Переключатель для смены темы
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
              child: Text('No movies added yet'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final movie = box.getAt(index)!; // Получаем фильм из Box

              return ListTile(
                leading: movie.imagePath.isNotEmpty
                    ? Image.file(
                        File(movie.imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.movie,
                        size: 50,
                      ),
                title: Text(movie.title),
                subtitle: Text('${movie.genre}, ${movie.year}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Открываем экран для редактирования фильма
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMoviePage(movieIndex: index),
                          ),
                        ).then((_) {
                          setState(() {}); // Обновляем список после редактирования
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
                  // Открываем диалоговое окно с деталями фильма
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
                          Text('Genre: ${movie.genre}'),
                          Text('Year: ${movie.year}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Открываем экран для добавления нового фильма
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMoviePage(),
            ),
          ).then((_) {
            setState(() {}); // Обновляем список после возвращения
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
