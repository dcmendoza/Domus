import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:domus/services/leaves/leaves_service.dart';
import 'package:domus/routes.dart';
// for possible file path handling

/// Pantalla para crear una nueva solicitud de permiso/incapacidad.
class LeaveRequestScreen extends StatefulWidget {
  static const routeName = Routes.leaveRequest;
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Campos del formulario
  String? _type;
  DateTime _startDate = DateTime.now();
  DateTime _endDate   = DateTime.now();
  final _reasonCtrl   = TextEditingController();
  PlatformFile? _pickedFile;

  // Formatos reutilizables
  final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
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

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un documento.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await LeavesService.createLeave(
        type: _type!,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonCtrl.text.trim(),
        filePath: _pickedFile!.path!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada exitosamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      // Muestra en consola el mensaje exacto que viene del servidor
      print('ERROR creando leave: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
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
                // Tipo
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.event_note),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'permiso', child: Text('Permiso')),
                    DropdownMenuItem(value: 'incapacidad', child: Text('Incapacidad')),
                  ],
                  onChanged: (v) => setState(() => _type = v),
                  validator: (v) => v == null ? 'Selecciona un tipo' : null,
                ),
                const SizedBox(height: 16),

                // Fecha inicio
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha Inicio',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: _dateFmt.format(_startDate)),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) => _startDate == null ? 'Elige la fecha' : null,
                ),
                const SizedBox(height: 16),

                // Fecha fin
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha Fin',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(text: _dateFmt.format(_endDate)),
                  onTap: () => _pickDate(isStart: false),
                  validator: (_) => _endDate == null ? 'Elige la fecha' : null,
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
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa un motivo' : null,
                ),
                const SizedBox(height: 16),

                // Documento
                OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: Text(_pickedFile == null
                      ? 'Seleccionar documento'
                      : _pickedFile!.name),
                  onPressed: _pickDocument,
                ),
                const SizedBox(height: 24),

                // Botón enviar
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? 'Enviando...' : 'Enviar Solicitud'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
