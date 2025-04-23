import '../services/auth_service.dart';
import 'admin_home_screen.dart';
import 'empleado_home_screen.dart';
import 'propietario_home_screen.dart';


class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

Future<void> _login() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await AuthService.loginAdmin(email: email, password: password);

    // 🧠 Obtener perfil luego del login
    final userData = await AuthService.getProfile();

    // 🔀 Navegación según el rol del usuario
    final role = userData['role'];
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
    } else if (role == 'empleado') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmpleadoHomeScreen()),
      );
    } else if (role == 'propietario') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PropietarioHomeScreen()),
      );
    }

  } catch (e) {
    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
        title: const Text('Ingresar', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Ingresa a tu Cuenta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('¡Ingresemos!', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'lib/assets/images/admin_avatar.png',
                width: 140,
              ),
            ),
            const SizedBox(height: 30),
            const Text('Correo Electrónico', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.green),
                hintText: 'Ingresa tu correo electrónico',
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Contraseña', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                hintText: 'Ingresa tu contraseña',
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '¿Olvidaste tu Contraseña?',
                style: TextStyle(color: Colors.teal),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _login,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.login),
              label: Text(_isLoading ? 'Ingresando...' : 'Ingresa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
