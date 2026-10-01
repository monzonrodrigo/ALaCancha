import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/cancha.dart';
import '../../models/turno.dart';
import '../../providers/auth_providers.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/turnos_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;
    final canchas = ref.watch(canchasActivasProvider);
    final misTurnos = ref.watch(misTurnosProvider);

    final proximoTurno = misTurnos.valueOrNull
        ?.where((t) =>
            t.estado != EstadoTurno.cancelado && !t.fecha.isBefore(_hoy()))
        .toList()
      ?..sort((a, b) => a.fecha.compareTo(b.fecha));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Hola, ${usuario?.nombre.split(' ').first ?? ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Que cancha reservamos hoy?',
            style: TextStyle(color: AppColors.textoSecundario),
          ),
          const SizedBox(height: 18),
          if (proximoTurno != null && proximoTurno.isNotEmpty)
            _CardProximoTurno(turno: proximoTurno.first),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/cliente/canchas'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Reservar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/cliente/mis-turnos'),
                  icon: const Icon(Icons.event_note_outlined, size: 18),
                  label: const Text('Mis Turnos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BannerTurnoFijo(
            onTap: () => context.go('/cliente/nuevo-turno-fijo'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Canchas del predio',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: canchas.when(
              data: (lista) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _CardCancha(
                  cancha: lista[i],
                  onTap: () => context.go('/cliente/grilla/${lista[i].id}'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('No se pudieron cargar las canchas: $e'),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _hoy() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }
}

class _CardProximoTurno extends StatelessWidget {
  const _CardProximoTurno({required this.turno});

  final Turno turno;

  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
        DateFormat("EEEE d 'de' MMMM", 'es').format(turno.fecha);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.primario, AppColors.primarioOscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TU PROXIMO TURNO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancha · ${turno.esNocturno ? 'Nocturno' : 'Diurno'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 15, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '$fechaFormateada · ${turno.horaInicio}:00 a ${turno.horaFin}:00',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerTurnoFijo extends StatelessWidget {
  const _BannerTurnoFijo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.fijoFondo,
          border: Border.all(color: const Color(0xFFE0DBF5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.fijoAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: AppColors.fijoAccent, fontSize: 12.5),
                  children: [
                    TextSpan(text: 'Jugas siempre el mismo dia y horario? '),
                    TextSpan(
                      text: 'Crea un turno fijo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCancha extends StatelessWidget {
  const _CardCancha({required this.cancha, required this.onTap});

  final Cancha cancha;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borde),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sports_soccer,
                color: AppColors.primario, size: 26),
            const SizedBox(height: 8),
            Text(
              cancha.nombre,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(
              '${cancha.superficie.etiqueta} · desde \$${cancha.precioDiurno.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
