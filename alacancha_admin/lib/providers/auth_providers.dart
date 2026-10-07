import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario.dart';
import 'repository_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).cambiosDeSesion;
});

final usuarioActualProvider = StreamProvider<Usuario?>((ref) {
  final authState = ref.watch(authStateProvider).valueOrNull;
  if (authState == null) return Stream.value(null);
  return ref.watch(usuariosRepositoryProvider).observarUsuario(authState.uid);
});

final esAdministradorProvider = Provider<bool>((ref) {
  final usuario = ref.watch(usuarioActualProvider).valueOrNull;
  return usuario?.esAdministrador ?? false;
});
