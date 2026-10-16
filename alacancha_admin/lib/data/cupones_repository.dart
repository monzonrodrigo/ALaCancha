
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/cupon.dart';

class CuponesRepository {
  CuponesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(FirestorePaths.cupones);

  static const _charsetCodigo = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  String _generarCodigo() {
    final random = Random.secure();
    final sufijo = List.generate(
      5,
      (_) => _charsetCodigo[random.nextInt(_charsetCodigo.length)],
    ).join();
    return 'ALC-CUP-$sufijo';
  }

  Stream<List<Cupon>> observarCuponesDeCliente(String clienteId) {
    return _ref.where('clienteId', isEqualTo: clienteId).snapshots().map(
          (snap) => snap.docs.map((d) => Cupon.fromMap(d.id, d.data())).toList()
            ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn)),
        );
  }

  Stream<List<Cupon>> observarTodos() {
    return _ref.snapshots().map(
          (snap) => snap.docs.map((d) => Cupon.fromMap(d.id, d.data())).toList()
            ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn)),
        );
  }

  Future<void> sincronizarCupones({
    required String clienteId,
    required int partidosJugados,
    required int partidosPorCupon,
    required double porcentaje,
  }) async {
    if (partidosPorCupon <= 0) return;
    final objetivo = partidosJugados ~/ partidosPorCupon;
    for (var n = 1; n <= objetivo; n++) {
      final hito = n * partidosPorCupon;
      final docRef = _ref.doc('${clienteId}_$hito');
      final snap = await docRef.get();
      if (snap.exists) continue;
      final cupon = Cupon(
        id: docRef.id,
        clienteId: clienteId,
        codigo: _generarCodigo(),
        porcentaje: porcentaje,
        partidosAcumulados: hito,
        estado: EstadoCupon.disponible,
        creadoEn: DateTime.now(),
      );
      await docRef.set(cupon.toMap());
    }
  }

  Future<void> marcarComoUsado(String cuponId, String turnoId) {
    return _ref.doc(cuponId).update({
      'estado': EstadoCupon.usado.name,
      'usadoEn': DateTime.now().toIso8601String(),
      'turnoId': turnoId,
      'disponible': false,
      'status': 'inactivo',
      'actualizadoEn': DateTime.now().toIso8601String(),
    });
  }
}
