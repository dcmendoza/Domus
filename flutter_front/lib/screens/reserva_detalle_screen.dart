import 'package:flutter/material.dart';
import '../models/reserva_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservaDetalleScreen extends StatelessWidget {
  final Reserva reserva;

  ReservaDetalleScreen({required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de la reserva',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lugar: ${reserva.lugar}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Fecha: ${reserva.fecha}", style: TextStyle(fontSize: 15)),
              Text("Tipo: ${reserva.tiempo}", style: TextStyle(fontSize: 15)),
              Text("Estado: ${reserva.estado}", style: TextStyle(fontSize: 15)),
              Text("Persona: ${reserva.persona}", style: TextStyle(fontSize: 15)),              
            ],
          ),
        ),
      ),
    );
  }
}
