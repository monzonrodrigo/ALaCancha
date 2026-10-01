import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/slot_grilla.dart';
import 'configuracion_providers.dart';
import 'disponibilidad_providers.dart';
import 'turnos_fijos_providers.dart';
import 'turnos_providers.dart';

final grillaProvider =
    Provider.family<AsyncValue<List<SlotGrilla>>, TurnosDelDiaArgs>(
  (ref, args) {
    final configuracion = ref.watch(configuracionProvider);
    final turnosDelDia = ref.watch(turnosDelDiaProvider(args));
    final bloqueos = ref.watch(bloqueosDelDiaProvider(args));
    final turnosFijos = ref.watch(
      turnosFijosDeCanchaProvider(
        TurnosFijosDeCanchaArgs(
          canchaId: args.canchaId,
          diaSemana: args.fecha.weekday,
        ),
      ),
    );

    if (configuracion.isLoading ||
        turnosDelDia.isLoading ||
        bloqueos.isLoading ||
        turnosFijos.isLoading) {
      return const AsyncValue.loading();
    }

    final error = configuracion.error ??
        turnosDelDia.error ??
        bloqueos.error ??
        turnosFijos.error;

    if (error != null) {
      return AsyncValue.error(error, StackTrace.current);
    }

    final config = configuracion.value!;
    final slots = <SlotGrilla>[];

    for (var hora = config.horaAperturaPredio;
        hora < config.horaCierrePredio;
        hora++) {
      final esNocturno = config.horaEsNocturna(hora);

      final bloqueo =
          bloqueos.value!.where((b) => b.horaInicio == hora).firstOrNull;

      if (bloqueo != null) {
        slots.add(
          SlotGrilla(
            hora: hora,
            estado: EstadoSlot.bloqueado,
            esNocturno: esNocturno,
            etiqueta: bloqueo.motivo,
            referenciaId: bloqueo.id,
          ),
        );
        continue;
      }

      final turnoFijo =
          turnosFijos.value!.where((t) => t.horaInicio == hora).firstOrNull;

      if (turnoFijo != null) {
        slots.add(
          SlotGrilla(
            hora: hora,
            estado: EstadoSlot.ocupadoFijo,
            esNocturno: esNocturno,
            etiqueta: turnoFijo.equipo ?? turnoFijo.clienteNombre,
            referenciaId: turnoFijo.id,
          ),
        );
        continue;
      }

      final turno =
          turnosDelDia.value!.where((t) => t.horaInicio == hora).firstOrNull;

      if (turno != null) {
        slots.add(
          SlotGrilla(
            hora: hora,
            estado: EstadoSlot.ocupadoPuntual,
            esNocturno: esNocturno,
            etiqueta: turno.equipo ?? turno.clienteNombre,
            referenciaId: turno.id,
          ),
        );
        continue;
      }

      slots.add(
        SlotGrilla(
          hora: hora,
          estado: EstadoSlot.libre,
          esNocturno: esNocturno,
        ),
      );
    }

    return AsyncValue.data(slots);
  },
);

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}