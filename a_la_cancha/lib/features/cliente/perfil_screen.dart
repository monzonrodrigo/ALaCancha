import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dialogo_confirmacion.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repository_providers.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _editando = false;
  bool _guardando = false;
  String? _ultimoUidCargado;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider).valueOrNull;

    if (usuario != null && usuario.uid != _ultimoUidCargado) {
      _nombreController.text = usuario.nombre;
      _telefonoController.text = usuario.telefono ?? '';
      _ultimoUidCargado = usuario.uid;
    }

    if (usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEAF3EC),
              child: Text(
                usuario.nombre.isNotEmpty
                    ? usuario.nombre[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primario,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nombreController,
            enabled: _editando,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            enabled: false,
            controller: TextEditingController(text: usuario.email),
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefonoController,
            enabled: _editando,
            keyboardType: TextInputType.phone,
            decoration:
                const InputDecoration(labelText: 'Telefono (opcional)'),
          ),
          const SizedBox(height: 20),
          if (!_editando)
            OutlinedButton.icon(
              onPressed: () => setState(() => _editando = true),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar perfil'),
            )
          else
            ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      setState(() => _guardando = true);

                      await ref
                          .read(usuariosRepositoryProvider)
                          .actualizarPerfil(
                            usuario.copyWith(
                              nombre: _nombreController.text.trim(),
                              telefono:
                                  _telefonoController.text.trim().isEmpty
                                      ? null
                                      : _telefonoController.text.trim(),
                            ),
                          );

                      if (mounted) {
                        setState(() {
                          _editando = false;
                          _guardando = false;
                        });
                      }
                    },
              child: _guardando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar cambios'),
            ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.peligro,
              side: const BorderSide(color: AppColors.peligro),
            ),
            onPressed: () async {
              final confirmar = await mostrarDialogoConfirmacion(
                context,
                titulo: 'Cerrar sesion?',
                mensaje: 'Vas a salir de tu cuenta.',
                textoBotonConfirmar: 'Cerrar sesion',
              );

              if (confirmar) {
                await ref.read(authRepositoryProvider).cerrarSesion();
              }
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }
}