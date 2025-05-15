import 'package:flutter/material.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import 'package:domus/routes.dart';

/// Pantalla de registro de nuevos usuarios.
/// Permite escoger rol (solo propietario o empleado), subrol si es empleado,
/// e ingresar email, nombre, apellido, teléfono y contraseña.
class RegisterScreen extends StatefulWidget {
  static const routeName = Routes.signup;
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _selectedRole;
  String? _selectedSubrole;
  bool _loading = false;
  bool _obscure = true;

  static const _roles = <String, String>{
    'propietario': 'Propietario',
    'empleado': 'Empleado',
  };
  static const _subroles = <String, String>{
    'limpieza': 'Limpieza',
    'seguridad': 'Seguridad',
    'mantenimiento': 'Mantenimiento',
  };

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.register(
        email: _emailCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        telefono: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        role: _selectedRole!,
        subRole: _selectedRole == 'empleado' ? _selectedSubrole : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada. Espera la aprobación del administrador.',
          ),
        ),
      );
      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),            // espacio alrededor de todo
          decoration: BoxDecoration(
            color: Colors.white,                        // fondo dentro del borde
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Imagen de registro
                Image.asset(
                  'lib/assets/images/register_image.png',
                  height: 200,
                  semanticLabel: 'Imagen de registro',
                ),
                const SizedBox(height: 32),

                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
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

                      // Primer Nombre
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 16),

                      // Apellido
                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresa tu apellido' : null,
                      ),
                      const SizedBox(height: 16),

                      // Teléfono
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresa tu teléfono' : null,
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility
                                : Icons.visibility_off),
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

                      // Rol
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: _roles.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedRole = v;
                          _selectedSubrole = null;
                        }),
                        validator: (v) => v == null ? 'Selecciona tu rol' : null,
                      ),
                      const SizedBox(height: 16),

                      // Sub-rol (solo empleado)
                      if (_selectedRole == 'empleado')
                        DropdownButtonFormField<String>(
                          value: _selectedSubrole,
                          decoration: const InputDecoration(
                            labelText: 'Sub-rol',
                            prefixIcon: Icon(Icons.label),
                          ),
                          items: _subroles.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSubrole = v),
                          validator: (v) =>
                              (_selectedRole == 'empleado' && v == null)
                                 ? 'Selecciona un sub-rol'
                                 : null,
                        ),
                      const SizedBox(height: 32),

                      // Botón enviar
                      DomusButton(
                        text: _loading? 'Enviando...':'Enviar Solicitud',
                        onPressed: _loading ? () {} : _submit,
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
