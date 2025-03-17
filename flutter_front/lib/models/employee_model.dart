class Employee {
  final int id;
  final String name;
  final String role;
  final String? phone;
  final String? email;
  final int userId;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.userId,
    this.phone,
    this.email,
  });

  // Convertir JSON a objeto Dart
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['user']['name'],
      role: json['role'],
      phone: json['user']['phone'],
      email: json['user']['email'],
      userId: json['user']['id'],
    );
  }
}
