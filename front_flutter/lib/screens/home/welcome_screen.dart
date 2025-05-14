import 'package:flutter/material.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import '../../routes.dart';

/// Pantalla de bienvenida de la aplicación Domus.
/// Permite ir a Login o Registro.
class WelcomeScreen extends StatelessWidget {
  /// Ruta nombrada de esta pantalla.
  static const routeName = Routes.welcome;

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),            // espacio alrededor de todo
          decoration: BoxDecoration(
            color: Colors.white,                        // fondo dentro del borde
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DOMUS',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const LogoImage(),
                  const SizedBox(height: 40),
                  const AuthButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para la imagen del logo de Domus.
class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  static const _assetPath = 'lib/assets/images/domus_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: 180,
      semanticLabel: 'Logo de Domus',
    );
  }
}

/// Botones de acceso: Login y Registro.
class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DomusButton(
          text: 'Iniciar Sesión',
          onPressed: () => Navigator.pushNamed(context, Routes.login),
        ),
        const SizedBox(height: 12),
        DomusButton(
          text: 'Registrarse',
          onPressed: () => Navigator.pushNamed(context, Routes.signup),
        ),
      ],
    );
  }
}
