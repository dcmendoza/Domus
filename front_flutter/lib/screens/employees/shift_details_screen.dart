import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../routes.dart';

/// Pantalla de detalle de un turno de trabajo.
/// Recibe por arguments un Map<String, dynamic> con los datos del turno,
/// incluyendo los campos opcionales employee_name, tower_name y facility_name.
class ShiftDetailsScreen extends StatelessWidget {
  static const routeName = Routes.shiftDetails;

  const ShiftDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1) Recuperamos el turno que nos pasó el Navigator:
    final shift =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // 2) Parseamos fechas (suponiendo ISO 8601 en el JSON):
    final start = DateTime.parse(shift['start_datetime'] as String);
    final end   = DateTime.parse(shift['end_datetime'] as String);

    // 3) Intentamos leer nombres amigables, si no existen, caemos a los IDs:
    final employeeDisplay = shift['employee_name'] ??
        'ID ${shift['employee'].toString()}';
    final area            = shift['area'] as String;
    final dateDisplay     = DateFormat.yMMMMd(
      Localizations.localeOf(context).languageCode,
    ).format(start);
    final startTime       = DateFormat.Hm().format(start);
    final endTime         = DateFormat.Hm().format(end);
    final towerDisplay    = shift['tower_name'] ??
        (shift['tower'] != null ? 'ID ${shift['tower']}' : '—');
    final facilityDisplay = shift['facility_name'] ??
        (shift['facility'] != null ? 'ID ${shift['facility']}' : '—');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Turno'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Empleado', employeeDisplay),
            const Divider(),
            _buildRow('Área', area),
            const Divider(),
            _buildRow('Fecha', dateDisplay),
            const Divider(),
            _buildRow('Hora de Inicio', startTime),
            const Divider(),
            _buildRow('Hora de Fin', endTime),
            const Divider(),
            // Solo mostramos Torre si existe
            if (shift['tower'] != null)
              ...[
                _buildRow('Torre', towerDisplay),
                const Divider(),
              ],
            // Solo mostramos Instalación si existe
            if (shift['facility'] != null)
              ...[
                _buildRow('Instalación', facilityDisplay),
                const Divider(),
              ],
          ],
        ),
      ),
    );
  }

  /// Fila genérica con etiqueta en negrita y valor a la derecha.
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
