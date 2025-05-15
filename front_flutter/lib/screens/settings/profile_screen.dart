import 'package:flutter/material.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/screens/home/home_screen.dart';
import 'package:domus/routes.dart';

/// Pantalla de perfil de usuario.
class ProfileScreen extends StatefulWidget {
  static const routeName = Routes.profile;
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = AuthService.getProfile();
  }

  Widget infoTile(String title, String subtitle, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(child: Text('Error al cargar perfil')),
          );
        }

        final p = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Mi Perfil')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('lib/assets/images/avatar_image.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  '${p['first_name']} ${p['last_name']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(p['email'], style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                infoTile('Teléfono', p['telefono'], Icons.phone),
                infoTile('Rol', p['role'], Icons.work),
                if (p['subrole'] != null && p['subrole'] != '')
                  infoTile('Sub-rol', p['subrole'], Icons.label),
                infoTile('Estado registro', p['registration_status'], Icons.check_circle),
              ],
            ),
          ),
          bottomNavigationBar: DomusBottomNavBar(role: p['role']),
        );
      },
    );
  }
}