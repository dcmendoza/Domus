import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:domus/utils/constants.dart';

/// Servicio de autenticación: registro, login, perfil y token storage.
class AuthService {
  static const _tokenKey = 'auth_token';
  static final _storage = const FlutterSecureStorage();
  static final _baseUrl = apiBaseUrl;

  /// Crea una nueva cuenta (queda en estado “pendiente” hasta aprobación).
  static Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String telefono,
    required String role,
    String? subRole,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/users/');
    final body = <String, dynamic>{
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'telefono': telefono,
      'role': role,
      'password': password,
      if (subRole != null) 'subrole': subRole,
    };

    final resp = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode != 201) {
      final decoded = jsonDecode(resp.body);
      String message;
      if (decoded is Map<String, dynamic>) {
        // Aplana todos los mensajes de error que venga en listas
        message = decoded.entries
            .map((e) {
              final v = e.value;
              if (v is List) return '${e.key}: ${v.join(', ')}';
              return '${e.key}: $v';
            })
            .join('\n');
      } else {
        message = 'Error registrando usuario';
      }
      throw Exception(message);
    }
  }

  /// Hace login (cualquier rol) y guarda el token en secure storage.
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api-token-auth/');
    final resp = await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': email, 'password': password}))
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final token = data['token'] as String? ?? '';
      if (token.isEmpty) throw Exception('Token no recibido');
      await _storage.write(key: _tokenKey, value: token);
    } else {
      final decoded = jsonDecode(resp.body);
      final error = (decoded is Map<String, dynamic> &&
              decoded['non_field_errors'] != null)
          ? (decoded['non_field_errors'] as List).join(', ')
          : 'Credenciales inválidas';
      throw Exception(error);
    }
  }

  /// Elimina el token (logout).
  static Future<void> logout() => _storage.delete(key: _tokenKey);

  /// Lee el token o lanza si no hay.
  static Future<String> _readToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) throw Exception('No autenticado');
    return token;
  }

  /// Obtiene el perfil (incluye `role`, `registration_status`, etc.).
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _readToken();
    final uri = Uri.parse('$_baseUrl/api/users/me/');
    final resp = await http
        .get(uri, headers: {'Authorization': 'Token $token'})
        .timeout(const Duration(seconds: 10));

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener perfil');
    }
  }
}
