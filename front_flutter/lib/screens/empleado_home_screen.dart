import 'package:flutter/material.dart';

class EmpleadoHomeScreen extends StatelessWidget {
  const EmpleadoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio Empleado')),
      body: const Center(
        child: Text('Bienvenido Empleado'),
      ),
    );
  }
}
