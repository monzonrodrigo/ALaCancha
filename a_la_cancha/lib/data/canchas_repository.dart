import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/cancha.dart';

class CanchasRepository {
  CanchasRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.canchas);
  Stream<List<Cancha>> observarCanchas({bool soloActivas = false}) {
    Query<Map<String, dynamic>> query = _ref.orderBy('nombre');
    if (soloActivas) {
      query = query.where('activa', isEqualTo: true);
    }
    return query.snapshots().map(
          (snap) =>
              snap.docs.map((d) => Cancha.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Cancha?> obtenerCancha(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return Cancha.fromMap(doc.id, doc.data()!);
  }

  Future<void> crearCancha(Cancha cancha) {
    return _ref.doc(cancha.id).set(cancha.toMap());
  }

  Future<Cancha> crearCanchaNueva(Cancha datosSinId) async {
    final docRef = _ref.doc();
    final conId = datosSinId.copyWith();
    await docRef.set(conId.toMap());
    return Cancha.fromMap(docRef.id, conId.toMap());
  }

  Future<void> actualizarCancha(Cancha cancha) {
    return _ref.doc(cancha.id).update(cancha.toMap());
  }

  Future<void> eliminarCancha(String id) {
    return _ref.doc(id).delete();
  }
}
