import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cancha.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

final canchasActivasProvider = StreamProvider<List<Cancha>>((ref) {
  final sesion = ref.watch(authStateProvider).valueOrNull;
  if (sesion == null) return Stream.value(const []);
  return ref
      .watch(canchasRepositoryProvider)
      .observarCanchas(soloActivas: true);
});

final todasLasCanchasProvider = StreamProvider<List<Cancha>>((ref) {
  final sesion = ref.watch(authStateProvider).valueOrNull;
  if (sesion == null) return Stream.value(const []);
  return ref.watch(canchasRepositoryProvider).observarCanchas();
});

final canchaPorIdProvider = FutureProvider.family<Cancha?, String>((ref, id) {
  final sesion = ref.watch(authStateProvider).valueOrNull;
  if (sesion == null) return Future.value(null);
  return ref.watch(canchasRepositoryProvider).obtenerCancha(id);
});
