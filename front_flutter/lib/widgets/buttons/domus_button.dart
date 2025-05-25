import 'package:flutter/material.dart';

/// Botón personalizado de Domus con texto e icono, que aprovecha
/// el tema global de la aplicación para estilos (colores, forma, paddings).
///
/// - [text]: etiqueta que se muestra.
/// - [icon]: icono a la izquierda del texto (por defecto es Icons.login).
/// - [onPressed]: callback al pulsar el botón.
class DomusButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const DomusButton({
    super.key,                    // <–– aquí estás declarando el key como parámetro de super
    required this.text,
    this.icon = Icons.login,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        // No definimos estilo inline aquí: usamos ElevatedButtonTheme en ThemeData
      ),
    );
  }
}
