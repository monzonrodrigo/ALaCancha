import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/canchas_repository.dart';
import '../data/configuracion_repository.dart';
import '../data/disponibilidad_repository.dart';
import '../data/turnos_fijos_repository.dart';
import '../data/turnos_repository.dart';
import '../data/usuarios_repository.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());
final usuariosRepositoryProvider =
    Provider<UsuariosRepository>((ref) => UsuariosRepository());
final canchasRepositoryProvider =
    Provider<CanchasRepository>((ref) => CanchasRepository());
final configuracionRepositoryProvider =
    Provider<ConfiguracionRepository>((ref) => ConfiguracionRepository());
final turnosRepositoryProvider =
    Provider<TurnosRepository>((ref) => TurnosRepository());
final turnosFijosRepositoryProvider =
    Provider<TurnosFijosRepository>((ref) => TurnosFijosRepository());
final disponibilidadRepositoryProvider =
    Provider<DisponibilidadRepository>((ref) => DisponibilidadRepository());
