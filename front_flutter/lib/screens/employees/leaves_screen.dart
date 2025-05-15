import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/services/leaves/leaves_service.dart';
import 'package:domus/models/leave_request.dart';
import 'package:domus/routes.dart';

/// Pantalla de listado de Permisos e Incapacidades
class LeavesScreen extends StatefulWidget {
  static const routeName = Routes.leaves;
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  String? _role;
  Future<List<LeaveRequest>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<List<LeaveRequest>> _loadData() async {
    final profile = await AuthService.getProfile();
    _role = profile['role'] as String;
    return await LeavesService.fetchLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos e Incapacidades'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LeaveRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          final leaves = snapshot.data!;
          if (leaves.isEmpty) {
            final msg = _role == 'admin'
                ? 'No hay solicitudes de permisos/incapacidades.'
                : 'Aún no has realizado solicitudes.';
            return Center(child: Text(msg));
          }

          return ListView.builder(
            itemCount: leaves.length,
            itemBuilder: (ctx, i) {
              final l = leaves[i];
              final dateFmt = DateFormat('yyyy-MM-dd');
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    '${l.type == 'permiso' ? 'Permiso' : 'Incapacidad'} - \${l.status}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${dateFmt.format(l.startDate)} → ${dateFmt.format(l.endDate)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_role == 'admin') ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _review(l.id, true),
                          tooltip: 'Aprobar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _review(l.id, false),
                          tooltip: 'Rechazar',
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.leaveDetails,
                          arguments: l,
                        ),
                        tooltip: 'Detalles',
                      ),
                      if (_role != 'admin' && l.status == 'pendiente') ...[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Routes.leaveEdit,
                            arguments: l,
                          ),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () => _delete(l.id),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (_role != 'admin')
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                context,
                Routes.leaveRequest,
              ),
              tooltip: 'Nuevo permiso/incapacidad',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _review(int id, bool approve) async {
    try {
      await LeavesService.reviewLeave(id: id, approve: approve);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'Solicitud aprobada' : 'Solicitud rechazada')),
      );
      setState(() {
        _future = LeavesService.fetchLeaves();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')), 
      );
    }
  }

  Future<void> _delete(int id) async {
    try {
      await LeavesService.deleteLeave(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada')),
      );
      setState(() {
        _future = LeavesService.fetchLeaves();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \$e')), 
      );
    }
  }
}
