import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/cupon.dart';
import '../../providers/cupones_providers.dart';

class CuponesAdminScreen extends ConsumerWidget {
  const CuponesAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cupones = ref.watch(todosLosCuponesProvider);

    return cupones.when(
      data: (lista) {
        if (lista.isEmpty) {
          return const Center(
            child: Text('Todavia no se genero ningun cupon.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: lista.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = lista[i];
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
                        Text(
                          c.codigo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${c.porcentaje.toStringAsFixed(0)}% off a los ${c.partidosAcumulados} partidos',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Generado el ${DateFormat("d 'de' MMMM", 'es').format(c.creadoEn)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EstadoCuponBadge(estado: c.estado),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('No se pudieron cargar los cupones: $e')),
    );
  }
}

class EstadoCuponBadge extends StatelessWidget {
  const EstadoCuponBadge({super.key, required this.estado});
  final EstadoCupon estado;

  @override
  Widget build(BuildContext context) {
    late final Color fondo;
    late final Color texto;
    late final String etiqueta;

    switch (estado) {
      case EstadoCupon.disponible:
        fondo = const Color(0xFFEAF3EC);
        texto = const Color(0xFF235C2F);
        etiqueta = 'Disponible';
        break;
      case EstadoCupon.usado:
        fondo = const Color(0xFFE4E4E7);
        texto = const Color(0xFF52525B);
        etiqueta = 'Usado';
        break;
      case EstadoCupon.vencido:
        fondo = const Color(0xFFFDECEC);
        texto = AppColors.peligro;
        etiqueta = 'Vencido';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        etiqueta,
        style: TextStyle(
          color: texto,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
