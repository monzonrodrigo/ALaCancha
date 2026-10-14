import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/slot_grilla.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/grilla_provider.dart';
import '../../providers/turnos_providers.dart';

class GrillaScreen extends ConsumerStatefulWidget {
  const GrillaScreen({super.key, required this.canchaId});
  final String canchaId;

  @override
  ConsumerState<GrillaScreen> createState() => _GrillaScreenState();
}

class _GrillaScreenState extends ConsumerState<GrillaScreen> {
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _fecha = DateTime(ahora.year, ahora.month, ahora.day);
  }

  DateTime get _hoy {
    final a = DateTime.now();
    return DateTime(a.year, a.month, a.day);
  }

  @override
  Widget build(BuildContext context) {
    final cancha = ref.watch(canchaPorIdProvider(widget.canchaId));
    final slots = ref.watch(grillaProvider(
        TurnosDelDiaArgs(canchaId: widget.canchaId, fecha: _fecha)));

    return SafeArea(
      child: Column(
        children: [
          cancha.when(
            data: (c) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                c?.nombre ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borde),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _fecha.isAfter(_hoy)
                        ? () => setState(() =>
                            _fecha = _fecha.subtract(const Duration(days: 1)))
                        : null,
                  ),
                  Text(
                    DateFormat("EEEE d 'de' MMMM", 'es').format(_fecha),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(
                        () => _fecha = _fecha.add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: slots.when(
              data: (lista) => GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  final slot = lista[i];
                  final esHoy = _fecha.isAtSameMomentAs(_hoy);
                  final yaPaso = esHoy && slot.hora <= DateTime.now().hour;
                  return _BloqueHorario(
                    slot: slot,
                    yaPaso: yaPaso,
                    onTap: (slot.disponible && !yaPaso)
                        ? () => context.push('/cliente/confirmar', extra: {
                              'canchaId': widget.canchaId,
                              'fecha': _fecha,
                              'hora': slot.hora,
                              'esNocturno': slot.esNocturno,
                            })
                        : null,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('No se pudo cargar la grilla: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueHorario extends StatelessWidget {
  const _BloqueHorario({
    required this.slot,
    required this.onTap,
    this.yaPaso = false,
  });
  final SlotGrilla slot;
  final VoidCallback? onTap;
  final bool yaPaso;

  @override
  Widget build(BuildContext context) {
    late Color fondo;
    late Color texto;
    late Color borde;
    late String etiqueta;

    switch (slot.estado) {
      case EstadoSlot.libre:
        fondo = Colors.white;
        texto = AppColors.primario;
        borde = AppColors.primario;
        etiqueta = 'Libre';
        break;
      case EstadoSlot.ocupadoPuntual:
        fondo = const Color(0xFFFFF4E5);
        texto = const Color(0xFFB45309);
        borde = const Color(0xFFF5D9AE);
        etiqueta = slot.etiqueta ?? 'Ocupado';
        break;
      case EstadoSlot.ocupadoFijo:
        fondo = AppColors.fijoFondo;
        texto = AppColors.fijoAccent;
        borde = AppColors.fijoAccent;
        etiqueta = '${slot.etiqueta ?? 'Fijo'} · FIJO';
        break;
      case EstadoSlot.bloqueado:
        fondo = const Color(0xFFE4E4E7);
        texto = const Color(0xFF52525B);
        borde = const Color(0xFFD4D4D8);
        etiqueta = slot.etiqueta ?? 'Bloqueado';
        break;
    }

    if (yaPaso) {
      fondo = const Color(0xFFFAFAFA);
      texto = const Color(0xFFC7C7CC);
      borde = const Color(0xFFEFEFF1);
      etiqueta = 'Pasado';
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borde),
        ),
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${slot.hora}:00',
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 11, color: texto),
            ),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: texto),
            ),
          ],
        ),
      ),
    );
  }
}
