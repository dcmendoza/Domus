import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000/api/";

  Future<List<dynamic>> fetchEmployees() async {
    final response = await http.get(Uri.parse("${baseUrl}employees/"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener los usuarios");
    }
  }
}
