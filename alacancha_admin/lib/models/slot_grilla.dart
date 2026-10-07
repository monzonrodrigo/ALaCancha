enum EstadoSlot {
  libre,
  ocupadoPuntual,
  ocupadoFijo,
  bloqueado,
}

class SlotGrilla {
  final int hora;
  final EstadoSlot estado;
  final bool esNocturno;
  final String? etiqueta;
  final String? referenciaId;

  const SlotGrilla({
    required this.hora,
    required this.estado,
    required this.esNocturno,
    this.etiqueta,
    this.referenciaId,
  });

  bool get disponible => estado == EstadoSlot.libre;
}