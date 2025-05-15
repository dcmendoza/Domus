/// Modelo Dart para mapear reservas de instalaciones
class Reservation {
  final int id;
  final int facilityId;
  final String facilityName;
  final int userId;
  final String userName;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status; // 'pendiente', 'aprobada', 'rechazada'
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.userId,
    required this.userName,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      facilityId: json['facility'] as int,
      facilityName: json['facility_name'] as String,
      userId: json['user'] as int,
      userName: json['user_name'] as String,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: DateTime.parse(json['end_datetime'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facility': facilityId,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
    };
  }
}
