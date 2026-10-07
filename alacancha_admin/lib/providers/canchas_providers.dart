import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cancha.dart';
import 'repository_providers.dart';

final canchasActivasProvider = StreamProvider<List<Cancha>>((ref) {
  return ref
      .watch(canchasRepositoryProvider)
      .observarCanchas(soloActivas: true);
});

final todasLasCanchasProvider = StreamProvider<List<Cancha>>((ref) {
  return ref.watch(canchasRepositoryProvider).observarCanchas();
});
final canchaPorIdProvider = FutureProvider.family<Cancha?, String>((ref, id) {
  return ref.watch(canchasRepositoryProvider).obtenerCancha(id);
});
