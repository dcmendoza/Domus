class Notificacion {
  final int id;
  final String name;
  final String date;
  final String? description;
  final String state;
  final String? person;
  final String? place;

  Notificacion({
    required this.id,
    required this.name,
    this.place,
    required this.date,
    this.description,
    required this.state,
    this.person,
  });

  // Convertir JSON a objeto Dart
  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      description: json['description'],
      state: json['state'],
      person: json['person'],
    );
  }
}
