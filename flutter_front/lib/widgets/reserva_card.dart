import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reserva_model.dart';
import '../screens/reserva_detalle_screen.dart';

class ReservaCard extends StatelessWidget {
  final Reserva reserva;

  const ReservaCard({Key? key, required this.reserva}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(reserva.lugar, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Text("Fecha: ${reserva.fecha}", style: GoogleFonts.lato(fontSize: 14)),
        trailing: Text(reserva.estado, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservaDetalleScreen(reserva: reserva),
            ),
          );
        },
      ),
    );
  }
}
