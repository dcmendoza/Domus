import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/constants.dart';

/// Servicio para manejar turnos: listar, crear, y fetch de datos auxiliares.
class ShiftsService {
  static final _storage = FlutterSecureStorage();
  static final _baseUrl = apiBaseUrl;

  /// Helper privado que extrae la lista ya sea de un array directo
  /// o de un objeto paginado con `results`.
  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
      return decoded['results'] as List<dynamic>;
    }
    if (decoded is List) {
      return decoded;
    }
    throw Exception('Formato inesperado en la respuesta del servidor');
  }

  /// Trae todos los turnos cuyo inicio/fin caigan en [date].
  static Future<List<dynamic>> fetchShiftsForDate(DateTime date) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final day = date.toIso8601String().split('T').first;
    final uri = Uri.parse('$_baseUrl/api/shifts/?start=$day&end=$day');
    final resp = await http.get(uri, headers: {'Authorization': 'Token $token'});
    if (resp.statusCode != 200) {
      throw Exception('Error cargando turnos');
    }

    final decoded = jsonDecode(resp.body);
    List<dynamic> raw;
    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      raw = decoded['results'] as List<dynamic>;
    } else if (decoded is List) {
      raw = decoded;
    } else {
      throw Exception('Formato inesperado de turnos');
    }

    return raw;
  }


  /// Trae la lista de empleados (rol=empleado) desde la API.
  static Future<List<dynamic>> fetchEmployees() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    // suponemos que tu API permite filtrar con ?role=empleado
    final uri = Uri.parse('$_baseUrl/api/users/?role=empleado');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Token $token'},
    );
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      return _extractList(decoded);
    } else {
      throw Exception('Error cargando empleados (${resp.statusCode})');
    }
  }

  /// Trae la lista de torres.
  static Future<List<dynamic>> fetchTowers() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/towers/');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Token $token'},
    );
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      return _extractList(decoded);
    } else {
      throw Exception('Error cargando torres (${resp.statusCode})');
    }
  }

  /// Trae la lista de instalaciones.
  static Future<List<dynamic>> fetchFacilities() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/facilities/');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Token $token'},
    );
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      return _extractList(decoded);
    } else {
      throw Exception('Error cargando instalaciones (${resp.statusCode})');
    }
  }

  /// Crea un nuevo turno en la API.
  static Future<void> createShift({
    required int employee,
    required String area,
    required DateTime startDatetime,
    required DateTime endDatetime,
    int? tower,
    int? facility,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/shifts/');
    final body = {
      'employee': employee,
      'area': area,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      if (tower != null) 'tower': tower,
      if (facility != null) 'facility': facility,
    };
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 201) {
      final error = jsonDecode(resp.body);
      throw Exception(
        error is Map ? (error['detail'] ?? error).toString() : error.toString()
      );
    }
  }
}
