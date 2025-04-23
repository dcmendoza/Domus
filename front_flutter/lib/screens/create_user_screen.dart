import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String nombre = '';
  String telefono = '';
  String password = '';
  String rol = 'admin';
  String? subrol;

  bool _isLoading = false;
  String? _error;

  final subroles = ['limpieza', 'seguridad', 'mantenimiento'];

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await AuthService.getToken();
    final url = Uri.parse('$apiBaseUrl/api/users/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'username': email.split('@')[0],
          'nombre_completo': nombre,
          'telefono': telefono,
          'role': rol,
          'subrole': rol == 'empleado' ? subrol : null,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado con éxito')),
        );
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        setState(() {
          _error = data.toString();
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: Colors.teal)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle, color: Colors.teal)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Correo Electrónico'),
              _buildInputField(
                hintText: 'correo@domus.com',
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val!,
                validator: _required,
              ),
              _buildLabel('Nombre Completo'),
              _buildInputField(
                hintText: 'Nombre del usuario',
                onSaved: (val) => nombre = val!,
                validator: _required,
              ),
              _buildLabel('Teléfono'),
              _buildInputField(
                hintText: 'Ej: 3001234567',
                keyboardType: TextInputType.phone,
                onSaved: (val) => telefono = val!,
                validator: _required,
              ),
              _buildLabel('Contraseña Temporal'),
              _buildInputField(
                hintText: 'Contraseña',
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: _required,
              ),
              const SizedBox(height: 10),
              _buildLabel('Rol'),
              DropdownButtonFormField<String>(
                value: rol,
                onChanged: (val) => setState(() => rol = val!),
                decoration: _dropdownStyle,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                  DropdownMenuItem(value: 'propietario', child: Text('Propietario')),
                ],
              ),
              if (rol == 'empleado') ...[
                _buildLabel('Subrol (solo empleados)'),
                DropdownButtonFormField<String>(
                  value: subrol,
                  onChanged: (val) => setState(() => subrol = val!),
                  validator: (val) => val == null ? 'Selecciona un subrol' : null,
                  decoration: _dropdownStyle,
                  items: subroles
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _crearUsuario,
                icon: const Icon(Icons.person_add),
                label: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Crear Usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _buildInputField({
  required String hintText,
  TextInputType? keyboardType,
  bool obscureText = false,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
}) {
  return TextFormField(
    onSaved: onSaved,
    validator: validator,
    keyboardType: keyboardType,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

InputDecoration _dropdownStyle = const InputDecoration(
  filled: true,
  fillColor: Color(0xFFF0F0F0),
  border: InputBorder.none,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
);

String? _required(String? val) {
  return (val == null || val.trim().isEmpty) ? 'Campo obligatorio' : null;
}
