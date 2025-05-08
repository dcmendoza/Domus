import 'package:flutter/material.dart';

class PropietarioHomeScreen extends StatelessWidget {
  const PropietarioHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio Propietario')),
      body: const Center(
        child: Text('Bienvenido Propietario'),
      ),
    );
  }
}
