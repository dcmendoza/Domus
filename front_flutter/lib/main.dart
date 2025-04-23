import 'package:domus/screens/employee_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/personnel_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(DomusApp());
}

class DomusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Domus',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/personnel': (context) => PersonnelScreen(),
        '/finances': (context) => FinanceScreen(),
        '/reservations': (context) => ReservationsScreen(),
        '/mantenimientos': (context) => MaintenanceScreen(),
        '/profile': (context) => ProfileScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/employee': (context) => EmployeeScreen(),
      },
    );
  }
}
