import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/configuracion.dart';

class ConfiguracionRepository {
  ConfiguracionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _doc => _firestore
      .collection(FirestorePaths.configuracion)
      .doc(FirestorePaths.configuracionDocId);

  Stream<Configuracion> observarConfiguracion() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists) return const Configuracion();
      return Configuracion.fromMap(snap.data()!);
    });
  }

  Future<Configuracion> obtenerConfiguracion() async {
    final snap = await _doc.get();

    if (!snap.exists) return const Configuracion();

    return Configuracion.fromMap(snap.data()!);
  }

  Future<void> actualizarConfiguracion(
    Configuracion configuracion,
  ) {
    return _doc.set(
      configuracion.toMap(),
      SetOptions(merge: true),
    );
  }
}