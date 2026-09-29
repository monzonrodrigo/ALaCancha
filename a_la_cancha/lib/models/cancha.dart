enum Superficie {
sintetica,
piso;
static Superficie fromString(String value) {
return Superficie.values.firstWhere(
(s) => s.name == value,
orElse: () => Superficie.sintetica,
);
}
String get etiqueta => this == Superficie.sintetica ? 'Sintetica' : 'Piso';
}

class Cancha {
final String id;
final String nombre;
final Superficie superficie;
final double precioDiurno;
final double precioNocturno;
final bool activa;
const Cancha({
required this.id,
required this.nombre,
required this.superficie,
required this.precioDiurno,
required this.precioNocturno,
this.activa = true,
});
double precioSegunHorario({required bool esNocturno}) {
return esNocturno ? precioNocturno : precioDiurno;
}
factory Cancha.fromMap(String id, Map<String, dynamic> data) {
return Cancha(
id: id,
nombre: (data['nombre'] as String?) ?? '',
superficie: Superficie.fromString((data['superficie'] as String?) ?? 'sintetica'),
precioDiurno: (data['precioDiurno'] as num?)?.toDouble() ?? 0,
precioNocturno: (data['precioNocturno'] as num?)?.toDouble() ?? 0,
activa: (data['activa'] as bool?) ?? true,
);
}
Map<String, dynamic> toMap() {
return {
'nombre': nombre,
'superficie': superficie.name,
'precioDiurno': precioDiurno,
'precioNocturno': precioNocturno,
'activa': activa,
};
}
Cancha copyWith({
String? nombre,
Superficie? superficie,
double? precioDiurno,
double? precioNocturno,
bool? activa,
}) {

return Cancha(
id: id,
nombre: nombre ?? this.nombre,
superficie: superficie ?? this.superficie,
precioDiurno: precioDiurno ?? this.precioDiurno,
precioNocturno: precioNocturno ?? this.precioNocturno,
activa: activa ?? this.activa,
);
}
}