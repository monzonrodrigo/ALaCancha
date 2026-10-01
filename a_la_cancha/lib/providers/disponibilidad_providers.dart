import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bloqueo_disponibilidad.dart';
import 'repository_providers.dart';
import 'turnos_providers.dart' show TurnosDelDiaArgs;

final bloqueosDelDiaProvider =
    StreamProvider.family<List<BloqueoDisponibilidad>, TurnosDelDiaArgs>(
  (ref, args) {
    return ref
        .watch(disponibilidadRepositoryProvider)
        .observarBloqueosDelDia(
          canchaId: args.canchaId,
          fecha: args.fecha,
        );
  },
);