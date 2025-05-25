import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/reservations/reservations_service.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import 'package:domus/screens/home/home_screen.dart';
import 'package:domus/routes.dart';

/// Pantalla para crear una nueva reserva de instalación.
class NewReservationScreen extends StatefulWidget {
  static const routeName = Routes.newReservation;
  const NewReservationScreen({super.key});

  @override
  State<NewReservationScreen> createState() => _NewReservationScreenState();
}

class _NewReservationScreenState extends State<NewReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  List<dynamic> _facilities = [];
  int? _selectedFacility;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));
  final _dateFmt = DateFormat('yyyy-MM-dd');
  final _timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final list = await ReservationsService.fetchFacilities();
      setState(() => _facilities = list);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error cargando instalaciones: \$e')));
    }
  }

  Future<void> _pickDateTime({required bool isStart, required bool pickDate}) async {
    if (pickDate) {
      final picked = await showDatePicker(
        context: context,
        initialDate: isStart ? _start : _end,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked == null) return;
      setState(() {
        if (isStart) {
          _start = DateTime(picked.year, picked.month, picked.day, _start.hour, _start.minute);
          if (!_end.isAfter(_start)) {
            _end = _start.add(const Duration(hours: 1));
          }
        } else {
          _end = DateTime(picked.year, picked.month, picked.day, _end.hour, _end.minute);
        }
      });
    } else {
      final initial = isStart
          ? TimeOfDay.fromDateTime(_start)
          : TimeOfDay.fromDateTime(_end);
      final picked = await showTimePicker(
        context: context,
        initialTime: initial,
      );
      if (picked == null) return;
      setState(() {
        if (isStart) {
          _start = DateTime(_start.year, _start.month, _start.day, picked.hour, picked.minute);
          if (!_end.isAfter(_start)) {
            _end = _start.add(const Duration(hours: 1));
          }
        } else {
          _end = DateTime(_end.year, _end.month, _end.day, picked.hour, picked.minute);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Enviar en UTC para evitar confusiones de zona horaria
      await ReservationsService.createReservation(
        facility: _selectedFacility!,
        startDatetime: _start.toUtc(),
        endDatetime: _end.toUtc(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reserva creada')));
      Navigator.pop(context, true);
    } catch (e) {
ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(content: Text('Error al crear reserva: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _facilities.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Instalación'),
                      items: _facilities
                          .map((f) => DropdownMenuItem<int>(
                                value: f['id'] as int,
                                child: Text(f['name'] as String),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedFacility = v),
                      validator: (v) => v == null ? 'Selecciona una instalación' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha Inicio'),
                      controller: TextEditingController(
                          text: _dateFmt.format(_start)),
                      onTap: () => _pickDateTime(isStart: true, pickDate: true),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora Inicio'),
                      controller: TextEditingController(
                          text: _timeFmt.format(_start)),
                      onTap: () => _pickDateTime(isStart: true, pickDate: false),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha Fin'),
                      controller:
                          TextEditingController(text: _dateFmt.format(_end)),
                      onTap: () => _pickDateTime(isStart: false, pickDate: true),
                      validator: (_) =>
                          _end.isAfter(_start) ? null : 'Fecha fin posterior al inicio',
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Hora Fin'),
                      controller:
                          TextEditingController(text: _timeFmt.format(_end)),
                      onTap: () => _pickDateTime(isStart: false, pickDate: false),
                      validator: (_) =>
                          _end.isAfter(_start) ? null : 'Hora fin posterior al inicio',
                    ),
                    const SizedBox(height: 24),
                    DomusButton(
                      text: _loading ? 'Enviando...' : 'Reservar',
                      onPressed: _loading ? () {} : _submit,
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: DomusBottomNavBar(role: 'propietario'),
    );
  }
}