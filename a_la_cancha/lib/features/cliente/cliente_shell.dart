import 'package:flutter/material.dart';
import 'widgets/drawer_cliente.dart';

class ClienteShell extends StatelessWidget {
  const ClienteShell(
      {super.key, required this.rutaActual, required this.child});
  final String rutaActual;
  final Widget child;
  static const Map<String, String> _titulos = {
    '/cliente/home': 'Turnos F5',
    '/cliente/canchas': 'Canchas',
    '/cliente/mis-turnos': 'Mis Turnos',
    '/cliente/perfil': 'Perfil',
    '/cliente/nuevo-turno-fijo': 'Nuevo turno fijo',
  };
  String _titulo() {
    if (_titulos.containsKey(rutaActual)) return _titulos[rutaActual]!;
    if (rutaActual.startsWith('/cliente/grilla')) return 'Elegir horario';
    if (rutaActual.startsWith('/cliente/confirmar')) return 'Confirmar turno';
    return 'Turnos F5';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulo())),
      drawer: DrawerCliente(rutaActual: rutaActual),
      body: child,
    );
  }
}
