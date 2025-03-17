class Tarea {
  final int id;
  final String nombre;
  final String fecha;
  final String lugar;
  final String estado;
  final String persona;

  Tarea({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.estado,
    required this.persona,
  });

  // Convertir JSON a objeto Dart
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      lugar: json['lugar'],
      fecha: json['fecha'],
      nombre: json['nombre'],
      estado: json['estado'],
      persona: json['persona'],
    );
  }
}