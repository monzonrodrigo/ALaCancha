class BloqueoDisponibilidad {
  final String id;
  final String canchaId;
  final DateTime fecha;
  final int horaInicio;
  final String motivo;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;

  const BloqueoDisponibilidad({
    required this.id,
    required this.canchaId,
    required this.fecha,
    required this.horaInicio,
    required this.motivo,
    this.creadoEn,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });

  factory BloqueoDisponibilidad.fromMap(String id, Map<String, dynamic> data) {
    return BloqueoDisponibilidad(
      id: id,
      canchaId: (data['canchaId'] as String?) ?? '',
      fecha: DateTime.parse(data['fecha'] as String),
      horaInicio: (data['horaInicio'] as num).toInt(),
      motivo: (data['motivo'] as String?) ?? 'Bloqueado',
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
      'canchaId': canchaId,
      'fecha': DateTime(fecha.year, fecha.month, fecha.day).toIso8601String(),
      'horaInicio': horaInicio,
      'motivo': motivo,
      'creadoEn': (creadoEn ?? DateTime.now()).toIso8601String(),
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }
}
