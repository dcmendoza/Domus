import 'package:flutter/material.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import '../../../services/auth/auth_service.dart';
import '../../../routes.dart';

/// Pantalla de login unificado para todos los roles.
class LoginScreen extends StatefulWidget {
  /// Ruta nombrada de la pantalla de login.
  static const routeName = Routes.login;
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validación básica del formulario
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1) Autenticar y guardar token
      await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      // 2) Recuperar perfil (incluye el campo 'role')
      final profile = await AuthService.getProfile();
      if (!mounted) return;

      final role = profile['role'] as String;

      // 3) Navegar a Home pasando el rol
      Navigator.pushReplacementNamed(
        context,
        Routes.home,
        arguments: {'role': role},
      );
    } catch (e) {
      if (!mounted) return;
      final msg = (e is Exception)
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Error inesperado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),           // espacio alrededor de todo
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/images/login_image.png',
                  height: 200,
                  semanticLabel: 'Imagen de login',
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu correo';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      DomusButton(
                        text: _loading ? 'Ingresando...' : 'Entrar',
                        // Si está cargando, pasa un callback vacío; 
                        // si no, llama a _submit()
                        onPressed: _loading ? () {} : () => _submit(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}