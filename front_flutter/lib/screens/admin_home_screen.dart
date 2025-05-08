import 'package:flutter/material.dart';
import 'create_user_screen.dart';


class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _logout(BuildContext context) {
    // Aquí luego podrías limpiar el token o usar pushAndRemoveUntil
    Navigator.pop(context); // Sale y vuelve al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, // Notificaciones
            icon: const Icon(Icons.notifications_none, color: Colors.teal),
          ),
          IconButton(
            onPressed: () {}, // Perfil (aún no implementado)
            icon: const Icon(Icons.account_circle, color: Colors.teal),
          ),
          IconButton(
            onPressed: () => _logout(context), // Cerrar sesión
            icon: const Icon(Icons.logout, color: Colors.teal),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Resumen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Bienvenido a Domus',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Actividad Semanal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            Image.asset('lib/assets/images/bar_chart.png'),
            const SizedBox(height: 30),
            const Text(
              'Estadísticas de Gastos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.asset('lib/assets/images/pie_chart.png'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 6) {
            // Cuando toca el ícono de tres puntos
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateUserScreen()),
            );
          }// Puedes agregar más navegación por index si luego lo necesitas
},

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: ''), // Finanzas
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: ''), // Mantenimientos
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: ''), // Placeholder si necesitas más
        ],
      ),
    );
  }
}
