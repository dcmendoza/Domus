import 'package:domus/models/employee_model.dart';

class Excusa {
  final int id;
  final String name;
  final Employee employee;
  final String description;

  Excusa({
    required this.id,
    required this.name,
    required this.employee,
    required this.description,
  });

  // Convertir JSON a objeto Dart
  factory Excusa.fromJson(Map<String, dynamic> json) {
    return Excusa(
      id: json['id'],
      name: json['name'],
      employee: json['employee'],
      description: json['description'],
    );
  }
}