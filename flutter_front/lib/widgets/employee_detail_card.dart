import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/employee_model.dart';

class EmployeeDetailCard extends StatelessWidget {
  final Employee employee;

  EmployeeDetailCard({required this.employee});

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
                "Detalle del Empleado",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              Divider(color: Colors.grey[300]),
              _buildInfoRow(Icons.person, "Nombre", employee.name),
              _buildInfoRow(Icons.badge, "Rol", employee.role),
              _buildInfoRow(
                  Icons.numbers, "ID empleado", employee.id.toString()),
              _buildInfoRow(
                  Icons.numbers, "ID usuario", employee.userId.toString()),
              if (employee.phone != null)
                _buildInfoRow(Icons.phone, "Teléfono", employee.phone!),
              if (employee.email != null)
                _buildInfoRow(Icons.email, "Email", employee.email!),
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
}
