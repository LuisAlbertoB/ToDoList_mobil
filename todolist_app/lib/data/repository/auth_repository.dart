import 'package:dio/dio.dart';
import 'package:todolist_app/data/network/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<Response> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users/signup', // Corregimos el endpoint
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}