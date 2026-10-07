import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogo_confirmacion.dart';
import '../../models/cancha.dart';
import '../../providers/canchas_providers.dart';
import '../../providers/repository_providers.dart';

class CanchasAdminScreen extends ConsumerWidget {
  const CanchasAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canchas = ref.watch(todasLasCanchasProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva cancha'),
      ),
      body: canchas.when(
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(child: Text('Todavia no cargaste ninguna cancha.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final cancha = lista[i];
              return Container(
                padding: const EdgeInsets.all(16),
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
                          Row(children: [
                            Text(cancha.nombre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            if (!cancha.activa) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF4F4F5), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Inactiva', style: TextStyle(fontSize: 10.5, color: AppColors.textoSecundario)),
                              ),
                            ],
                          ]),
                          const SizedBox(height: 3),
                          Text(
                            '${cancha.superficie.etiqueta} · Diurno \$${cancha.precioDiurno.toStringAsFixed(0)} · Nocturno \$${cancha.precioNocturno.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _abrirFormulario(context, ref, cancha),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.peligro),
                      onPressed: () async {
                        final confirmar = await mostrarDialogoConfirmacion(
                          context,
                          titulo: 'Eliminar cancha?',
                          mensaje: 'Vas a eliminar "${cancha.nombre}" de forma permanente. Esta accion no se puede deshacer.',
                          textoBotonConfirmar: 'Eliminar cancha',
                          avisoNeutral: 'Los turnos ya reservados en esta cancha no se eliminan automaticamente.',
                        );
                        if (confirmar) {
                          await ref.read(canchasRepositoryProvider).eliminarCancha(cancha.id);
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
        error: (e, _) => Center(child: Text('No se pudieron cargar las canchas: $e')),
      ),
    );
  }

  void _abrirFormulario(BuildContext context, WidgetRef ref, Cancha? cancha) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _FormularioCancha(cancha: cancha),
    );
  }
}

class _FormularioCancha extends ConsumerStatefulWidget {
  const _FormularioCancha({this.cancha});
  final Cancha? cancha;

  @override
  ConsumerState<_FormularioCancha> createState() => _FormularioCanchaState();
}

class _FormularioCanchaState extends ConsumerState<_FormularioCancha> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _precioDiurnoController;
  late final TextEditingController _precioNocturnoController;
  late Superficie _superficie;
  late bool _activa;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cancha;
    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _precioDiurnoController = TextEditingController(text: c?.precioDiurno.toStringAsFixed(0) ?? '');
    _precioNocturnoController = TextEditingController(text: c?.precioNocturno.toStringAsFixed(0) ?? '');
    _superficie = c?.superficie ?? Superficie.sintetica;
    _activa = c?.activa ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioDiurnoController.dispose();
    _precioNocturnoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esNueva = widget.cancha == null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(esNueva ? 'Nueva cancha' : 'Editar cancha', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Superficie>(
              initialValue: _superficie,
              decoration: const InputDecoration(labelText: 'Superficie'),
              items: Superficie.values.map((s) => DropdownMenuItem(value: s, child: Text(s.etiqueta))).toList(),
              onChanged: (s) => setState(() => _superficie = s ?? _superficie),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _precioDiurnoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio diurno'),
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Numero invalido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _precioNocturnoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio nocturno'),
                  validator: (v) => (double.tryParse(v ?? '') == null) ? 'Numero invalido' : null,
                ),
              ),
            ]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Activa (visible para clientes)'),
              value: _activa,
              onChanged: (v) => setState(() => _activa = v),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _guardando = true);
                      final repo = ref.read(canchasRepositoryProvider);
                      final datos = Cancha(
                        id: widget.cancha?.id ?? '',
                        nombre: _nombreController.text.trim(),
                        superficie: _superficie,
                        precioDiurno: double.parse(_precioDiurnoController.text),
                        precioNocturno: double.parse(_precioNocturnoController.text),
                        activa: _activa,
                      );
                      if (esNueva) {
                        await repo.crearCanchaNueva(datos);
                      } else {
                        await repo.actualizarCancha(datos);
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: _guardando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(esNueva ? 'Crear cancha' : 'Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}