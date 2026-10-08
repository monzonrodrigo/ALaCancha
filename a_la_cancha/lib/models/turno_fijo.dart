enum EstadoTurnoFijo {
  vigente,
  dadoDeBaja;

  static EstadoTurnoFijo fromString(String value) {
    return EstadoTurnoFijo.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoTurnoFijo.vigente,
    );
  }
}

class TurnoFijo {
  final String id;
  final String canchaId;
  final String clienteId;
  final String clienteNombre;
  final String? equipo;
  final int diaSemana;
  final int horaInicio;
  final double precio;
  final EstadoTurnoFijo estado;
  final DateTime creadoEn;
  final DateTime? bajaEn;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;

  const TurnoFijo({
    required this.id,
    required this.canchaId,
    required this.clienteId,
    required this.clienteNombre,
    this.equipo,
    required this.diaSemana,
    required this.horaInicio,
    required this.precio,
    required this.estado,
    required this.creadoEn,
    this.bajaEn,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });

  int get horaFin => horaInicio + 1;

  static const _nombresDia = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  String get nombreDia => _nombresDia[(diaSemana - 1).clamp(0, 6)];

  factory TurnoFijo.fromMap(String id, Map<String, dynamic> data) {
    return TurnoFijo(
      id: id,
      canchaId: (data['canchaId'] as String?) ?? '',
      clienteId: (data['clienteId'] as String?) ?? '',
      clienteNombre: (data['clienteNombre'] as String?) ?? '',
      equipo: data['equipo'] as String?,
      diaSemana: (data['diaSemana'] as num).toInt(),
      horaInicio: (data['horaInicio'] as num).toInt(),
      precio: (data['precio'] as num?)?.toDouble() ?? 0,
      estado:
          EstadoTurnoFijo.fromString((data['estado'] as String?) ?? 'vigente'),
      creadoEn: data['creadoEn'] != null
          ? DateTime.parse(data['creadoEn'] as String)
          : DateTime.now(),
      bajaEn: data['bajaEn'] != null
          ? DateTime.parse(data['bajaEn'] as String)
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
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'equipo': equipo,
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'precio': precio,
      'estado': estado.name,
      'creadoEn': creadoEn.toIso8601String(),
      'bajaEn': bajaEn?.toIso8601String(),
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }
}
