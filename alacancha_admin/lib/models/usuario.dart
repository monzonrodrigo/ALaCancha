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
  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.creadoEn,
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
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol.name,
      'telefono': telefono,
      'creadoEn': (creadoEn ?? DateTime.now()).toIso8601String(),
    };
  }

  Usuario copyWith({
    String? nombre,
    String? email,
    RolUsuario? rol,
    String? telefono,
  }) {
    return Usuario(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      telefono: telefono ?? this.telefono,
      creadoEn: creadoEn,
    );
  }
}
