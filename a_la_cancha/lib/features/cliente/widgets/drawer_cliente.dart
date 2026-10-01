import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dialogo_confirmacion.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/repository_providers.dart';

class DrawerCliente extends ConsumerWidget {
  const DrawerCliente({super.key, required this.rutaActual});

  final String rutaActual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primario, AppColors.primarioOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _iniciales(usuario?.nombre ?? '?'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                Text(usuario?.nombre ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                Text(usuario?.email ?? '', style: const TextStyle(color: Color(0xFFD7E8DB), fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _item(context, icono: Icons.home_outlined, texto: 'Home', ruta: '/cliente/home'),
          _item(context, icono: Icons.sports_soccer_outlined, texto: 'Canchas', ruta: '/cliente/canchas'),
          _item(context, icono: Icons.event_note_outlined, texto: 'Mis Turnos', ruta: '/cliente/mis-turnos'),
          _item(context, icono: Icons.person_outline, texto: 'Perfil', ruta: '/cliente/perfil'),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.peligro),
            title: const Text(
              'Cerrar sesion',
              style: TextStyle(color: AppColors.peligro, fontWeight: FontWeight.w700),
            ),
            onTap: () async {
              Navigator.of(context).pop();
              final confirmar = await mostrarDialogoConfirmacion(
                context,
                titulo: 'Cerrar sesion?',
                mensaje:
                    'Vas a salir de tu cuenta. Vas a tener que volver a ingresar tu email y contrasena (o el login social) para reservar de nuevo.',
                textoBotonConfirmar: 'Cerrar sesion',
              );
              if (confirmar) {
                await ref.read(authRepositoryProvider).cerrarSesion();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, {required IconData icono, required String texto, required String ruta}) {
    final activo = rutaActual == ruta;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icono, color: activo ? AppColors.primarioOscuro : AppColors.texto),
        title: Text(
          texto,
          style: TextStyle(fontWeight: FontWeight.w700, color: activo ? AppColors.primarioOscuro : AppColors.texto),
        ),
        selected: activo,
        selectedTileColor: const Color(0xFFEAF3EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.of(context).pop();
          if (!activo) context.go(ruta);
        },
      ),
    );
  }

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1)).toUpperCase();
  }
}