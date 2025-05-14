import 'package:flutter/material.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import 'package:domus/routes.dart';
import '../home/home_screen.dart'; // para poder usar DomusBottomNavBar

/// Pantalla “Empleados”: ofrece dos opciones según rol:
/// - Horarios de trabajo
/// - Permisos e Incapacidades
class HomeEmployeeScreen extends StatefulWidget {
  static const routeName = Routes.workers;
  const HomeEmployeeScreen({super.key});

  @override
  State<HomeEmployeeScreen> createState() => _HomeEmployeeScreenState();
}

class _HomeEmployeeScreenState extends State<HomeEmployeeScreen> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (!mounted) return;
      setState(() {
        _role = profile['role'] as String?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error cargando perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin   = _role == 'admin';
    final isEmpleado= _role == 'empleado';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Empleados',
          style: TextStyle(color: Colors.green),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
        foregroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications),
            onPressed: () =>
                Navigator.pushNamed(context, Routes.notifications),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(
                  context, Routes.welcome);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen ilustrativa
              Image.asset(
                'lib/assets/images/employees_image.png',
                height: 300,
                semanticLabel: 'Ilustración Empleados',
              ),
              const SizedBox(height: 40),

              // Botón “Horarios de Trabajo”
              DomusButton(
                text: 'Horarios de Trabajo',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.shifts);
                },
              ),
              const SizedBox(height: 16),

              // Botón “Permisos e Incapacidades”
              DomusButton(
                text: 'Permisos e Incapacidades',
                onPressed: () {
                  Navigator.pushNamed(context, Routes.leaves);
                },
              ),
            ],
          ),
        ),
      ),

      // reutilizamos la barra inferior de HomeScreen
      bottomNavigationBar:
          DomusBottomNavBar(role: _role ?? 'empleado'),
    );
  }
}
