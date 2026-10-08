import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/repository_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion(Future<void> Function() accion) async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await accion();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mensajeError(e.code));
    } catch (e) {
      setState(() => _error = 'Ocurrio un error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contrasena incorrectos.';
      case 'invalid-email':
        return 'El email no es valido.';
      case 'sign-in-cancelado':
        return 'Se cancelo el inicio de sesion.';
      default:
        return 'No se pudo iniciar sesion ($code).';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.sports_soccer,
                        size: 56, color: AppColors.primario),
                    const SizedBox(height: 16),
                    const Text(
                      'Turnos F5',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const Text(
                      'Inicia sesion para reservar tu cancha',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textoSecundario),
                    ),
                    const SizedBox(height: 28),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(color: AppColors.peligro)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Ingresa un email valido'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Contrasena'),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Minimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cargando
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              _iniciarSesion(
                                  () => authRepo.iniciarSesionConEmail(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ));
                            },
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Ingresar'),
                    ),
                    const SizedBox(height: 16),
                    const Row(children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('o continua con',
                            style: TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 12)),
                      ),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _cargando
                          ? null
                          : () =>
                              _iniciarSesion(authRepo.iniciarSesionConGoogle),
                      icon: const Icon(Icons.g_mobiledata, size: 26),
                      label: const Text('Continuar con Google'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _cargando
                          ? null
                          : () =>
                              _iniciarSesion(authRepo.iniciarSesionConApple),
                      icon: const Icon(Icons.apple, size: 22),
                      label: const Text('Continuar con Apple'),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed:
                          _cargando ? null : () => context.push('/registro'),
                      child: const Text('No tenes cuenta? Registrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
