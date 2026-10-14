enum Superficie {
  sintetica,
  piso;

  static Superficie fromString(String value) {
    return Superficie.values.firstWhere(
      (s) => s.name == value,
      orElse: () => Superficie.sintetica,
    );
  }

  String get etiqueta => this == Superficie.sintetica ? 'Sintetica' : 'Piso';
}

class Cancha {
  final String id;
  final String nombre;
  final Superficie superficie;
  final double precioDiurno;
  final double precioNocturno;
  final bool activa;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;
  const Cancha({
    required this.id,
    required this.nombre,
    required this.superficie,
    required this.precioDiurno,
    required this.precioNocturno,
    this.activa = true,
    this.creadoEn,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });
  double precioSegunHorario({required bool esNocturno}) {
    return esNocturno ? precioNocturno : precioDiurno;
  }

  factory Cancha.fromMap(String id, Map<String, dynamic> data) {
    return Cancha(
      id: id,
      nombre: (data['nombre'] as String?) ?? '',
      superficie:
          Superficie.fromString((data['superficie'] as String?) ?? 'sintetica'),
      precioDiurno: (data['precioDiurno'] as num?)?.toDouble() ?? 0,
      precioNocturno: (data['precioNocturno'] as num?)?.toDouble() ?? 0,
      activa: (data['activa'] as bool?) ?? true,
      creadoEn: data['creadoEn'] != null
          ? DateTime.tryParse(data['creadoEn'].toString())
          : null,
      actualizadoEn: data['actualizadoEn'] != null
          ? DateTime.tryParse(data['actualizadoEn'].toString())
          : null,
      eliminado: (data['eliminado'] as bool?) ?? false,
      disponible: (data['disponible'] as bool?) ?? true,
      status: (data['status'] as String?) ?? 'activo',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'superficie': superficie.name,
      'precioDiurno': precioDiurno,
      'precioNocturno': precioNocturno,
      'activa': activa,
      'creadoEn': (creadoEn ?? DateTime.now()).toIso8601String(),
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }

  Cancha copyWith({
    String? nombre,
    Superficie? superficie,
    double? precioDiurno,
    double? precioNocturno,
    bool? activa,
    bool? eliminado,
    bool? disponible,
    String? status,
  }) {
    return Cancha(
      id: id,
      nombre: nombre ?? this.nombre,
      superficie: superficie ?? this.superficie,
      precioDiurno: precioDiurno ?? this.precioDiurno,
      precioNocturno: precioNocturno ?? this.precioNocturno,
      activa: activa ?? this.activa,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
      eliminado: eliminado ?? this.eliminado,
      disponible: disponible ?? this.disponible,
      status: status ?? this.status,
    );
  }
}
