import 'package:domus/models/tarea_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/tarea_card.dart';

class PersonnelScreen extends StatefulWidget {
  @override
  _PersonnelScreenState createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> with SingleTickerProviderStateMixin {
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
        title: Text('Personal', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          dividerColor: Colors.lightGreen,
          labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          tabs: [
            Tab(text: 'Tareas Aignadas'),
            Tab(text: 'Nueva asignacion'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAsignadasTab(),
          _buildNuevaTab(),
        ],
      ),
    );
  }

  Widget _buildAsignadasTab() {
    List<Tarea> tareas = [
      Tarea(id: 1, nombre: 'Barrer entrada', fecha: '12/03/2025', lugar: 'Porteria', estado: 'pendiente', persona: 'Lolita')
    ];

    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        return TareaCard(tarea: tareas[index]);
      },
    );
  }

  Widget _buildNuevaTab() {
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
              labelText: "Nombre",
              labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ).animate().fade(duration: 500.ms),
          SizedBox(height: 12),
          TextField(
            controller: _fechaController,
            decoration: InputDecoration(
              labelText: "Fecha ",
              labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ).animate().fade(duration: 500.ms, delay: 100.ms),
          SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: "Lugar",
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
