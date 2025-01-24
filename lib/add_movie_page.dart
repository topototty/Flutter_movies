import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'movie_model.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();

  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveMovie() {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final box = Hive.box<Movie>('movies');

      final newMovie = Movie(
        id: box.length + 1,
        title: _titleController.text,
        genre: _genreController.text,
        year: int.parse(_yearController.text),
        imagePath: _selectedImage!.path,
      );

      box.add(newMovie);

      Navigator.pop(context);
    } else if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите изображение')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавление фильма'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Жанр'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите жанр';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Год'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите год выхода фильма';
                  }
                  if (value.length != 4) {
                    return 'Год должен содержать 4 цифры';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Введите корректное число';
                  }
                  if (year < 1888 || year > DateTime.now().year) {
                    return 'Введите год от 1888 до ${DateTime.now().year}';
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
                          child: Text('Нажмите, чтобы выбрать изображение'),
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
                onPressed: _saveMovie,
                child: const Text('Сохранить фильм'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
