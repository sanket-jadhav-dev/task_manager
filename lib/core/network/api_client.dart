import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manager/core/utils/app_constants.dart';
import 'package:task_manager/data/models/task_model.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl = AppConstants.baseUrl;

  ApiClient({required this.client});

  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required bool completed,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'title': title,
          'completed': completed,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await client.patch(
        Uri.parse('$baseUrl/todos/${task.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'title': task.title,
          'completed': task.completed,
        }),
      );

      if (response.statusCode == 200) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}