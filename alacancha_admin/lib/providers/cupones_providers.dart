
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cupon.dart';
import '../models/turno.dart';
import 'auth_providers.dart';
import 'configuracion_providers.dart';
import 'repository_providers.dart';
import 'turnos_providers.dart';

final misCuponesProvider = StreamProvider<List<Cupon>>((ref) {
  final usuario = ref.watch(usuarioActualProvider).valueOrNull;
  if (usuario == null) return Stream.value(const []);
  return ref
      .watch(cuponesRepositoryProvider)
      .observarCuponesDeCliente(usuario.uid);
});

final misCuponesDisponiblesProvider = Provider<List<Cupon>>((ref) {
  final cupones = ref.watch(misCuponesProvider).valueOrNull ?? const <Cupon>[];
  return cupones.where((c) => c.estaDisponible).toList();
});

final partidosJugadosProvider = Provider<int>((ref) {
  final turnos = ref.watch(misTurnosProvider).valueOrNull ?? const <Turno>[];
  final ahora = DateTime.now();
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  return turnos
      .where((t) => t.estado == EstadoTurno.confirmado && t.fecha.isBefore(hoy))
      .length;
});

final todosLosCuponesProvider = StreamProvider<List<Cupon>>((ref) {
  final sesion = ref.watch(authStateProvider).valueOrNull;
  if (sesion == null) return Stream.value(const []);
  return ref.watch(cuponesRepositoryProvider).observarTodos();
});

final sincronizarCuponesProvider = FutureProvider<void>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).valueOrNull;
  final config = ref.watch(configuracionProvider).valueOrNull;
  if (usuario == null || config == null) return;
  final jugados = ref.watch(partidosJugadosProvider);
  if (jugados < config.partidosPorCupon) return;
  await ref.read(cuponesRepositoryProvider).sincronizarCupones(
         clienteId: usuario.uid,
         partidosJugados: jugados,
         partidosPorCupon: config.partidosPorCupon,
         porcentaje: config.porcentajeDescuentoCupon,
      );
});
