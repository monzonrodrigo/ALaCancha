import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/turno.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

final misTurnosProvider = StreamProvider<List<Turno>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).valueOrNull;

  if (usuario == null) return Stream.value(const []);

  return ref
      .watch(turnosRepositoryProvider)
      .observarTurnosDeCliente(usuario.uid);
});

class TurnosDelDiaArgs {
  const TurnosDelDiaArgs({
    required this.canchaId,
    required this.fecha,
  });

  final String canchaId;
  final DateTime fecha;

  @override
  bool operator ==(Object other) =>
      other is TurnosDelDiaArgs &&
      other.canchaId == canchaId &&
      other.fecha.year == fecha.year &&
      other.fecha.month == fecha.month &&
      other.fecha.day == fecha.day;

  @override
  int get hashCode =>
      Object.hash(canchaId, fecha.year, fecha.month, fecha.day);
}

final turnosDelDiaProvider =
    StreamProvider.family<List<Turno>, TurnosDelDiaArgs>((ref, args) {
  return ref
      .watch(turnosRepositoryProvider)
      .observarTurnosDelDia(
        canchaId: args.canchaId,
        fecha: args.fecha,
      );
});