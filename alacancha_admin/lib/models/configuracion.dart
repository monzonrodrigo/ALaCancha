class Configuracion {
  final int minutosMinimoCancelacion;
  final double porcentajeSena;
  final int horaInicioNocturno;
  final int horaAperturaPredio;
  final int horaCierrePredio;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;

  const Configuracion({
    this.minutosMinimoCancelacion = 180,
    this.porcentajeSena = 50,
    this.horaInicioNocturno = 18,
    this.horaAperturaPredio = 9,
    this.horaCierrePredio = 24,
    this.creadoEn,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });

  bool horaEsNocturna(int hora) => hora >= horaInicioNocturno;

  factory Configuracion.fromMap(Map<String, dynamic> data) {
    return Configuracion(
      minutosMinimoCancelacion:
          (data['minutosMinimoCancelacion'] as num?)?.toInt() ?? 180,
      porcentajeSena: (data['porcentajeSena'] as num?)?.toDouble() ?? 50,
      horaInicioNocturno: (data['horaInicioNocturno'] as num?)?.toInt() ?? 18,
      horaAperturaPredio: (data['horaAperturaPredio'] as num?)?.toInt() ?? 9,
      horaCierrePredio: (data['horaCierrePredio'] as num?)?.toInt() ?? 24,
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
      'minutosMinimoCancelacion': minutosMinimoCancelacion,
      'porcentajeSena': porcentajeSena,
      'horaInicioNocturno': horaInicioNocturno,
      'horaAperturaPredio': horaAperturaPredio,
      'horaCierrePredio': horaCierrePredio,
      'creadoEn': (creadoEn ?? DateTime.now()).toIso8601String(),
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }

  Configuracion copyWith({
    int? minutosMinimoCancelacion,
    double? porcentajeSena,
    int? horaInicioNocturno,
    int? horaAperturaPredio,
    int? horaCierrePredio,
  }) {
    return Configuracion(
      minutosMinimoCancelacion:
          minutosMinimoCancelacion ?? this.minutosMinimoCancelacion,
      porcentajeSena: porcentajeSena ?? this.porcentajeSena,
      horaInicioNocturno: horaInicioNocturno ?? this.horaInicioNocturno,
      horaAperturaPredio: horaAperturaPredio ?? this.horaAperturaPredio,
      horaCierrePredio: horaCierrePredio ?? this.horaCierrePredio,
      creadoEn: creadoEn,
      actualizadoEn: actualizadoEn,
      eliminado: eliminado,
      disponible: disponible,
      status: status,
    );
  }
}
