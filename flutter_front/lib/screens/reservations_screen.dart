import 'package:domus/models/reserva_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/reserva_card.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> with SingleTickerProviderStateMixin {
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
        title: Text('Reservaciones', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          dividerColor: Colors.lightGreen,
          labelStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          tabs: [
            Tab(text: 'Disponibles'),
            Tab(text: 'Reservados'),
            Tab(text: 'Nueva reserva'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDisponiblesTab(),
          _buildReservadosTab(),
          _buildNuevaTab(),
        ],
      ),
    );
  }

  Widget _buildDisponiblesTab() {
    List<Reserva> reservas = [
      Reserva(id: 1, lugar: 'cancha de futbol', fecha: 'n/a', tiempo: 'n/a', estado: 'disponible', persona: 'n/a'),
      Reserva(id: 2, lugar: 'salon de juegos', fecha: 'n/a', tiempo: 'n/a', estado: 'disponible', persona: 'n/a'),
    ];

    return ListView.builder(
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        return ReservaCard(reserva: reservas[index]);
      },
    );
  }

  Widget _buildReservadosTab() {
    List<Reserva> reservas = [
      Reserva(id: 1, lugar: 'cancha de squash', fecha: '20/08/2025', tiempo: 'tarde', estado: 'reservado', persona: 'Olga'),
      Reserva(id: 2, lugar: 'salon social', fecha: '05/06/2025', tiempo: 'ma;ana', estado: 'reservado', persona: 'Norita'),
    ];

    return ListView.builder(
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        return ReservaCard(reserva: reservas[index]);
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
              labelText: "Lugar",
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
              labelText: "Tiempo",
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
