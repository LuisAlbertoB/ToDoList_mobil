import 'package:dio/dio.dart';
import 'package:todolist_app/data/network/dio_client.dart';
import 'package:todolist_app/model/task_model.dart';

class TaskRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Task>> getTasks({required String token}) async {
    try {
      final response = await _dio.get(
        '/tasks',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List<dynamic> taskData = response.data;
      return taskData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> createTask({
    required String title,
    required String content,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: {'title': title, 'content': content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask({required Task task, required String token}) async {
    try {
      await _dio.put(
        '/tasks/${task.id}',
        data: task.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask({required int taskId, required String token}) async {
    try {
      await _dio.delete(
        '/tasks/$taskId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }
}