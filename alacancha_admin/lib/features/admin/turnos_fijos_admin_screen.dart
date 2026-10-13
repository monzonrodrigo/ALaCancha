import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogo_confirmacion.dart';
import '../../providers/repository_providers.dart';
import '../../providers/turnos_fijos_providers.dart';

class TurnosFijosAdminScreen extends ConsumerWidget {
  const TurnosFijosAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnosFijos = ref.watch(turnosFijosVigentesProvider);
    return turnosFijos.when(
      data: (lista) {
        if (lista.isEmpty) {
          return const Center(child: Text('No hay turnos fijos vigentes.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final f = lista[i];
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borde),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.equipo ?? f.clienteNombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                        const SizedBox(height: 3),
                        Text(
                          '${f.nombreDia} · ${f.horaInicio}:00 a ${f.horaFin}:00',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFEAF3EC), borderRadius: BorderRadius.circular(999)),
                    child: const Text('Vigente', style: TextStyle(color: Color(0xFF235C2F), fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.peligro),
                    onPressed: () async {
                      final confirmar = await mostrarDialogoConfirmacion(
                        context,
                        titulo: 'Dar de baja este turno fijo?',
                        mensaje: 'Vas a dar de baja el turno fijo de ${f.equipo ?? f.clienteNombre}, los ${f.nombreDia.toLowerCase()} de ${f.horaInicio}:00 a ${f.horaFin}:00.',
                        textoBotonConfirmar: 'Dar de baja turno fijo',
                        avisoNeutral: 'El horario queda liberado para otros clientes a partir de la proxima semana. El cliente va a ser notificado.',
                      );
                      if (confirmar) {
                        await ref.read(turnosFijosRepositoryProvider).darDeBaja(f.id);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudieron cargar los turnos fijos: $e')),
    );
  }
}
