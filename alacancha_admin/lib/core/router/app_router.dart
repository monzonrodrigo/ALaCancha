import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/cupones_admin_screen.dart';
import '../../features/acceso/login_screen.dart';
import '../../features/acceso/sin_permiso_screen.dart';
import '../../features/acceso/splash_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/agenda_admin_screen.dart';
import '../../features/admin/canchas_admin_screen.dart';
import '../../features/admin/configuracion_admin_screen.dart';
import '../../features/admin/perfil_screen.dart';
import '../../features/admin/turnos_fijos_admin_screen.dart';
import '../../providers/auth_providers.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refrescar() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authStateProvider, (_, _) => refreshNotifier.refrescar());
  ref.listen(usuarioActualProvider, (_, _) => refreshNotifier.refrescar());
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final ubicacion = state.matchedLocation;
      if (authState.isLoading) {
        return ubicacion == '/splash' ? null : '/splash';
      }
      final haySesion = authState.valueOrNull != null;
      if (!haySesion) {
        return ubicacion == '/login' ? null : '/login';
      }
      final usuarioAsync = ref.read(usuarioActualProvider);
      if (usuarioAsync.isLoading) {
        return ubicacion == '/splash' ? null : '/splash';
      }
      final usuario = usuarioAsync.valueOrNull;
      if (usuario == null) {
        return ubicacion == '/splash' ? null : '/splash';
      }
      if (!usuario.esAdministrador) {
        return ubicacion == '/sin-permiso' ? null : '/sin-permiso';
      }
      if (!ubicacion.startsWith('/admin')) return '/admin/agenda';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/sin-permiso',
        builder: (context, state) => const SinPermisoScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(rutaActual: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/admin/agenda',
            builder: (context, state) => const AgendaAdminScreen(),
          ),
          GoRoute(
            path: '/admin/canchas',
            builder: (context, state) => const CanchasAdminScreen(),
          ),
          GoRoute(
            path: '/admin/turnos-fijos',
            builder: (context, state) => const TurnosFijosAdminScreen(),
          ),
          GoRoute(
            path: '/admin/configuracion',
            builder: (context, state) => const ConfiguracionAdminScreen(),
          ),
          GoRoute(
            path: '/admin/perfil',
            builder: (context, state) => const PerfilScreen(),
          ),
          GoRoute(
            path: '/admin/cupones',
            builder: (context, state) => const CuponesAdminScreen(),
          ),
        ],
      ),
    ],
  );
});
