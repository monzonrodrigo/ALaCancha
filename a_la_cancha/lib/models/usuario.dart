enum RolUsuario {
  cliente,
  administrador;

  static RolUsuario fromString(String value) {
    return RolUsuario.values.firstWhere(
      (r) => r.name == value,
      orElse: () => RolUsuario.cliente,
    );
  }
}

class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final RolUsuario rol;
  final String? telefono;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;
  final bool eliminado;
  final bool disponible;
  final String status;
  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.creadoEn,
    this.actualizadoEn,
    this.eliminado = false,
    this.disponible = true,
    this.status = 'activo',
  });
  bool get esAdministrador => rol == RolUsuario.administrador;
  factory Usuario.fromMap(String uid, Map<String, dynamic> data) {
    return Usuario(
      uid: uid,
      nombre: (data['nombre'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      rol: RolUsuario.fromString((data['rol'] as String?) ?? 'cliente'),
      telefono: data['telefono'] as String?,
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
      'email': email,
      'rol': rol.name,
      'telefono': telefono,
      'creadoEn': (creadoEn ?? DateTime.now()).toIso8601String(),
      'actualizadoEn': DateTime.now().toIso8601String(),
      'eliminado': eliminado,
      'disponible': disponible,
      'status': status,
    };
  }

  Usuario copyWith({
    String? nombre,
    String? email,
    RolUsuario? rol,
    String? telefono,
    bool? eliminado,
    bool? disponible,
    String? status,
  }) {
    return Usuario(
        uid: uid,
        nombre: nombre ?? this.nombre,
        email: email ?? this.email,
        rol: rol ?? this.rol,
        telefono: telefono ?? this.telefono,
        creadoEn: creadoEn,
        actualizadoEn: actualizadoEn,
        eliminado: eliminado ?? this.eliminado,
        disponible: disponible ?? this.disponible,
        status: status ?? this.status);
  }
}
