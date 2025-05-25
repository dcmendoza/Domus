import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/models/reservation.dart';
import 'package:domus/screens/home/home_screen.dart';
import 'package:domus/routes.dart';

/// Pantalla de detalle de reserva.
class ReservationDetailsScreen extends StatelessWidget {
  static const routeName = Routes.reservationDetails;
  const ReservationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservation = ModalRoute.of(context)!.settings.arguments as Reservation;
    final dateFmt = DateFormat('yyyy-MM-dd');
    final hourFmt = DateFormat('HH:mm');

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row('Instalación', reservation.facilityName),
                row('Reservado por', reservation.userName),
                row('Fecha inicio', '${dateFmt.format(reservation.startDatetime)} ${hourFmt.format(reservation.startDatetime)}'),
                row('Fecha fin',    '${dateFmt.format(reservation.endDatetime)} ${hourFmt.format(reservation.endDatetime)}'),
                row('Estado', reservation.status.capitalize()),
                row('Creado', dateFmt.format(reservation.createdAt)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DomusBottomNavBar(
        role: (ModalRoute.of(context)!.settings.arguments is Map && (ModalRoute.of(context)!.settings.arguments as Map).containsKey('role'))
            ? (ModalRoute.of(context)!.settings.arguments as Map)['role']
            : 'propietario',
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}