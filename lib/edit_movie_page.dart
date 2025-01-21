import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'movie_model.dart';

class EditMoviePage extends StatefulWidget {
  final int movieIndex; // Индекс фильма в Hive Box

  const EditMoviePage({super.key, required this.movieIndex});

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _genreController;
  late TextEditingController _yearController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Movie>('movies');
    final movie = box.getAt(widget.movieIndex)!;

    _titleController = TextEditingController(text: movie.title);
    _genreController = TextEditingController(text: movie.genre);
    _yearController = TextEditingController(text: movie.year.toString());
    _selectedImage = movie.imagePath.isNotEmpty ? File(movie.imagePath) : null;
  }

  // Метод для выбора изображения
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Сохранение изменений
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Movie>('movies');
      final updatedMovie = Movie(
        id: widget.movieIndex + 1,
        title: _titleController.text,
        genre: _genreController.text,
        year: int.parse(_yearController.text),
        imagePath: _selectedImage?.path ?? '',
      );

      box.putAt(widget.movieIndex, updatedMovie); // Обновляем фильм
      Navigator.pop(context); // Возвращаемся назад
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a genre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Tap to select an image'),
                        ),
                      )
                    : Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
