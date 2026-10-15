
enum EstadoCupon {
  disponible,
  usado,
  vencido;

  static EstadoCupon fromString(String value) {
    return EstadoCupon.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoCupon.disponible,
    );
  }
}

class Cupon {
  final String id;
  final String clienteId;
  final String codigo;
  final double porcentaje;
  final int partidosAcumulados;
  final EstadoCupon estado;
  final DateTime creadoEn;
  final DateTime? usadoEn;
  final String? turnoId;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;

  const Cupon({
    required this.id,
    required this.clienteId,
    required this.codigo,
    required this.porcentaje,
    required this.partidosAcumulados,
    required this.estado,
    required this.creadoEn,
    this.usadoEn,
    this.turnoId,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });

  bool get estaDisponible =>
      estado == EstadoCupon.disponible && !eliminado;

  double aplicarA(double precio) =>
      precio - (precio * porcentaje / 100);

  factory Cupon.fromMap(String id, Map<String, dynamic> data) {
    return Cupon(
      id: id,
      clienteId: (data['clienteId'] as String?) ?? '',
      codigo: (data['codigo'] as String?) ?? '',
      porcentaje: (data['porcentaje'] as num?)?.toDouble() ?? 0,
      partidosAcumulados:
          (data['partidosAcumulados'] as num?)?.toInt() ?? 0,
      estado: EstadoCupon.fromString(
          (data['estado'] as String?) ?? 'disponible'),
      creadoEn: data['creadoEn'] != null
          ? DateTime.parse(data['creadoEn'] as String)
          : DateTime.now(),
      usadoEn: data['usadoEn'] != null
          ? DateTime.tryParse(data['usadoEn'].toString())
          : null,
      turnoId: data['turnoId'] as String?,
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
      'clienteId': clienteId,
      'codigo': codigo,
      'porcentaje': porcentaje,
      'partidosAcumulados': partidosAcumulados,
      'estado': estado.name,
      'creadoEn': creadoEn.toIso8601String(),
      'usadoEn': usadoEn?.toIso8601String(),
      'turnoId': turnoId,
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }
}
