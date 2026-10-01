import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogo_confirmacion.dart';
import '../../models/turno.dart';
import '../../providers/configuracion_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/turnos_fijos_providers.dart';
import '../../providers/turnos_providers.dart';

class MisTurnosScreen extends ConsumerWidget {
  const MisTurnosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                const Expanded(
                  child: TabBar(
                    tabs: [Tab(text: 'Proximos'), Tab(text: 'Historial')],
                    labelColor: AppColors.texto,
                    indicatorColor: AppColors.primario,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: () => context.go('/cliente/nuevo-turno-fijo'),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.fijoFondo,
                      foregroundColor: AppColors.fijoAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Turno fijo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [_ListaProximos(), _ListaHistorial()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaProximos extends ConsumerWidget {
  const _ListaProximos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnos = ref.watch(misTurnosProvider);
    final turnosFijos = ref.watch(misTurnosFijosProvider);
    final configuracion = ref.watch(configuracionProvider).valueOrNull;
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    if (turnos.isLoading || turnosFijos.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final proximos = (turnos.valueOrNull ?? [])
        .where((t) => t.estado == EstadoTurno.confirmado && !t.fecha.isBefore(hoySinHora))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final fijos = turnosFijos.valueOrNull ?? [];

    if (proximos.isEmpty && fijos.isEmpty) {
      return const Center(child: Text('Todavia no tenes turnos reservados.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final t in proximos)
          _TurnoCard(
            titulo: DateFormat("EEEE d 'de' MMM", 'es').format(t.fecha),
            subtitulo: '${t.horaInicio}:00 a ${t.horaFin}:00 · ${t.esNocturno ? 'Nocturno' : 'Diurno'}',
            equipo: t.equipo,
            esFijo: false,
            onAccion: () async {
              final minAnticipacion = configuracion?.minutosMinimoCancelacion ?? 180;
              final horaTurno = DateTime(t.fecha.year, t.fecha.month, t.fecha.day, t.horaInicio);
              final quedaTiempo = horaTurno.difference(DateTime.now()).inMinutes >= minAnticipacion;

              final confirmar = await mostrarDialogoConfirmacion(
                context,
                titulo: 'Cancelar turno?',
                mensaje: 'Vas a cancelar el turno del ${DateFormat("EEEE d 'de' MMM", 'es').format(t.fecha)} de ${t.horaInicio}:00 a ${t.horaFin}:00.',
                textoBotonConfirmar: 'Cancelar turno',
                avisoNeutral: quedaTiempo
                    ? 'El horario queda libre para otras reservas.'
                    : 'Estas dentro de la ventana minima de cancelacion: podrias perder la sena segun la politica del predio.',
              );
              if (confirmar) {
                await ref.read(turnosRepositoryProvider).cancelarTurno(t.id);
              }
            },
          ),
        for (final f in fijos)
          _TurnoCard(
            titulo: '${f.nombreDia}, ${f.horaInicio}:00',
            subtitulo: 'Todas las semanas · 1 hora',
            equipo: f.equipo,
            esFijo: true,
            onAccion: () async {
              final confirmar = await mostrarDialogoConfirmacion(
                context,
                titulo: 'Dar de baja este turno fijo?',
                mensaje: 'Vas a dar de baja tu turno fijo de los ${f.nombreDia.toLowerCase()} de ${f.horaInicio}:00 a ${f.horaFin}:00.',
                textoBotonConfirmar: 'Dar de baja turno fijo',
                avisoNeutral: 'El horario queda liberado para otros clientes a partir de la proxima semana.',
              );
              if (confirmar) {
                await ref.read(turnosFijosRepositoryProvider).darDeBaja(f.id);
              }
            },
          ),
      ],
    );
  }
}

class _ListaHistorial extends ConsumerWidget {
  const _ListaHistorial();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnos = ref.watch(misTurnosProvider);
    final hoy = DateTime.now();
    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);

    return turnos.when(
      data: (lista) {
        final historial = lista
            .where((t) => t.estado == EstadoTurno.cancelado || t.fecha.isBefore(hoySinHora))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        if (historial.isEmpty) {
          return const Center(child: Text('Todavia no tenes turnos en el historial.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: historial.length,
          itemBuilder: (context, i) {
            final t = historial[i];
            return _TurnoCard(
              titulo: DateFormat("EEEE d 'de' MMM", 'es').format(t.fecha),
              subtitulo: '${t.horaInicio}:00 a ${t.horaFin}:00',
              equipo: t.equipo,
              esFijo: false,
              estadoTexto: t.estado == EstadoTurno.cancelado ? 'Cancelado' : 'Jugado',
              onAccion: null,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudo cargar el historial: $e')),
    );
  }
}

class _TurnoCard extends StatelessWidget {
  const _TurnoCard({
    required this.titulo,
    required this.subtitulo,
    required this.equipo,
    required this.esFijo,
    this.estadoTexto,
    required this.onAccion,
  });

  final String titulo;
  final String subtitulo;
  final String? equipo;
  final bool esFijo;
  final String? estadoTexto;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5))),
                    if (esFijo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.fijoFondo, borderRadius: BorderRadius.circular(6)),
                        child: const Text('FIJO', style: TextStyle(color: AppColors.fijoAccent, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
              _Badge(texto: estadoTexto ?? 'Confirmado', color: estadoTexto == 'Cancelado' ? AppColors.peligro : AppColors.primario),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(fontSize: 12.5, color: AppColors.textoSecundario)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.textoSecundario),
                  const SizedBox(width: 6),
                  Text(equipo ?? 'Sin equipo cargado', style: const TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
                ],
              ),
              if (onAccion != null)
                TextButton.icon(
                  onPressed: onAccion,
                  style: TextButton.styleFrom(foregroundColor: AppColors.peligro),
                  icon: const Icon(Icons.close, size: 15),
                  label: Text(esFijo ? 'Dar de baja' : 'Cancelar', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.texto, required this.color});
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(texto, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}