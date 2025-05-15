import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/routes.dart';
import 'package:domus/widgets/buttons/domus_button.dart';
import 'package:domus/services/shifts/shifts_service.dart';

/// Pantalla para que el administrador asigne un turno a un empleado.
class ShiftAssignScreen extends StatefulWidget {
  static const routeName = Routes.shiftAssign;
  final DateTime? initialDate;

  const ShiftAssignScreen({super.key, this.initialDate});

  @override
  State<ShiftAssignScreen> createState() => _ShiftAssignScreenState();
}

class _ShiftAssignScreenState extends State<ShiftAssignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Controladores para mantener el texto de fecha y hora
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();

  // Datos del dropdown
  List<dynamic> _employees = [];
  List<dynamic> _towers = [];
  List<dynamic> _facilities = [];

  // Valores del formulario
  int? _selectedEmployeeId;
  String? _selectedArea;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int? _selectedTowerId;
  int? _selectedFacilityId;

  static const _areas = <String, String>{
    'aseo': 'Aseo',
    'seguridad': 'Seguridad',
  };

  // Formatos reutilizables
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    // Si vino una fecha inicial por argumento, la usamos
    if (widget.initialDate != null) {
      _startDate = widget.initialDate!;
      _endDate = widget.initialDate!;
    }
    // Inicializamos los controladores con los valores por defecto
    _startDateCtrl.text = _dateFormat.format(_startDate);
    _endDateCtrl.text   = _dateFormat.format(_endDate);
    _startTimeCtrl.text = _timeFormat.format(
      DateTime(0, 0, 0, _startTime.hour, _startTime.minute),
    );
    _endTimeCtrl.text   = _timeFormat.format(
      DateTime(0, 0, 0, _endTime.hour, _endTime.minute),
    );

    _loadDropdownData();
  }

  @override
  void dispose() {
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final employees  = await ShiftsService.fetchEmployees();
      final towers     = await ShiftsService.fetchTowers();
      final facilities = await ShiftsService.fetchFacilities();
      if (!mounted) return;
      setState(() {
        _employees  = employees;
        _towers     = towers;
        _facilities = facilities;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
    }
  }

  Future<void> _pickDate({ required bool isStart }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate:  DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateCtrl.text = _dateFormat.format(picked);
        // Si la fecha de fin era anterior, la igualamos
        if (_endDate.isBefore(picked)) {
          _endDate = picked;
          _endDateCtrl.text = _dateFormat.format(picked);
        }
      } else {
        _endDate = picked;
        _endDateCtrl.text = _dateFormat.format(picked);
      }
    });
  }

  Future<void> _pickTime({ required bool isStart }) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
        _startTimeCtrl.text = _timeFormat.format(
          DateTime(0, 0, 0, picked.hour, picked.minute),
        );
      } else {
        _endTime = picked;
        _endTimeCtrl.text = _timeFormat.format(
          DateTime(0, 0, 0, picked.hour, picked.minute),
        );
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Combinamos fecha y hora
    final start = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    try {
      await ShiftsService.createShift(
        employee:      _selectedEmployeeId!,
        area:          _selectedArea!,
        startDatetime: start,
        endDatetime:   end,
        tower:         _selectedTowerId,
        facility:      _selectedFacilityId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno asignado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error asignando turno: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Turno'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Empleado
                      DropdownButtonFormField<int>(
                        value: _selectedEmployeeId,
                        decoration: const InputDecoration(
                          labelText: 'Empleado',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _employees
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text('${e['first_name']} ${e['last_name']}'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedEmployeeId = v),
                        validator: (v) => v == null ? 'Selecciona un empleado' : null,
                      ),
                      const SizedBox(height: 16),

                      // Área
                      DropdownButtonFormField<String>(
                        value: _selectedArea,
                        decoration: const InputDecoration(
                          labelText: 'Área',
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: _areas.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedArea = v),
                        validator: (v) => v == null ? 'Selecciona un área' : null,
                      ),
                      const SizedBox(height: 16),

                      // Fecha y hora de inicio
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startDateCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Fecha Inicio',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () => _pickDate(isStart: true),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Elige la fecha' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _startTimeCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Hora Inicio',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              onTap: () => _pickTime(isStart: true),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Elige la hora' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fecha y hora de fin
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _endDateCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Fecha Fin',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () => _pickDate(isStart: false),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Elige la fecha' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _endTimeCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Hora Fin',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              onTap: () => _pickTime(isStart: false),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Elige la hora' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Torre o Instalación (opcionales)
                      DropdownButtonFormField<int>(
                        value: _selectedTowerId,
                        decoration: const InputDecoration(
                          labelText: 'Torre (opcional)',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: _towers
                            .map((t) => DropdownMenuItem<int>(
                                  value: t['id'] as int,
                                  child: Text(t['name']),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedTowerId    = v;
                          if (v != null) _selectedFacilityId = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedFacilityId,
                        decoration: const InputDecoration(
                          labelText: 'Instalación (opcional)',
                          prefixIcon: Icon(Icons.room_preferences),
                        ),
                        items: _facilities
                            .map((f) => DropdownMenuItem<int>(
                                  value: f['id'] as int,
                                  child: Text(f['name']),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedFacilityId = v;
                          if (v != null) _selectedTowerId = null;
                        }),
                      ),
                      const SizedBox(height: 24),

                      DomusButton(
                        text: _loading ? 'Enviando...' : 'Asignar Turno',
                        onPressed: _loading ? () {} : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
