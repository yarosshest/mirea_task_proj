import 'dart:typed_data';
import 'dart:io' show File; // Оставляем, чтобы использовать File? для сохранения ссылки на мобильном
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirea_task_proj/api/tasks.dart';
import 'package:mirea_task_proj/file_hendlesr/file_picker.dart';
// import 'package:mirea_task_proj/pages/tasks/file_hendlesr/file_picker.dart'; // <-- единственный импорт (условный)
import 'package:flutter/foundation.dart' show kIsWeb; // для проверки платформы
import 'dart:convert';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Ссылка на байты (веб) или File (мобайл)
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  final TaskApi taskApi = TaskApi();

  // Статус задачи
  String _status = 'assigned';
  final List<String> _statusOptions = ['assigned', 'resolved', 'closed', 'feedback', 'rejected'];

  // Создаём экземпляр FilePicker (через условный экспорт будет либо FilePickerMobile, либо FilePickerWeb)
  late final FilePicker _filePicker;
  // Если хотите, можно делать проверку вида:
  // final FilePicker _filePicker = kIsWeb ? FilePickerWeb() : FilePickerMobile();
  // Но благодаря условным экспортам обычно достаточно просто написать FilePickerMobile(),
  // ведь на вебе класс FilePickerMobile заменится на FilePickerWeb автоматически.

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    try {
      final response = await taskApi.fetchTaskDetailsRequest(widget.taskId);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _titleController.text = data['title'];
          _descriptionController.text = data['description'] ?? '';
          _status = data['status'] ?? 'assigned';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load task');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  Future<void> _updateTask() async {
    setState(() => _isUpdating = true);
    try {
      final response = await taskApi.updateTaskRequest(
          widget.taskId, _titleController.text, _descriptionController.text, _status);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully')));
      } else {
        throw Exception('Failed to update task');
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteTask() async {
    setState(() => _isDeleting = true);

    try {
      final response = await taskApi.deleteTaskRequest(widget.taskId);

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // вернуться с успехом
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  Widget buildTaskPhoto(int taskId) {
    return FutureBuilder<List<String>?>(
      future: taskApi.getTaskPhotoRequest(taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text("No photos available"));
        } else {
          return Column(
            children: snapshot.data!.map((imageUrl) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) {
                    print(error);
                    return const Icon(Icons.error);
                  },
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Future<void> _pickImage() async {
    // С помощью условного экспорта:
    // - на вебе _filePicker будет от класса FilePickerWeb
    // - на мобильных _filePicker будет от класса FilePickerMobile
    final bytes = await _filePicker.pickImage();

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo selected')),
      );
      return;
    }

    if (kIsWeb) {
      // Для веба у нас есть только байты
      _selectedImageBytes = bytes;
      _selectedImageFile = null;
    } else {
      // Для мобильной платформы можно временно сохранить файл,
      // но поскольку мы вернули bytes, у нас нет пути к файлу
      // (если нужно, можно изменить реализацию FilePickerMobile).
      // Или же в FilePickerMobile вы можете возвращать File вместо Uint8List,
      // в зависимости от того, как вам удобно.
      _selectedImageBytes = bytes;
      _selectedImageFile = null;
    }

    setState(() {});
    await _uploadPhoto();
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImageFile == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo selected')),
      );
      return;
    }
    setState(() => _isUploadingPhoto = true);

    final response = await taskApi.uploadTaskPhoto(
      widget.taskId,
      _selectedImageFile,
      _selectedImageBytes,
    );

    setState(() => _isUploadingPhoto = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Photo uploaded successfully')));
      _fetchTaskDetails(); // Обновим список фотографий
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to upload photo')));
    }
  }

  bool _isUploadingPhoto = false; // для индикации загрузки

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteTask,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown для выбора статуса
            DropdownButtonFormField<String>(
              value: _status,
              onChanged: (newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: _statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status[0].toUpperCase() + status.substring(1)),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            buildTaskPhoto(widget.taskId),
            const SizedBox(height: 16),
            if (_isUploadingPhoto) const Center(child: CircularProgressIndicator()),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Photo'),
            ),
            const SizedBox(height: 16),
            _isUpdating
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
