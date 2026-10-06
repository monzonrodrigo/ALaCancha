import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/cancha.dart';
import '../../models/turno_fijo.dart';
import '../../providers/auth_providers.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/configuracion_providers.dart';
import '../../providers/repository_providers.dart';

class NuevoTurnoFijoScreen extends ConsumerStatefulWidget {
  const NuevoTurnoFijoScreen({super.key});

  @override
  ConsumerState<NuevoTurnoFijoScreen> createState() =>
      _NuevoTurnoFijoScreenState();
}

class _NuevoTurnoFijoScreenState
    extends ConsumerState<NuevoTurnoFijoScreen> {
  static const _nombresDia = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  Cancha? _canchaSeleccionada;
  int _diaSemana = 1;
  int? _horaSeleccionada;
  final _equipoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _equipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canchas = ref.watch(canchasActivasProvider);
    final configuracion = ref.watch(configuracionProvider);
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;

    return SafeArea(
      child: canchas.when(
        data: (lista) {
          _canchaSeleccionada ??= lista.isNotEmpty ? lista.first : null;

          return configuracion.when(
            data: (config) {
              final horas = [
                for (
                  var h = config.horaAperturaPredio;
                  h < config.horaCierrePredio;
                  h++
                )
                  h
              ];

              _horaSeleccionada ??= horas.isNotEmpty ? horas.first : null;

              final esNocturno = _horaSeleccionada != null &&
                  config.horaEsNocturna(_horaSeleccionada!);

              final precio = _canchaSeleccionada?.precioSegunHorario(
                    esNocturno: esNocturno,
                  ) ??
                  0;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Cancha',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Cancha>(
                    initialValue: _canchaSeleccionada,
                    items: lista
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (c) =>
                        setState(() => _canchaSeleccionada = c),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Dia de la semana',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _nombresDia.length; i++)
                        ChoiceChip(
                          label: Text(_nombresDia[i]),
                          selected: _diaSemana == i + 1,
                          onSelected: (_) =>
                              setState(() => _diaSemana = i + 1),
                          selectedColor: AppColors.fijoFondo,
                          labelStyle: TextStyle(
                            color: _diaSemana == i + 1
                                ? AppColors.fijoAccent
                                : AppColors.texto,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Horario (bloques de 1 hora)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final h in horas)
                        ChoiceChip(
                          label: Text('$h:00'),
                          selected: _horaSeleccionada == h,
                          onSelected: (_) =>
                              setState(() => _horaSeleccionada = h),
                          selectedColor: AppColors.fijoFondo,
                          labelStyle: TextStyle(
                            color: _horaSeleccionada == h
                                ? AppColors.fijoAccent
                                : AppColors.texto,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _equipoController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del equipo (opcional)',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.fijoFondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precio por semana',
                          style: TextStyle(
                            color: AppColors.fijoAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\$${precio.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.fijoAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.fijoAccent,
                    ),
                    onPressed: _cargando ||
                            _canchaSeleccionada == null ||
                            _horaSeleccionada == null ||
                            usuario == null
                        ? null
                        : () async {
                            setState(() => _cargando = true);

                            try {
                              await ref
                                  .read(turnosFijosRepositoryProvider)
                                  .crearTurnoFijo(
                                    TurnoFijo(
                                      id: '',
                                      canchaId: _canchaSeleccionada!.id,
                                      clienteId: usuario.uid,
                                      clienteNombre: usuario.nombre,
                                      equipo:
                                          _equipoController.text.trim().isEmpty
                                              ? null
                                              : _equipoController.text.trim(),
                                      diaSemana: _diaSemana,
                                      horaInicio: _horaSeleccionada!,
                                      precio: precio,
                                      estado: EstadoTurnoFijo.vigente,
                                      creadoEn: DateTime.now(),
                                    ),
                                  );

                              if (context.mounted) {
                                context.go('/cliente/mis-turnos');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No se pudo crear el turno fijo: $e',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _cargando = false);
                              }
                            }
                          },
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Crear turno fijo'),
                  ),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('No se pudo cargar la configuracion: $e'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('No se pudieron cargar las canchas: $e'),
        ),
      ),
    );
  }
}