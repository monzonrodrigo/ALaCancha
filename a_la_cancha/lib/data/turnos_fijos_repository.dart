import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/turno_fijo.dart';

class TurnosFijosRepository {
  TurnosFijosRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.turnosFijos);

  Stream<List<TurnoFijo>> observarTurnosFijosDeCancha({
    required String canchaId,
    required int diaSemana,
  }) {
    return _ref
        .where('canchaId', isEqualTo: canchaId)
        .where('diaSemana', isEqualTo: diaSemana)
        .where('estado', isEqualTo: EstadoTurnoFijo.vigente.name)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => TurnoFijo.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<TurnoFijo>> observarTodosVigentes() {
    return _ref
        .where('estado', isEqualTo: EstadoTurnoFijo.vigente.name)
        .orderBy('diaSemana')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => TurnoFijo.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<TurnoFijo>> observarTurnosFijosDeCliente(String clienteId) {
    return _ref
        .where('clienteId', isEqualTo: clienteId)
        .where('estado', isEqualTo: EstadoTurnoFijo.vigente.name)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => TurnoFijo.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<TurnoFijo> crearTurnoFijo(TurnoFijo turnoFijo) async {
    return _firestore.runTransaction<TurnoFijo>((tx) async {
      final choques = await _ref
          .where('canchaId', isEqualTo: turnoFijo.canchaId)
          .where('diaSemana', isEqualTo: turnoFijo.diaSemana)
          .where('horaInicio', isEqualTo: turnoFijo.horaInicio)
          .where('estado', isEqualTo: EstadoTurnoFijo.vigente.name)
          .get();

      if (choques.docs.isNotEmpty) {
        throw StateError(
          'Ese dia y horario ya tiene un turno fijo asignado. Elegi otro.',
        );
      }

      final docRef = _ref.doc();

      final conId = TurnoFijo(
        id: docRef.id,
        canchaId: turnoFijo.canchaId,
        clienteId: turnoFijo.clienteId,
        clienteNombre: turnoFijo.clienteNombre,
        equipo: turnoFijo.equipo,
        diaSemana: turnoFijo.diaSemana,
        horaInicio: turnoFijo.horaInicio,
        precio: turnoFijo.precio,
        estado: EstadoTurnoFijo.vigente,
        creadoEn: DateTime.now(),
      );

      tx.set(docRef, conId.toMap());

      return conId;
    });
  }

  Future<void> darDeBaja(String turnoFijoId) {
    return _ref.doc(turnoFijoId).update({
      'estado': EstadoTurnoFijo.dadoDeBaja.name,
      'bajaEn': DateTime.now().toIso8601String(),
    });
  }
}