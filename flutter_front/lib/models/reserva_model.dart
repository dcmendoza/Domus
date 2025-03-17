class Reserva {
  final int id;
  final String lugar;
  final String fecha;
  final String tiempo;
  final String estado;
  final String persona;

  Reserva({
    required this.id,
    required this.lugar,
    required this.fecha,
    required this.tiempo,
    required this.estado,
    required this.persona,
  });

  // Convertir JSON a objeto Dart
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      lugar: json['lugar'],
      fecha: json['fecha'],
      tiempo: json['tiempo'],
      estado: json['estado'],
      persona: json['persona'],
    );
  }
}