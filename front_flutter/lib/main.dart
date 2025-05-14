import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';  // ← Import necesario para Intl
import 'routes.dart';
import 'screens/home/welcome_screen.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/signup/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/employees/home_employee_screen.dart';
import 'screens/employees/shifts_screen.dart';
import 'screens/employees/shift_details_screen.dart';
import 'screens/employees/shift_assign_screen.dart';

/// Claves globales para navegación y SnackBars desde cualquier punto.
final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  // 1️⃣ Asegurarnos de inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2️⃣ Cargar datos de formato de fecha para el locale por defecto
  //    Si solo usas español, podrías usar: initializeDateFormatting('es');
  await initializeDateFormatting();

  // 3️⃣ Arrancar la app
  runApp(const DomusApp());
}

class DomusApp extends StatelessWidget {
  const DomusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOMUS',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,

      // Rutas nombradas
      initialRoute: Routes.welcome,
      routes: {
        Routes.welcome:      (_) => const WelcomeScreen(),
        Routes.login:        (_) => const LoginScreen(),
        Routes.signup:       (_) => const RegisterScreen(),
        Routes.home:         (_) => const HomeScreen(),
        Routes.workers:      (_) => const HomeEmployeeScreen(),
        Routes.shifts:       (_) => const ShiftsScreen(),
        Routes.shiftDetails: (_) => const ShiftDetailsScreen(),
        Routes.shiftAssign: (_) => const ShiftAssignScreen(),

      },

      // Tema global
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
