import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../models/usuario.dart';

class UsuariosRepository {
  UsuariosRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.usuarios);

  Stream<Usuario?> observarUsuario(String uid) {
    return _ref.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Usuario.fromMap(doc.id, doc.data()!);
    });
  }

  Future<Usuario?> obtenerUsuario(String uid) async {
    final doc = await _ref.doc(uid).get();
    if (!doc.exists) return null;
    return Usuario.fromMap(doc.id, doc.data()!);
  }

  Future<void> actualizarPerfil(Usuario usuario) {
    return _ref.doc(usuario.uid).update(usuario.toMap());
  }
}
