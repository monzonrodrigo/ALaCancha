import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/configuracion.dart';
import '../../providers/configuracion_providers.dart';
import '../../providers/repository_providers.dart';

class ConfiguracionAdminScreen extends ConsumerStatefulWidget {
  const ConfiguracionAdminScreen({super.key});

  @override
  ConsumerState<ConfiguracionAdminScreen> createState() => _ConfiguracionAdminScreenState();
}

class _ConfiguracionAdminScreenState extends ConsumerState<ConfiguracionAdminScreen> {
  final _minutosController = TextEditingController();
  final _senaController = TextEditingController();
  final _horaNocturnoController = TextEditingController();
  final _horaAperturaController = TextEditingController();
  final _horaCierreController = TextEditingController();
  bool _cargado = false;
  bool _guardando = false;

  void _cargarValores(Configuracion c) {
    if (_cargado) return;
    _minutosController.text = c.minutosMinimoCancelacion.toString();
    _senaController.text = c.porcentajeSena.toStringAsFixed(0);
    _horaNocturnoController.text = c.horaInicioNocturno.toString();
    _horaAperturaController.text = c.horaAperturaPredio.toString();
    _horaCierreController.text = c.horaCierrePredio.toString();
    _cargado = true;
  }

  @override
  void dispose() {
    _minutosController.dispose();
    _senaController.dispose();
    _horaNocturnoController.dispose();
    _horaAperturaController.dispose();
    _horaCierreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final configuracion = ref.watch(configuracionProvider);
    return configuracion.when(
      data: (c) {
        _cargarValores(c);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _campo(_minutosController, 'Ventana minima para cancelar (minutos)'),
            _campo(_senaController, 'Porcentaje de sena que se pierde si se cancela tarde (%)'),
            _campo(_horaNocturnoController, 'Hora desde la que aplica tarifa nocturna (0-23)'),
            Row(children: [
              Expanded(child: _campo(_horaAperturaController, 'Apertura del predio (hora)')),
              const SizedBox(width: 12),
              Expanded(child: _campo(_horaCierreController, 'Cierre del predio (hora)')),
            ]),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      setState(() => _guardando = true);
                      await ref.read(configuracionRepositoryProvider).actualizarConfiguracion(
                            Configuracion(
                              minutosMinimoCancelacion: int.tryParse(_minutosController.text) ?? c.minutosMinimoCancelacion,
                              porcentajeSena: double.tryParse(_senaController.text) ?? c.porcentajeSena,
                              horaInicioNocturno: int.tryParse(_horaNocturnoController.text) ?? c.horaInicioNocturno,
                              horaAperturaPredio: int.tryParse(_horaAperturaController.text) ?? c.horaAperturaPredio,
                              horaCierrePredio: int.tryParse(_horaCierreController.text) ?? c.horaCierrePredio,
                            ),
                          );
                      if (mounted) {
                        setState(() => _guardando = false);
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('Configuracion guardada.')),
                        );
                      }
                    },
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudo cargar la configuracion: $e')),
    );
  }

  Widget _campo(TextEditingController controller, String etiqueta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: etiqueta),
      ),
    );
  }
}