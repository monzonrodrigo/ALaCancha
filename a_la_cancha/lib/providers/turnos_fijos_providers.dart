import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/turno_fijo.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

final misTurnosFijosProvider = StreamProvider<List<TurnoFijo>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).valueOrNull;

  if (usuario == null) return Stream.value(const []);

  return ref
      .watch(turnosFijosRepositoryProvider)
      .observarTurnosFijosDeCliente(usuario.uid);
});

final turnosFijosVigentesProvider = StreamProvider<List<TurnoFijo>>((ref) {
  return ref
      .watch(turnosFijosRepositoryProvider)
      .observarTodosVigentes();
});

class TurnosFijosDeCanchaArgs {
  const TurnosFijosDeCanchaArgs({
    required this.canchaId,
    required this.diaSemana,
  });

  final String canchaId;
  final int diaSemana;

  @override
  bool operator ==(Object other) =>
      other is TurnosFijosDeCanchaArgs &&
      other.canchaId == canchaId &&
      other.diaSemana == diaSemana;

  @override
  int get hashCode => Object.hash(canchaId, diaSemana);
}

final turnosFijosDeCanchaProvider =
    StreamProvider.family<List<TurnoFijo>, TurnosFijosDeCanchaArgs>(
  (ref, args) {
    return ref
        .watch(turnosFijosRepositoryProvider)
        .observarTurnosFijosDeCancha(
          canchaId: args.canchaId,
          diaSemana: args.diaSemana,
        );
  },
);