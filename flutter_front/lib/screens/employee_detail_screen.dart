import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:domus/models/employee_model.dart';
import 'package:domus/models/excusa_model.dart';
import 'package:domus/models/tarea_model.dart';
import 'package:domus/widgets/Excusa_card.dart';
import 'package:domus/widgets/employee_detail_card.dart';
import 'package:domus/widgets/tarea_card.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  EmployeeDetailScreen({required this.employee});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tarea> tareas = [
    Tarea(
        id: 1,
        nombre: 'Verificar seguridad',
        fecha: '12/05/2025',
        lugar: 'Sendero',
        estado: 'Pendiente',
        persona: 'Lolita'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Redibuja la pantalla cuando cambia la pestaña
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name,
            style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          dividerColor: Colors.lightGreen,
          labelStyle: GoogleFonts.lato(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
          tabs: [
            Tab(text: 'Información'),
            Tab(text: 'Tareas'),
            Tab(text: 'Excusas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionTab(),
          _buildTareasTab(),
          _buildExcusasTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _mostrarFormularioTarea,
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null, // Oculta el botón en otras pestañas
    );
  }

  Widget _buildInformacionTab() {
    return EmployeeDetailCard(employee: widget.employee);
  }

  Widget _buildTareasTab() {
    return ListView.builder(
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        return TareaCard(tarea: tareas[index]);
      },
    );
  }

  Widget _buildExcusasTab() {
    List<Excusa> excusas = [
      Excusa(
          id: 1,
          name: 'Incapacidad',
          employee:
              Employee(id: 4, name: 'Katy', role: 'Salva vidas', userId: 5),
          description: 'Tengo gripa'),
    ];

    return ListView.builder(
      itemCount: excusas.length,
      itemBuilder: (context, index) {
        return ExcusaCard(excusa: excusas[index]);
      },
    );
  }

  void _mostrarFormularioTarea() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController fechaController = TextEditingController();
    TextEditingController lugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nueva Tarea",
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: "Nombre de la tarea"),
              ),
              TextField(
                controller: fechaController,
                decoration: InputDecoration(labelText: "Fecha"),
              ),
              TextField(
                controller: lugarController,
                decoration: InputDecoration(labelText: "Lugar"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tareas.add(Tarea(
                    id: tareas.length + 1,
                    nombre: nombreController.text,
                    fecha: fechaController.text,
                    lugar: lugarController.text,
                    estado: "Pendiente",
                    persona: widget.employee.name,
                  ));
                });
                Navigator.pop(context);
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
