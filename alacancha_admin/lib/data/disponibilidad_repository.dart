import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/bloqueo_disponibilidad.dart';

class DisponibilidadRepository {
  DisponibilidadRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.disponibilidad);

  Stream<List<BloqueoDisponibilidad>> observarBloqueosDelDia({
    required String canchaId,
    required DateTime fecha,
  }) {
    final inicioDia =
        DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();

    return _ref
        .where('canchaId', isEqualTo: canchaId)
        .where('fecha', isEqualTo: inicioDia)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => BloqueoDisponibilidad.fromMap(
                  d.id,
                  d.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> crearBloqueo(BloqueoDisponibilidad bloqueo) {
    final docRef = _ref.doc();
    return docRef.set(bloqueo.toMap());
  }

  Future<void> eliminarBloqueo(String id) {
    return _ref.doc(id).delete();
  }
}