import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api-token-auth/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _storage.write(key: 'auth_token', value: token);
    } else {
      throw Exception('Credenciales inválidas');
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.read(key: 'auth_token');
    final url = Uri.parse('$apiBaseUrl/api/users/me/');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

}
