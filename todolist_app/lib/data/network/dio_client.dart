import 'package:dio/dio.dart';

class DioClient {
  // Instancia Singleton
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://98.89.202.212:8080',
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 3000),
        contentType: 'application/json',
      ),
    );
  }

  // Getter para acceder a la instancia de Dio desde los repositorios
  Dio get dio => _dio;
}