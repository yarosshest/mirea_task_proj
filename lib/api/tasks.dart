import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:mirea_task_proj/api/requests/http.dart';
import 'package:mirea_task_proj/api/requests/multipart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Предполагаем, что CustomResponse, httpRequest и multipartRequest уже определены выше

class Task {
  final int id;
  final String title;
  final String? description;
  final String status;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
    );
  }
}

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<TaskApi>(TaskApi());
}

class TaskApi {
  final String host = "78.136.223.100:60106";

  Future<List<Task>> fetchTasks([int page = 0, String? status]) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;

    final uri = Uri.http(host, "tasks", {
      'skip': '${page * 10}',
      if (status != null) 'status': status,
    });

    final response = await httpRequest(
      'GET',
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> taskJson = json.decode(response.body);
      return taskJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<CustomResponse> addTaskRequest(String title, String description) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks");

    final response = await httpRequest(
      'POST',
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'status': 'Assigned',
      }),
    );

    return response;
  }

  Future<CustomResponse> fetchTaskDetailsRequest(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks/$taskId");

    final response = await httpRequest(
      'GET',
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<CustomResponse> updateTaskRequest(int taskId, String title, String description, String status) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks/$taskId");

    final response = await httpRequest(
      'PUT',
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'status': status,
      }),
    );

    return response;
  }

  Future<CustomResponse> deleteTaskRequest(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks/$taskId");

    final response = await httpRequest(
      'DELETE',
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future<List<String>?> getTaskPhotoRequest(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks/$taskId/photos");

    final response = await httpRequest(
      'GET',
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> photosJson = json.decode(response.body);
      if (photosJson.isNotEmpty) {
        List<String> ret = [];
        for (var photo in photosJson) {
          ret.add(photo['url']);
        }
        return ret;
      }
    }
    return null;
  }

  Future<CustomResponse> uploadTaskPhoto(int taskId, File? photo, Uint8List? webPhoto) async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('access_token')!;
    final url = Uri.http(host, "tasks/$taskId/photos");

    List<int>? fileBytes;
    String filename = 'upload.jpg';

    if (kIsWeb && webPhoto != null) {
      // Веб: фото в байтах
      fileBytes = webPhoto;
    } else if (photo != null) {
      // Мобильные платформы: читаем файл
      fileBytes = await photo.readAsBytes();
    } else {
      throw Exception("No file selected");
    }

    final response = await multipartRequest(
      'POST',
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      fieldName: 'file',
      fileName: filename,
      fileBytes: fileBytes,
      fileType: 'image/jpeg',
    );

    return response;
  }
}
