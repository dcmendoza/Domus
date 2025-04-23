import 'package:flutter/material.dart';
import '../models/maintenance_model.dart';
import 'package:google_fonts/google_fonts.dart';

class MantenimientoDetalleScreen extends StatelessWidget {
  final Maintenance mantenimiento;

  MantenimientoDetalleScreen({required this.mantenimiento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Domus - Administración - Detalles del mantenimiento',
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
              Text("Lugar: ${mantenimiento.lugar}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Fecha: ${mantenimiento.fecha}", style: TextStyle(fontSize: 15)),
              Text("Tipo: ${mantenimiento.tipo}", style: TextStyle(fontSize: 15)),
              Text("Estado: ${mantenimiento.estado}", style: TextStyle(fontSize: 15)),
              if (mantenimiento.costo != null) Text("Costo: \$${mantenimiento.costo}", style: TextStyle(fontSize: 15)),
              if (mantenimiento.descripcion != null) Text("Descripción: ${mantenimiento.descripcion}", style: TextStyle(fontSize: 15)),
              if (mantenimiento.encargado != null) Text("Encargado: ${mantenimiento.encargado}", style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
