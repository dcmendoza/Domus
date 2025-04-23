import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/maintenance_model.dart';
import '../screens/mantenimiento_detalle_screen.dart';

class MantenimientoCard extends StatelessWidget {
  final Maintenance mantenimiento;

  const MantenimientoCard({Key? key, required this.mantenimiento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(mantenimiento.lugar, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
        subtitle: Text("Fecha: ${mantenimiento.fecha}", style: GoogleFonts.lato(fontSize: 14)),
        trailing: Text(mantenimiento.estado, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MantenimientoDetalleScreen(mantenimiento: mantenimiento),
            ),
          );
        },
      ),
    );
  }
}
