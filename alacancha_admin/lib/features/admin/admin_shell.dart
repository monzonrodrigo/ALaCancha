import 'package:flutter/material.dart';
import 'widgets/drawer_admin.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.rutaActual,
    required this.child,
  });

  final String rutaActual;
  final Widget child;

  static const Map<String, String> _titulos = {
    '/admin/agenda': 'Agenda',
    '/admin/canchas': 'Canchas',
    '/admin/turnos-fijos': 'Turnos Fijos',
    '/admin/configuracion': 'Configuracion',
    '/admin/perfil': 'Perfil',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titulos[rutaActual] ?? 'Administrador',
        ),
      ),
      drawer: DrawerAdmin(
        rutaActual: rutaActual,
      ),
      body: child,
    );
  }
}