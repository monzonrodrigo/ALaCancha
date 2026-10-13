import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/acceso/login_screen.dart';
import '../../features/acceso/registro_screen.dart';
import '../../features/acceso/splash_screen.dart';
import '../../features/cliente/canchas_screen.dart';
import '../../features/cliente/cliente_shell.dart';
import '../../features/cliente/confirmar_screen.dart';
import '../../features/cliente/grilla_screen.dart';
import '../../features/cliente/home_screen.dart';
import '../../features/cliente/mis_turnos_screen.dart';
import '../../features/cliente/nuevo_turno_fijo_screen.dart';
import '../../features/cliente/perfil_screen.dart';
import '../../providers/auth_providers.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refrescar() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authStateProvider, (_, __) => refreshNotifier.refrescar());
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
      final enPantallaPublica =
          ubicacion == '/login' || ubicacion == '/registro';
      if (!haySesion) {
        return enPantallaPublica ? null : '/login';
      }
      if (enPantallaPublica || ubicacion == '/splash') return '/cliente/home';
      return null;
    },
    routes: [
      GoRoute(
          path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/registro',
          builder: (context, state) => const RegistroScreen()),
      GoRoute(
        path: '/cliente/confirmar',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(title: const Text('Confirmar turno')),
            body: ConfirmarScreen(
              canchaId: args['canchaId'] as String,
              fecha: args['fecha'] as DateTime,
              hora: args['hora'] as int,
              esNocturno: args['esNocturno'] as bool,
            ),
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) =>
            ClienteShell(rutaActual: state.matchedLocation, child: child),
        routes: [
          GoRoute(
              path: '/cliente/home',
              builder: (context, state) => const HomeScreen()),
          GoRoute(
              path: '/cliente/canchas',
              builder: (context, state) => const CanchasScreen()),
          GoRoute(
            path: '/cliente/grilla/:canchaId',
            builder: (context, state) =>
                GrillaScreen(canchaId: state.pathParameters['canchaId']!),
          ),
          GoRoute(
              path: '/cliente/mis-turnos',
              builder: (context, state) => const MisTurnosScreen()),
          GoRoute(
              path: '/cliente/nuevo-turno-fijo',
              builder: (context, state) => const NuevoTurnoFijoScreen()),
          GoRoute(
              path: '/cliente/perfil',
              builder: (context, state) => const PerfilScreen()),
        ],
      ),
    ],
  );
});
