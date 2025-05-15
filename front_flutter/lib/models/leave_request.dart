/// Modelo Dart para mapear solicitudes de permisos e incapacidades
class LeaveRequest {
  final int id;
  final String type;        // 'permiso' o 'incapacidad'
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? documentUrl; // URL al archivo subido
  final String status;      // 'pendiente', 'aprobada', 'rechazada'
  final String? reviewedBy; // ID del revisor, si existe, como texto
  final DateTime createdAt;
  final DateTime? reviewedAt;

  LeaveRequest({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.documentUrl,
    required this.status,
    this.reviewedBy,
    required this.createdAt,
    this.reviewedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as int,
      type: json['type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String,
      documentUrl: json['document'] != null && json['document'] is String && (json['document'] as String).isNotEmpty
          ? json['document'] as String
          : null,
      status: json['status'] as String,
      reviewedBy: json['reviewed_by']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      'reason': reason,
      // document se envía como parte de multipart/form-data
    };
  }
}
