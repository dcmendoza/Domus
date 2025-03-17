import 'package:flutter/material.dart';
import 'package:domus/widgets/bottom_navigation_bar.dart';
import 'package:domus/services/api_service.dart';
import 'package:domus/models/employee_model.dart';
import 'package:domus/widgets/employee_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/employee_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<dynamic>> futureEmployees;

  @override
  void initState() {
    super.initState();
    futureEmployees =
        ApiService().fetchEmployees(); // Cargar empleados desde la API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureEmployees,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los empleados'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay empleados registrados'));
          }

          List<dynamic> employees = snapshot.data!;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              var employeej = employees[index];
              var employee = Employee.fromJson(employeej);

              return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeDetailScreen(
                              employee: employee,
                            ),
                          ),
                        );
                      },
                      child: EmployeeCard(employee: employee))
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY();
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBarCard(currentIndex: 2),
    );
  }
}
