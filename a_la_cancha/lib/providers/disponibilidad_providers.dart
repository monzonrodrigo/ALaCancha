import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bloqueo_disponibilidad.dart';
import 'repository_providers.dart';
import 'turnos_providers.dart' show TurnosDelDiaArgs;
import 'auth_providers.dart';

final bloqueosDelDiaProvider =
    StreamProvider.family<List<BloqueoDisponibilidad>, TurnosDelDiaArgs>(
  (ref, args) {
    final sesion = ref.watch(authStateProvider).valueOrNull;
    if (sesion == null) return Stream.value(const []);
    return ref.watch(disponibilidadRepositoryProvider).observarBloqueosDelDia(
          canchaId: args.canchaId,
          fecha: args.fecha,
        );
  },
);
