import 'package:flutter/material.dart';
import '../models/tarea_model.dart';
import 'package:google_fonts/google_fonts.dart';

class TareaDetalleScreen extends StatelessWidget {
  final Tarea tarea;

  TareaDetalleScreen({required this.tarea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de la tarea',
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
              Text("Lugar: ${tarea.nombre}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Fecha: ${tarea.fecha}", style: TextStyle(fontSize: 15)),
              Text("Tipo: ${tarea.lugar}", style: TextStyle(fontSize: 15)),
              Text("Estado: ${tarea.estado}", style: TextStyle(fontSize: 15)),
              Text("Persona: ${tarea.persona}", style: TextStyle(fontSize: 15)),              
            ],
          ),
        ),
      ),
    );
  }
}
