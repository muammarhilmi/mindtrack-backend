import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/storage/token_storage.dart';

class AuthProvider {
  final Dio _dio = DioService.dio;

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response> googleLogin({
    required String idToken,
  }) async {
    return await _dio.post('/auth/google', data: {
      'id_token': idToken,
    });
  }

  Future<Response> me(String token) async {
    return await _dio.get('/auth/me', options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));
  }

  Future<Response> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? password,
    String? theme,
  }) async {
    final token = await TokenStorage.getToken();
    
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (gender != null) data['gender'] = gender;
    if (password != null) {
      data['password'] = password;
      data['confirm_password'] = password;
    }
    if (theme != null) data['theme'] = theme;

    return await _dio.put('/auth/profile', data: data, options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));
  }
}