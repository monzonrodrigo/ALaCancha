import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/turnos_repository.dart';
import '../../models/turno.dart';
import '../../providers/auth_providers.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/repository_providers.dart';

class ConfirmarScreen extends ConsumerStatefulWidget {
  const ConfirmarScreen({
    super.key,
    required this.canchaId,
    required this.fecha,
    required this.hora,
    required this.esNocturno,
  });

  final String canchaId;
  final DateTime fecha;
  final int hora;
  final bool esNocturno;

  @override
  ConsumerState<ConfirmarScreen> createState() => _ConfirmarScreenState();
}

class _ConfirmarScreenState extends ConsumerState<ConfirmarScreen> {
  final _equipoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _equipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cancha = ref.watch(canchaPorIdProvider(widget.canchaId));
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;

    return SafeArea(
      child: cancha.when(
        data: (c) {
          if (c == null)
            return const Center(child: Text('No se encontro la cancha.'));
          final precio = c.precioSegunHorario(esNocturno: widget.esNocturno);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.borde),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 6),
                    _fila(
                        Icons.calendar_today,
                        DateFormat("EEEE d 'de' MMMM", 'es')
                            .format(widget.fecha)),
                    _fila(Icons.schedule,
                        '${widget.hora}:00 a ${widget.hora + 1}:00 · ${widget.esNocturno ? 'Nocturno' : 'Diurno'}'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          '\$${precio.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.primario),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _equipoController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del equipo (opcional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando || usuario == null
                    ? null
                    : () async {
                        setState(() => _cargando = true);
                        try {
                          await ref.read(turnosRepositoryProvider).crearTurno(
                                Turno(
                                  id: '',
                                  canchaId: c.id,
                                  clienteId: usuario.uid,
                                  clienteNombre: usuario.nombre,
                                  equipo: _equipoController.text.trim().isEmpty
                                      ? null
                                      : _equipoController.text.trim(),
                                  fecha: widget.fecha,
                                  horaInicio: widget.hora,
                                  esNocturno: widget.esNocturno,
                                  precio: precio,
                                  estado: EstadoTurno.confirmado,
                                  creadoEn: DateTime.now(),
                                ),
                              );
                          if (context.mounted)
                            context.go('/cliente/mis-turnos');
                        } on TurnoNoDisponibleException catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.mensaje)));
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('No se pudo confirmar el turno: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _cargando = false);
                        }
                      },
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirmar turno'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No se pudo cargar la cancha: $e')),
      ),
    );
  }

  Widget _fila(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppColors.textoSecundario),
          const SizedBox(width: 8),
          Text(texto,
              style: const TextStyle(
                  color: AppColors.textoSecundario, fontSize: 13)),
        ],
      ),
    );
  }
}
