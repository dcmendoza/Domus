import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/leaves/leaves_service.dart';
import 'package:domus/models/leave_request.dart';
import 'package:domus/routes.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla para editar una solicitud de permiso/incapacidad pendiente.
class LeaveEditScreen extends StatefulWidget {
  static const routeName = Routes.leaveEdit;
  const LeaveEditScreen({super.key});

  @override
  State<LeaveEditScreen> createState() => _LeaveEditScreenState();
}

class _LeaveEditScreenState extends State<LeaveEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late LeaveRequest _leave;
  String? _type;
  late DateTime _startDate;
  late DateTime _endDate;
  final _reasonCtrl = TextEditingController();

  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is LeaveRequest) {
      _leave = args;
      _type = _leave.type;
      _startDate = _leave.startDate;
      _endDate = _leave.endDate;
      _reasonCtrl.text = _leave.reason;
    } else {
      throw Exception('LeaveRequest no proporcionado para edición');
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await LeavesService.updateLeave(
        id: _leave.id,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud actualizada exitosamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: \$e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Solicitud'),
        content: const Text('¿Estás seguro de eliminar esta solicitud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await LeavesService.deleteLeave(_leave.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada exitosamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Solicitud'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tipo (solo lectura)
                TextFormField(
                  initialValue: _type == 'permiso' ? 'Permiso' : 'Incapacidad',
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.event_note),
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha Inicio
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha Inicio',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: _dateFmt.format(_startDate)),
                  onTap: () => _pickDate(isStart: true),
                ),
                const SizedBox(height: 16),

                // Fecha Fin
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha Fin',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: _dateFmt.format(_endDate)),
                  onTap: () => _pickDate(isStart: false),
                ),
                const SizedBox(height: 16),

                // Motivo
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Ingresa un motivo'
                      : null,
                ),
                const SizedBox(height: 16),

                // Documento existente
                if (_leave.documentUrl != null) ...[
                  Linkify(
                    onOpen: (link) async => await launchUrl(Uri.parse(link.url)),
                    text: 'Documento actual',
                    linkStyle: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botones de acción: actualizar y eliminar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: Text(_loading ? 'Actualizando...' : 'Actualizar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _delete,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Eliminar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
