import 'package:flutter/material.dart';
import 'package:domus/routes.dart';
import 'package:domus/services/auth/auth_service.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = Routes.home;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Arranca la petición del perfil tan pronto como se crea el widget.
    _profileFuture = AuthService.getProfile();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bienvenido, que tengas un feliz día';
    if (hour < 18) return 'Bienvenido, que tengas una feliz tarde';
    return 'Bienvenido, que tengas una feliz noche';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Mientras carga el perfil, mostramos un splash / loader sencillo
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          // Error al cargar perfil: forzamos volver al login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, Routes.welcome);
          });
          return const SizedBox.shrink();
        }

        final profile = snapshot.data!;
        final role = profile['role'] as String;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'DOMUS',
              style: TextStyle(color: Colors.green),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _greeting(),
                  style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.indigo),
                ),
              ),
            ),
            actions: [
                IconButton(
                tooltip: 'Notificaciones',
                icon: const Icon(Icons.notifications, color: Colors.green),
                onPressed: () {
                  Navigator.pushNamed(
                  context,
                  Routes.notifications,
                  arguments: {'role': role},
                  );
                },
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout, color: Colors.green),
                onPressed: () async {
                  await AuthService.logout();
                  if (!mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context, Routes.welcome, (_) => false
                    );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BannerImage(),
                const SizedBox(height: 24),
                if (role == CustomRoles.admin) const _AdminSection(),
                if (role == CustomRoles.propietario) const _PropietarioSection(),
                if (role == CustomRoles.empleado) const _EmpleadoSection(),
              ],
            ),
          ),
          bottomNavigationBar: DomusBottomNavBar(role: role),
        );
      },
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage();
  static const _asset = 'lib/assets/images/banner_image.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      fit: BoxFit.cover,
      height: 90,
      semanticLabel: 'Banner de Domus',
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finanzas Generales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        // TODO: reemplazar por ChartService y FutureBuilder
        Image.asset(
          'lib/assets/images/pie_chart_image.png',
          height: 300,
          fit: BoxFit.fill,
          semanticLabel: 'Gráfico de finanzas generales',
        ),
        const SizedBox(height: 24),
        const Text('Actividad Semanal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Image.asset(
          'lib/assets/images/bar_chart_image.png',
          height: 300,
          fit: BoxFit.fill,
          semanticLabel: 'Gráfico de actividad semanal',
        ),
      ],
    );
  }
}

class _PropietarioSection extends StatelessWidget {
  const _PropietarioSection();

  static const _aptAsset = 'lib/assets/images/apartment_image.png';
  static const _chartAsset = 'lib/assets/images/pie_chart_image.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tu Apartamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Image.asset(_aptAsset, height: 300, width: 550, fit: BoxFit.fill),
        const SizedBox(height: 24),
        const Text('Finanzas de tu Apartamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Image.asset(_chartAsset, height: 300, fit: BoxFit.fill),
        // TODO: reemplazar por FutureBuilder que llame a ApartmentService
      ],
    );
  }
}

class _EmpleadoSection extends StatelessWidget {
  const _EmpleadoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actividades Pendientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        Container(
          child: Image.asset(
            'lib/assets/images/checklist_image.png',
            height: 400,
            fit: BoxFit.contain,
            semanticLabel: 'Imagen de actividades pendientes',
          ),
        ),
      ],
    );
  }
}

class DomusBottomNavBar extends StatelessWidget {
  final String role;
  const DomusBottomNavBar({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;

    Widget icon(IconData icon, String route, bool visible) {
      if (!visible) return const SizedBox.shrink();
      final active = current == route;
      return IconButton(
        icon: Icon(icon,
            color: active
                ? Colors.green
                : Colors.indigo),
        onPressed: active
            ? null
            : () => Navigator.pushReplacementNamed(
                  context,
                  route,
                  arguments: {'role': role},
                ),
      );
    }

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon(Icons.home, Routes.home, true),
          icon(Icons.pie_chart, Routes.finance, true),
          icon(Icons.group, Routes.workers,
              role == CustomRoles.admin || role == CustomRoles.empleado),
          icon(Icons.calendar_today, Routes.reserves, true),
          icon(Icons.chat, Routes.chat, true),
          icon(Icons.person, Routes.profile, true),
        ],
      ),
    );
  }
}

/// Para no tener strings “mágicos” en tu UI, mejor centraliza los roles:
// lo defines en utils/constants.dart o models de tu app
abstract class CustomRoles {
  static const admin = 'admin';
  static const propietario = 'propietario';
  static const empleado = 'empleado';
}
