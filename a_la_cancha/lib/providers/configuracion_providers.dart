import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/configuracion.dart';
import 'repository_providers.dart';

final configuracionProvider = StreamProvider<Configuracion>((ref) {
  return ref.watch(configuracionRepositoryProvider).observarConfiguracion();
});