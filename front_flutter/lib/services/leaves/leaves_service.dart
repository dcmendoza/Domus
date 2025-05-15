import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/constants.dart';
import '../../models/leave_request.dart';
import 'package:file_picker/file_picker.dart';

class LeavesService {
  static final _storage = FlutterSecureStorage();
  static final _baseUrl = apiBaseUrl; // p.ej. 'http://localhost:8000'

  static Future<String> _token() async {
    final t = await _storage.read(key: 'auth_token');
    if (t == null) throw Exception('No autenticado');
    return t;
  }

  /// Lista todas las solicitudes (admin) o propias (empleado).
  static Future<List<LeaveRequest>> fetchLeaves() async {
    final token = await _token();
    final uri   = Uri.parse('$_baseUrl/api/leaves/');
    final resp  = await http.get(uri, headers: {
      'Authorization': 'Token $token',
    });
    if (resp.statusCode != 200) {
      throw Exception('Error cargando permisos (${resp.statusCode})');
    }
    final decoded = jsonDecode(resp.body);
    final rawList = decoded is Map && decoded['results'] is List
        ? decoded['results'] as List
        : decoded as List;
    return rawList
        .map((e) => LeaveRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Aprueba o rechaza una solicitud (solo admin).
  static Future<void> reviewLeave({
    required int id,
    required bool approve,
  }) async {
    final token = await _token();
    final uri   = Uri.parse('$_baseUrl/api/leaves/$id/review/');
    final resp  = await http.post(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({'decision': approve ? 'aprobada' : 'rechazada'}),
    );
    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body);
      throw Exception(err['detail'] ?? 'Error revisando solicitud');
    }
  }

  /// Crea una nueva solicitud con adjunto.
  static Future<void> createLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required String filePath, // path local al documento
  }) async {
    final token = await _token();
    final uri   = Uri.parse('$_baseUrl/api/leaves/');
    final req   = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Token $token'
      ..fields['type']      = type
      ..fields['start_date']= startDate.toIso8601String().split('T').first
      ..fields['end_date']  = endDate.toIso8601String().split('T').first
      ..fields['reason']    = reason;
        // Usa directamente los bytes para garantizar que siempre se adjunte el contenido:
      final picked = await FilePicker.platform.pickFiles(
        withData: true, 
        type: FileType.custom,
        allowedExtensions: ['pdf','jpg','png'],
      );
      if (picked == null || picked.files.isEmpty) {
        throw Exception('No se seleccionó el documento');
      }
      final file = picked.files.first;
      req.files.add(
        http.MultipartFile.fromBytes(
          'document',
          file.bytes!,
          filename: file.name,
        ),
      );

    final streamed = await req.send();
    final resp     = await http.Response.fromStream(streamed);
    if (resp.statusCode != 201) {
      final err = jsonDecode(resp.body);
      throw Exception(err.toString());
    }
  }

  /// Actualiza (admin o propio, pendiente).
  static Future<void> updateLeave({
    required int id,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _token();
    final uri   = Uri.parse('$_baseUrl/api/leaves/$id/');
    final body  = <String, dynamic>{};
    if (reason    != null) body['reason']     = reason;
    if (startDate != null) body['start_date'] = startDate.toIso8601String().split('T').first;
    if (endDate   != null) body['end_date']   = endDate.toIso8601String().split('T').first;

    final resp = await http.patch(
      uri,
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      final err = jsonDecode(resp.body);
      throw Exception(err.toString());
    }
  }

  /// Elimina (admin o propio, pendiente).
  static Future<void> deleteLeave(int id) async {
    final token = await _token();
    final uri   = Uri.parse('$_baseUrl/api/leaves/$id/');
    final resp  = await http.delete(uri, headers: {
      'Authorization': 'Token $token',
    });
    if (resp.statusCode != 204) {
      throw Exception('Error eliminando solicitud');
    }
  }
}
