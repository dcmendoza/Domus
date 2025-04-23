import 'package:domus/models/tarea_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TareaCard extends StatelessWidget {
  final Tarea tarea;

  TareaCard({required this.tarea});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tarea.nombre,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              Divider(color: Colors.grey[300]),

              _buildInfoRow(Icons.person, "Trabajador", tarea.persona),
              _buildInfoRow(Icons.calendar_month, "Fecha", tarea.fecha),
              _buildInfoRow(Icons.pin_drop, "Lugar", tarea.lugar),
              _buildInfoRow(Icons.timer, "estado", tarea.estado),

              SizedBox(height: 15),

              // Botones de Aceptar y Rechazar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    icon: Icons.check,
                    label: "Aceptar",
                    color: Colors.green,
                    onPressed: () {
                      // Lógica para aceptar la excusa
                      print("Excusa aceptada");
                    },
                  ),
                  _buildButton(
                    icon: Icons.close,
                    label: "Rechazar",
                    color: Colors.red,
                    onPressed: () {
                      // Lógica para rechazar la excusa
                      print("Excusa rechazada");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 20),
          SizedBox(width: 10),
          Text(
            "$label:",
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      onPressed: onPressed,
    );
  }
}
