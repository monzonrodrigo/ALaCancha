class Configuracion {
final int minutosMinimoCancelacion;
final double porcentajeSena;
final int horaInicioNocturno;
final int horaAperturaPredio;
final int horaCierrePredio;
const Configuracion({
this.minutosMinimoCancelacion = 180,
this.porcentajeSena = 50,
this.horaInicioNocturno = 18,
this.horaAperturaPredio = 9,
this.horaCierrePredio = 24,
});
bool horaEsNocturna(int hora) => hora >= horaInicioNocturno;
factory Configuracion.fromMap(Map<String, dynamic> data) {
return Configuracion(
minutosMinimoCancelacion: (data['minutosMinimoCancelacion'] as num?)?.toInt() ?? 180,
porcentajeSena: (data['porcentajeSena'] as num?)?.toDouble() ?? 50,
horaInicioNocturno: (data['horaInicioNocturno'] as num?)?.toInt() ?? 18,
horaAperturaPredio: (data['horaAperturaPredio'] as num?)?.toInt() ?? 9,
horaCierrePredio: (data['horaCierrePredio'] as num?)?.toInt() ?? 24,
);
}
Map<String, dynamic> toMap() {
return {
'minutosMinimoCancelacion': minutosMinimoCancelacion,
'porcentajeSena': porcentajeSena,
'horaInicioNocturno': horaInicioNocturno,
'horaAperturaPredio': horaAperturaPredio,
'horaCierrePredio': horaCierrePredio,
};
}
Configuracion copyWith({
int? minutosMinimoCancelacion,
double? porcentajeSena,
int? horaInicioNocturno,
int? horaAperturaPredio,
int? horaCierrePredio,
}) {
return Configuracion(
minutosMinimoCancelacion: minutosMinimoCancelacion ?? this.minutosMinimoCancelacion,
porcentajeSena: porcentajeSena ?? this.porcentajeSena,
horaInicioNocturno: horaInicioNocturno ?? this.horaInicioNocturno,
horaAperturaPredio: horaAperturaPredio ?? this.horaAperturaPredio,
horaCierrePredio: horaCierrePredio ?? this.horaCierrePredio,
);
}
}