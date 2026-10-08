import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/turno.dart';

class TurnoNoDisponibleException implements Exception {
  TurnoNoDisponibleException(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

class TurnosRepository {
  TurnosRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.turnos);

  static const _charsetCodigo = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  String _generarCodigoReserva() {
    final random = Random.secure();
    final sufijo = List.generate(
      5,
      (_) => _charsetCodigo[random.nextInt(_charsetCodigo.length)],
    ).join();
    return 'ALC-$sufijo';
  }

  Stream<List<Turno>> observarTurnosDelDia({
    required String canchaId,
    required DateTime fecha,
  }) {
    final inicioDia =
        DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();
    return _ref
        .where('canchaId', isEqualTo: canchaId)
        .where('fecha', isEqualTo: inicioDia)
        .where('estado', isNotEqualTo: EstadoTurno.cancelado.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Turno.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Turno>> observarTurnosDeCliente(String clienteId) {
    return _ref
        .where('clienteId', isEqualTo: clienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Turno.fromMap(d.id, d.data())).toList());
  }

  Future<Turno> crearTurno(Turno turno) async {
    final inicioDia =
        DateTime(turno.fecha.year, turno.fecha.month, turno.fecha.day)
            .toIso8601String();

    return _firestore.runTransaction<Turno>((tx) async {
      final choques = await _ref
          .where('canchaId', isEqualTo: turno.canchaId)
          .where('fecha', isEqualTo: inicioDia)
          .where('horaInicio', isEqualTo: turno.horaInicio)
          .where('estado', isNotEqualTo: EstadoTurno.cancelado.name)
          .get();

      if (choques.docs.isNotEmpty) {
        throw TurnoNoDisponibleException(
          'Ese horario ya fue reservado. Elegi otro turno en la grilla.',
        );
      }

      final docRef = _ref.doc();
      final turnoConId = Turno(
        id: docRef.id,
        canchaId: turno.canchaId,
        clienteId: turno.clienteId,
        clienteNombre: turno.clienteNombre,
        equipo: turno.equipo,
        fecha: turno.fecha,
        horaInicio: turno.horaInicio,
        esNocturno: turno.esNocturno,
        precio: turno.precio,
        estado: EstadoTurno.confirmado,
        creadoEn: DateTime.now(),
        codigoReserva: _generarCodigoReserva(),
      );
      tx.set(docRef, turnoConId.toMap());
      return turnoConId;
    });
  }

  Future<void> cancelarTurno(String turnoId) {
    return _ref.doc(turnoId).update({
      'estado': EstadoTurno.cancelado.name,
      'actualizadoEn': DateTime.now().toIso8601String(),
    });
  }

  Future<void> establecerDisponibilidad(String turnoId,
      {required bool habilitado}) {
    return _ref.doc(turnoId).update({
      'disponible': habilitado,
      'status': habilitado ? 'activo' : 'inactivo',
      'actualizadoEn': DateTime.now().toIso8601String(),
    });
  }
}
