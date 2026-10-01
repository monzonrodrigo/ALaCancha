import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/canchas_providers.dart';

class CanchasScreen extends ConsumerWidget {
  const CanchasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canchas = ref.watch(canchasActivasProvider);

    return canchas.when(
      data: (lista) {
        if (lista.isEmpty) {
          return const Center(child: Text('Todavia no hay canchas cargadas.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final cancha = lista[i];
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go('/cliente/grilla/${cancha.id}'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borde),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_soccer, color: AppColors.primario),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cancha.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(
                            '${cancha.superficie.etiqueta} · Diurno \$${cancha.precioDiurno.toStringAsFixed(0)} · Nocturno \$${cancha.precioNocturno.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textoSecundario),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudieron cargar las canchas: $e')),
    );
  }
}