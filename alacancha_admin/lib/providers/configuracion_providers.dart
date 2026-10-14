import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/configuracion.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

final configuracionProvider = StreamProvider<Configuracion>((ref) {
  final sesion = ref.watch(authStateProvider).valueOrNull;
  if (sesion == null) return Stream.value(const Configuracion());
  return ref.watch(configuracionRepositoryProvider).observarConfiguracion();
});
