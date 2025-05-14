import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/shifts/shifts_service.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/routes.dart';
import '../home/home_screen.dart'; // para usar DomusBottomNavBar

class ShiftsScreen extends StatefulWidget {
  static const routeName = Routes.shifts;
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  bool _loading = true;
  bool _showCalendar = false;
  late DateTime _selectedDate;
  List<dynamic> _shifts = [];
  String? _role;
  int _employeeCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile = await AuthService.getProfile();
      final allShifts = await ShiftsService.fetchShiftsForDate(_selectedDate);

      // Filtrar sólo los turnos que cubren _selectedDate
      final filtered = allShifts.where((s) {
        final start = DateTime.parse(s['start_datetime'] as String);
        final end   = DateTime.parse(s['end_datetime']   as String);
        // devolvemos true si selectedDate está entre start y end (inclusive)
        return !_selectedDate.isBefore(start) && !_selectedDate.isAfter(end);
      }).toList();

      final ids = filtered.map((s) => s['employee'] as int).toSet().length;
      if (!mounted) return;
      setState(() {
        _role          = profile['role'] as String;
        _shifts        = filtered;
        _employeeCount = ids;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  Widget _buildDateSlider() {
    // 7 días centrados en _selectedDate
    final days = List.generate(7, (i) => _selectedDate.add(Duration(days: i - 3)));
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final d = days[i];
          final sel = d.year==_selectedDate.year &&
                      d.month==_selectedDate.month &&
                      d.day==_selectedDate.day;
          return GestureDetector(
            onTap: () => _onDateChanged(d),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: sel ? Colors.green : null,
                border: Border.all(color: const Color.fromARGB(255, 3, 106, 5)),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('d').format(d),
                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : Theme.of(ctx).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(d),
                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : Theme.of(ctx).colorScheme.primary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutine() {
    if (_shifts.isEmpty) {
      return const Center(child: Text('No hay turnos para este día'));
    }
    final sorted = List.from(_shifts)
      ..sort((a, b) =>
          (a['start_datetime'] as String)
              .compareTo(b['start_datetime'] as String));
    return Column(
      children: sorted.map((s) {
        final start = DateTime.parse(s['start_datetime']);
        final end   = DateTime.parse(s['end_datetime']);
        final name  = s['employee_name'] ?? 'Empleado';
        final area  = s['area'] as String;
        final startStr = DateFormat('hh:mm a').format(start);
        final endStr   = DateFormat('hh:mm a').format(end);
        final bg       = Colors.green.withAlpha((0.8 * 255).toInt());

        return GestureDetector(
          onTap: () => Navigator.pushNamed(
              context, Routes.shiftDetails,
              arguments: s),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name – $area',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$startStr – $endStr',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final headerDate = DateFormat('MMMM, d', locale).format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Empleados',
          style: TextStyle(color: Colors.green),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
        foregroundColor: Colors.green,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Text(headerDate,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (_role == 'admin') ...[
                  const SizedBox(height: 2),
                  Text('$_employeeCount empleados trabajando hoy',
                      style: Theme.of(context).textTheme.bodySmall),
                ]
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () =>
                setState(() => _showCalendar = !_showCalendar),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(
                  context, Routes.welcome);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _showCalendar
                      ? CalendarDatePicker(
                          initialDate: _selectedDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                          onDateChanged: _onDateChanged,
                        )
                      : _buildDateSlider(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                        child: _buildRoutine()),
                  ),
                ],
              ),
            ),
      floatingActionButton: _role == 'admin'
        ? FloatingActionButton(
            onPressed: () {
              // Navegar a la pantalla de asignar turno
              Navigator.pushNamed(context, Routes.shiftAssign, arguments: {
                'date': _selectedDate,
              });
            },
            tooltip: 'Asignar Turno',
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          )
        : null,
      bottomNavigationBar:
          DomusBottomNavBar(role: _role ?? 'empleado'),
    );
  }
}
