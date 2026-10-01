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
                    onPressed: () => setState(() =>
                        _fecha = _fecha.subtract(const Duration(days: 1))),
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
                itemBuilder: (context, i) => _BloqueHorario(
                  slot: lista[i],
                  onTap: lista[i].disponible
                      ? () => context.push('/cliente/confirmar', extra: {
                            'canchaId': widget.canchaId,
                            'fecha': _fecha,
                            'hora': lista[i].hora,
                            'esNocturno': lista[i].esNocturno,
                          })
                      : null,
                ),
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
  const _BloqueHorario({required this.slot, required this.onTap});
  final SlotGrilla slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    late final Color fondo;
    late final Color texto;
    late final String etiqueta;

    switch (slot.estado) {
      case EstadoSlot.libre:
        fondo = AppColors.fondo;
        texto = const Color(0xFFD4D4D8);
        etiqueta = 'Libre';
        break;
      case EstadoSlot.ocupadoPuntual:
        fondo = const Color(0xFFEAF3EC);
        texto = const Color(0xFF235C2F);
        etiqueta = slot.etiqueta ?? 'Ocupado';
        break;
      case EstadoSlot.ocupadoFijo:
        fondo = AppColors.fijoFondo;
        texto = AppColors.fijoAccent;
        etiqueta = '${slot.etiqueta ?? 'Fijo'} · FIJO';
        break;
      case EstadoSlot.bloqueado:
        fondo = const Color(0xFFF4F4F5);
        texto = const Color(0xFF71717A);
        etiqueta = slot.etiqueta ?? 'Bloqueado';
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(10),
          border: slot.estado == EstadoSlot.libre
              ? Border.all(color: AppColors.borde, style: BorderStyle.solid)
              : null,
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
