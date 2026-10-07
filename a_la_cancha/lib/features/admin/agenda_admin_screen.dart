import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogo_confirmacion.dart';
import '../../models/cancha.dart';
import '../../models/slot_grilla.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/grilla_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/turnos_providers.dart';

class AgendaAdminScreen extends ConsumerStatefulWidget {
  const AgendaAdminScreen({super.key});

  @override
  ConsumerState<AgendaAdminScreen> createState() => _AgendaAdminScreenState();
}

class _AgendaAdminScreenState extends ConsumerState<AgendaAdminScreen> {
  Cancha? _canchaSeleccionada;
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _fecha = DateTime(ahora.year, ahora.month, ahora.day);
  }

  @override
  Widget build(BuildContext context) {
    final canchas = ref.watch(todasLasCanchasProvider);
    return SafeArea(
      child: canchas.when(
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(child: Text('Todavia no hay canchas cargadas.'));
          }
          _canchaSeleccionada ??= lista.first;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: DropdownButtonFormField<Cancha>(
                 initialValue: lista.contains(_canchaSeleccionada) ? _canchaSeleccionada : lista.first,
                  items: lista.map((c) => DropdownMenuItem(value: c, child: Text(c.nombre))).toList(),
                  onChanged: (c) => setState(() => _canchaSeleccionada = c),
                ),
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
                        onPressed: () => setState(() => _fecha = _fecha.subtract(const Duration(days: 1))),
                      ),
                      Text(
                        DateFormat("EEEE d 'de' MMMM", 'es').format(_fecha),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() => _fecha = _fecha.add(const Duration(days: 1))),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final slots = ref.watch(
                      grillaProvider(TurnosDelDiaArgs(canchaId: _canchaSeleccionada!.id, fecha: _fecha)),
                    );
                    return slots.when(
                      data: (listaSlots) => GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: listaSlots.length,
                        itemBuilder: (context, i) => _BloqueAdmin(
                          slot: listaSlots[i],
                          onCancelar: listaSlots[i].estado == EstadoSlot.ocupadoPuntual
                              ? () async {
                                  final confirmar = await mostrarDialogoConfirmacion(
                                    context,
                                    titulo: 'Cancelar turno?',
                                    mensaje: 'Vas a cancelar el turno de ${listaSlots[i].etiqueta ?? 'este cliente'} en ${_canchaSeleccionada!.nombre}, el ${DateFormat("EEEE d 'de' MMMM", 'es').format(_fecha)} de ${listaSlots[i].hora}:00 a ${listaSlots[i].hora + 1}:00.',
                                    textoBotonConfirmar: 'Cancelar turno',
                                    avisoNeutral: 'El cliente va a ser notificado y el horario queda libre para otras reservas.',
                                  );
                                  if (confirmar && listaSlots[i].referenciaId != null) {
                                    await ref.read(turnosRepositoryProvider).cancelarTurno(listaSlots[i].referenciaId!);
                                  }
                                }
                              : null,
                        ),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('No se pudo cargar la agenda: $e')),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No se pudieron cargar las canchas: $e')),
      ),
    );
  }
}

class _BloqueAdmin extends StatelessWidget {
  const _BloqueAdmin({required this.slot, required this.onCancelar});

  final SlotGrilla slot;
  final VoidCallback? onCancelar;

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
      onTap: onCancelar,
      child: Container(
        decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${slot.hora}:00', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: texto)),
            Text(etiqueta, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: texto)),
          ],
        ),
      ),
    );
  }
}