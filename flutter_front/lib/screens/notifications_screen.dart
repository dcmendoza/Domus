import 'package:domus/models/notification_model.dart';
import 'package:domus/widgets/bottom_navigation_bar.dart';
import 'package:domus/widgets/notificacion_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
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
        title: Text('Notificationes',
            style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          dividerColor: Colors.lightGreen,
          labelStyle: GoogleFonts.lato(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          tabs: [
            Tab(text: 'Todas'),
            Tab(text: 'Nuevas'),
            Tab(text: 'Leidas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodasTab(),
          _buildNuevasTab(),
          _buildLeidasTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarCard(currentIndex: 1),
    );
  }

  Widget _buildTodasTab() {
    List<Notificacion> notificaciones = [
      Notificacion(
          id: 1,
          name: "Tarea Completada",
          date: "26/02/2025",
          state: "completada"),
    ];

    return ListView.builder(
      itemCount: notificaciones.length,
      itemBuilder: (context, index) {
        return NotificacionCard(notificacion: notificaciones[index]);
      },
    );
  }

  Widget _buildNuevasTab() {
    List<Notificacion> notificaciones = [
      Notificacion(
          id: 1,
          name: "Tarea Completada",
          date: "26/02/2025",
          state: "completada"),
    ];

    return ListView.builder(
      itemCount: notificaciones.length,
      itemBuilder: (context, index) {
        return NotificacionCard(notificacion: notificaciones[index]);
      },
    );
  }

  Widget _buildLeidasTab() {
    List<Notificacion> notificaciones = [
      Notificacion(
          id: 1,
          name: "Tarea Completada",
          date: "26/02/2025",
          state: "completada"),
    ];

    return ListView.builder(
      itemCount: notificaciones.length,
      itemBuilder: (context, index) {
        return NotificacionCard(notificacion: notificaciones[index]);
      },
    );
  }
}
