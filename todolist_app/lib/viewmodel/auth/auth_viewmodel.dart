import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/data/repository/auth_repository.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthState _state = AuthState.idle;
  AuthState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      await _authRepository.signUp(
        username: username,
        email: email,
        password: password,
      );
      _setState(AuthState.success);
    } on DioException catch (e) {
      // Capturamos el mensaje de error específico de la API
      if (e.response?.data is Map &&
          (e.response!.data as Map).containsKey('error')) {
        _errorMessage = e.response!.data['error'];
      } else {
        _errorMessage = e.response?.data?.toString() ?? 'An unknown error occurred';
      }
      _setState(AuthState.error);
    } catch (e) {
      _errorMessage = 'Failed to connect to the server.';
      _setState(AuthState.error);
    }
  }
}
