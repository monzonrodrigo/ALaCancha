import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/repository_providers.dart';

class SinPermisoScreen extends ConsumerWidget {
  const SinPermisoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 56,
                  color: AppColors.peligro,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Esta cuenta no es de administrador',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para reservar turnos usa la app de clientes. Si necesitas '
                  'acceso al panel, pedile al administrador que te asigne el rol.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authRepositoryProvider).cerrarSesion(),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Cerrar sesion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}