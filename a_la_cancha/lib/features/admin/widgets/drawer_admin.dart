import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/dialogo_confirmacion.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/repository_providers.dart';

class DrawerAdmin extends ConsumerWidget {
  const DrawerAdmin({super.key, required this.rutaActual});

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
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  usuario?.nombre ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Administrador',
                  style: TextStyle(
                    color: Color(0xFFD7E8DB),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _item(
            context,
            icono: Icons.calendar_month_outlined,
            texto: 'Agenda',
            ruta: '/admin/agenda',
          ),
          _item(
            context,
            icono: Icons.sports_soccer_outlined,
            texto: 'Canchas',
            ruta: '/admin/canchas',
          ),
          _item(
            context,
            icono: Icons.event_repeat_outlined,
            texto: 'Turnos Fijos',
            ruta: '/admin/turnos-fijos',
          ),
          _item(
            context,
            icono: Icons.settings_outlined,
            texto: 'Configuracion',
            ruta: '/admin/configuracion',
          ),
          _item(
            context,
            icono: Icons.person_outline,
            texto: 'Perfil',
            ruta: '/admin/perfil',
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.peligro,
            ),
            title: const Text(
              'Cerrar sesion',
              style: TextStyle(
                color: AppColors.peligro,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              Navigator.of(context).pop();

              final confirmar = await mostrarDialogoConfirmacion(
                context,
                titulo: 'Cerrar sesion?',
                mensaje: 'Vas a salir de tu cuenta de administrador.',
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

  Widget _item(
    BuildContext context, {
    required IconData icono,
    required String texto,
    required String ruta,
  }) {
    final activo = rutaActual == ruta;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: activo
              ? AppColors.primarioOscuro
              : AppColors.texto,
        ),
        title: Text(
          texto,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: activo
                ? AppColors.primarioOscuro
                : AppColors.texto,
          ),
        ),
        selected: activo,
        selectedTileColor: const Color(0xFFEAF3EC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.of(context).pop();

          if (!activo) {
            context.go(ruta);
          }
        },
      ),
    );
  }
}