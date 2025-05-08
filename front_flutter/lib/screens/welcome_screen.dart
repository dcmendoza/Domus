import 'package:flutter/material.dart';
import 'admin_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DOMUS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'lib/assets/images/domus_logo.png', 
                  height: 180,
                ),
                const SizedBox(height: 40),
                _buildLoginButton(
                  context,
                  'Ingresa como Administrador',
                  const AdminLoginScreen(),
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  context,
                  'Ingresa como Empleado',
                  null, // puedes cambiar esto más adelante
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  context,
                  'Ingresa como Propietario',
                  null, // puedes cambiar esto más adelante
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, String text, Widget? screen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: screen != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              }
            : null,
        icon: const Icon(Icons.login),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
