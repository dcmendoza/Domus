import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/services/leaves/leaves_service.dart';
import 'package:domus/models/leave_request.dart';
import 'package:domus/routes.dart';

/// Pantalla de detalle de una solicitud de permiso/incapacidad.
class LeaveDetailsScreen extends StatefulWidget {
  static const routeName = Routes.leaveDetails;
  const LeaveDetailsScreen({super.key});

  @override
  State<LeaveDetailsScreen> createState() => _LeaveDetailsScreenState();
}

class _LeaveDetailsScreenState extends State<LeaveDetailsScreen> {
  late LeaveRequest _leave;
  String? _role;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener la solicitud pasada como argumento
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is LeaveRequest) {
      _leave = args;
      _loadRole();
    } else {
      throw Exception('LeaveRequest no proporcionado a LeaveDetailsScreen');
    }
  }

  Future<void> _loadRole() async {
    final profile = await AuthService.getProfile();
    setState(() {
      _role = profile['role'] as String;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dateFmt = DateFormat.yMMMMd(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Solicitud'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Tipo', _leave.type == 'permiso' ? 'Permiso' : 'Incapacidad'),
            const Divider(),
            _buildRow('Estado', _leave.status),
            const Divider(),
            _buildRow('Inicio', dateFmt.format(_leave.startDate)),
            const Divider(),
            _buildRow('Fin', dateFmt.format(_leave.endDate)),
            const Divider(),
            _buildRow('Motivo', _leave.reason),
            const Divider(),
            if (_leave.documentUrl != null) ...[
              TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Ver documento'),
                onPressed: () {
                  // Abrir documento en navegador o visor integrado
                  // Podrías usar url_launcher para esto
                  // launch(_leave.documentUrl!);
                },
              ),
              const Divider(),
            ],
            const Spacer(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final isAdmin = _role == 'admin';
    final isPending = _leave.status == 'pendiente';

    List<Widget> buttons = [];

    if (isAdmin && isPending) {
      buttons.addAll([
        Expanded(
          child: ElevatedButton(
            onPressed: () => _review(true),
            child: const Text('Aprobar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _review(false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ),
      ]);
    }

    if (!isAdmin && isPending) {
      buttons.addAll([
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              Routes.leaveEdit,
              arguments: _leave,
            ),
            child: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await _delete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ),
      ]);
    }

    return Row(children: buttons);
  }

  Future<void> _review(bool approve) async {
    try {
      await LeavesService.reviewLeave(id: _leave.id, approve: approve);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Solicitud aprobada' : 'Solicitud rechazada')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')),
      );
    }
  }

  Future<void> _delete() async {
    try {
      await LeavesService.deleteLeave(_leave.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')),
      );
    }
  }
}
