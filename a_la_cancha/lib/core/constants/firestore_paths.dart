class FirestorePaths {
  FirestorePaths._();
  static const String usuarios = 'usuarios';
  static const String canchas = 'canchas';
  static const String disponibilidad = 'disponibilidad';
  static const String configuracion = 'configuracion';
  static const String turnos = 'turnos';
  static const String turnosFijos = 'turnosFijos';

  /// El documento de configuracion es unico (singleton).
  static const String configuracionDocId = 'general';
}
