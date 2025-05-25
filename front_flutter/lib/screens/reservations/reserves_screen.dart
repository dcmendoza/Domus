import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:domus/services/auth/auth_service.dart';
import 'package:domus/services/reservations/reservations_service.dart';
import 'package:domus/screens/home/home_screen.dart';
import 'package:domus/routes.dart';

/// Pantalla para ver reservas y peticiones de reserva.
class ReservesScreen extends StatefulWidget {
  static const routeName = Routes.reserves;
  const ReservesScreen({super.key});

  @override
  State<ReservesScreen> createState() => _ReservesScreenState();
}

class _ReservesScreenState extends State<ReservesScreen> {
  bool _loading = true;
  bool _showPending = false;
  List<dynamic> _reservations = [];
  String _role = 'propietario';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Obtener rol y reservas
      final profile = await AuthService.getProfile();
      final list = await ReservationsService.fetchReservations();
      setState(() {
        _role = profile['role'] as String;
        _reservations = list
            .where((r) => _showPending ? r['status']=='pendiente' : r['status']!='pendiente')
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: \$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showPending ? 'Peticiones de Reserva' : 'Reservas Aprobadas'),
        actions: [
          IconButton(
            icon: Icon(_showPending ? Icons.check : Icons.hourglass_empty),
            onPressed: () => setState(() {
              _showPending = !_showPending;
              _loadData();
            }),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reservations.length,
              itemBuilder: (ctx, i) {
                final r = _reservations[i];
                final start = DateTime.parse(r['start_datetime']);
                final end = DateTime.parse(r['end_datetime']);
                final fmt = DateFormat('yyyy-MM-dd HH:mm');
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(r['facility_name'] as String),
                    subtitle: Text(
                      '${fmt.format(start)} → ${fmt.format(end)}',
                    ),
                    trailing: _showPending && _role=='admin'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await ReservationsService.reviewReservation(
                                      id: r['id'], decision: 'aprobada');
                                  _loadData();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await ReservationsService.reviewReservation(
                                      id: r['id'], decision: 'rechazada');
                                  _loadData();
                                },
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => Navigator.pushNamed(
                              context, Routes.reservationDetails,
                              arguments: r,
                            ).then((_) => _loadData()),
                          ),
                  ),
                );
              },
            ),
      floatingActionButton: (_role!='admin' && !_showPending)
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                  context, Routes.newReservation)
                .then((v) => _loadData()),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar:
          DomusBottomNavBar(role: _role),
    );
  }
}