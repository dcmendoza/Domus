class Maintenance {
  final int id;
  final String lugar;
  final String fecha;
  final String tipo;
  final String estado;
  final double? costo;
  final String? descripcion;
  final String? encargado;

  Maintenance({
    required this.id,
    required this.lugar,
    required this.fecha,
    required this.tipo,
    required this.estado,
    this.costo,
    this.descripcion,
    this.encargado,
  });

  // Convertir JSON a objeto Dart
  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'],
      lugar: json['lugar'],
      fecha: json['fecha'],
      tipo: json['tipo'],
      estado: json['estado'],
      costo: json['costo'],
      descripcion: json['descripcion'],
      encargado: json['encargado'],
    );
  }
}
