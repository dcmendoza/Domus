import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:domus/utils/constants.dart';

/// Servicio para manejar reservas: listar, crear, revisar y fetch de instalaciones.
class ReservationsService {
  static final _storage = FlutterSecureStorage();
  static final _baseUrl = apiBaseUrl;

  /// Extrae lista ya sea de `results` o de un array directo.
  static List<dynamic> _extractList(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
      return decoded['results'] as List<dynamic>;
    }
    if (decoded is List) {
      return decoded;
    }
    throw Exception('Formato inesperado en la respuesta del servidor');
  }

  /// Fetch de todas las reservas.
  static Future<List<dynamic>> fetchReservations() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/reservations/');
    final resp = await http.get(uri, headers: {'Authorization': 'Token $token'});
    if (resp.statusCode != 200) throw Exception('Error cargando reservas');
    final decoded = jsonDecode(resp.body);
    return _extractList(decoded);
  }

  /// Fetch de instalaciones para el dropdown.
  static Future<List<dynamic>> fetchFacilities() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/facilities/');
    final resp = await http.get(uri, headers: {'Authorization': 'Token $token'});
    if (resp.statusCode != 200) throw Exception('Error cargando instalaciones');
    final decoded = jsonDecode(resp.body);
    return _extractList(decoded);
  }

  /// Crea una nueva reserva.
  static Future<void> createReservation({
    required int facility,
    required DateTime startDatetime,
    required DateTime endDatetime,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');

    final uri = Uri.parse('$_baseUrl/api/reservations/');
    final body = {
      'facility': facility,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
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
      try {
        final decoded = jsonDecode(resp.body);
        String message;
        if (decoded is Map<String, dynamic>) {
          message = decoded.entries.map((e) {
            final v = e.value;
            if (v is List) return '${e.key}: ${v.join(', ')}';
            return '${e.key}: $v';
          }).join('\n');
        } else {
          message = decoded.toString();
        }
        throw Exception(message);
      } catch (_) {
        throw Exception('Error creando reserva: ${resp.body}');
      }
    }
  }

  /// Admin aprueba o rechaza una reserva.
  static Future<void> reviewReservation({
    required int id,
    required String decision,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No autenticado');
    final uri = Uri.parse('$_baseUrl/api/reservations/$id/review/');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({'decision': decision}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Error revisando reserva: ${resp.body}');
    }
  }
}
