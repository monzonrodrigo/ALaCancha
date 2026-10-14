enum EstadoTurno {
  pendiente,
  confirmado,
  cancelado;

  static EstadoTurno fromString(String value) {
    return EstadoTurno.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstadoTurno.pendiente,
    );
  }
}

class Turno {
  final String id;
  final String canchaId;
  final String clienteId;
  final String clienteNombre;
  final String? equipo;
  final DateTime fecha;
  final int horaInicio;
  final bool esNocturno;
  final double precio;
  final EstadoTurno estado;
  final DateTime creadoEn;
  final String codigoReserva;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;

  const Turno({
    required this.id,
    required this.canchaId,
    required this.clienteId,
    required this.clienteNombre,
    this.equipo,
    required this.fecha,
    required this.horaInicio,
    required this.esNocturno,
    required this.precio,
    required this.estado,
    required this.creadoEn,
    this.codigoReserva = '',
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });

  int get horaFin => horaInicio + 1;

  factory Turno.fromMap(String id, Map<String, dynamic> data) {
    return Turno(
      id: id,
      canchaId: (data['canchaId'] as String?) ?? '',
      clienteId: (data['clienteId'] as String?) ?? '',
      clienteNombre: (data['clienteNombre'] as String?) ?? '',
      equipo: data['equipo'] as String?,
      fecha: DateTime.parse(data['fecha'] as String),
      horaInicio: (data['horaInicio'] as num).toInt(),
      esNocturno: (data['esNocturno'] as bool?) ?? false,
      precio: (data['precio'] as num?)?.toDouble() ?? 0,
      estado:
          EstadoTurno.fromString((data['estado'] as String?) ?? 'pendiente'),
      creadoEn: data['creadoEn'] != null
          ? DateTime.parse(data['creadoEn'] as String)
          : DateTime.now(),
      codigoReserva: (data['codigoReserva'] as String?) ?? '',
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
      'fecha': DateTime(fecha.year, fecha.month, fecha.day).toIso8601String(),
      'horaInicio': horaInicio,
      'esNocturno': esNocturno,
      'precio': precio,
      'estado': estado.name,
      'creadoEn': creadoEn.toIso8601String(),
      'codigoReserva': codigoReserva,
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }
}
