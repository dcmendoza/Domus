import 'package:domus/models/maintenance_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/mantenimiento_card.dart';

class MaintenanceScreen extends StatefulWidget {
  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimientos', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          dividerColor: Colors.lightGreen,
          labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          tabs: [
            Tab(text: 'Programados'),
            Tab(text: 'Historial'),
            Tab(text: 'Nuevo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgramadosTab(),
          _buildHistorialTab(),
          _buildNuevoTab(),
        ],
      ),
    );
  }

  Widget _buildProgramadosTab() {
    List<Maintenance> mantenimientos = [
      Maintenance(id: 1, lugar: "Ascensor", fecha: "2025-03-15", tipo: "ventilacion", estado: "Pendiente"),
      Maintenance(id: 2, lugar: "Parqueadero", fecha: "2025-03-20", tipo: "Iluminación", estado: "En proceso"),
      Maintenance(id: 3, lugar: "Porteria", fecha: "2025-03-25", tipo: "Tuberías", estado: "Completado"),
    ];

    return ListView.builder(
      itemCount: mantenimientos.length,
      itemBuilder: (context, index) {
        return MantenimientoCard(mantenimiento: mantenimientos[index]);
      },
    );
  }

  Widget _buildHistorialTab() {
    List<Maintenance> historial = [
      Maintenance(id: 1, lugar: "Piscina", fecha: "2025-03-15", tipo: "rutina", estado: "Pendiente"),
      Maintenance(id: 2, lugar: "Cancha", fecha: "2025-03-20", tipo: "Iluminación", estado: "En proceso"),
      Maintenance(id: 3, lugar: "Entrada", fecha: "2025-03-25", tipo: "Tuberías", estado: "Completado"),
    ];

    return ListView.builder(
      itemCount: historial.length,
      itemBuilder: (context, index) {
        return MantenimientoCard(mantenimiento: historial[index]);
      },
    );
  }


  Widget _buildNuevoTab() {
    TextEditingController _tipoController = TextEditingController();
    TextEditingController _fechaController = TextEditingController();
    TextEditingController _descripcionController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _tipoController,
            decoration: InputDecoration(
              labelText: "Tipo de mantenimiento",
              labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ).animate().fade(duration: 500.ms),
          SizedBox(height: 12),
          TextField(
            controller: _fechaController,
            decoration: InputDecoration(
              labelText: "Fecha programada",
              labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ).animate().fade(duration: 500.ms, delay: 100.ms),
          SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: "Descripción",
              labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            maxLines: 3,
          ).animate().fade(duration: 500.ms, delay: 200.ms),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print("Nuevo mantenimiento: ${_tipoController.text}");
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("Registrar Mantenimiento", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600)),
          ).animate().fade(duration: 500.ms, delay: 300.ms),
        ],
      ),
    );
  }
}
