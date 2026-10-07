class BloqueoDisponibilidad {
  final String id;
  final String canchaId;
  final DateTime fecha;
  final int horaInicio;
  final String motivo;

  const BloqueoDisponibilidad({
    required this.id,
    required this.canchaId,
    required this.fecha,
    required this.horaInicio,
    required this.motivo,
  });

  factory BloqueoDisponibilidad.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return BloqueoDisponibilidad(
      id: id,
      canchaId: (data['canchaId'] as String?) ?? '',
      fecha: DateTime.parse(data['fecha'] as String),
      horaInicio: (data['horaInicio'] as num).toInt(),
      motivo: (data['motivo'] as String?) ?? 'Bloqueado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canchaId': canchaId,
      'fecha': DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
      ).toIso8601String(),
      'horaInicio': horaInicio,
      'motivo': motivo,
    };
  }
}