class Employee {
  final int id;
  final String name;
  final String role;
  final String? phone;
  final String? email;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    this.phone,
    this.email,
  });

  // Convertir JSON a objeto Dart
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
