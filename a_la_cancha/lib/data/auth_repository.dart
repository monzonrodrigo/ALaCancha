import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

import '../core/constants/firestore_paths.dart';
import '../models/usuario.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get cambiosDeSesion => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _firestore.collection(FirestorePaths.usuarios);

  Future<Usuario> registrarConEmail({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credencial.user!.updateDisplayName(nombre);

    final usuario = Usuario(
      uid: credencial.user!.uid,
      nombre: nombre,
      email: email,
      rol: RolUsuario.cliente,
      creadoEn: DateTime.now(),
    );
    await _usuariosRef.doc(usuario.uid).set(usuario.toMap());
    return usuario;
  }

  Future<UserCredential> iniciarSesionConEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> iniciarSesionConGoogle() async {
    final cuentaGoogle = await _googleSignIn.signIn();
    if (cuentaGoogle == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelado',
        message: 'Se cancelo el inicio de sesion con Google.',
      );
    }
    final autenticacionGoogle = await cuentaGoogle.authentication;
    final credencial = GoogleAuthProvider.credential(
      accessToken: autenticacionGoogle.accessToken,
      idToken: autenticacionGoogle.idToken,
    );
    final resultado = await _auth.signInWithCredential(credencial);
    await _asegurarDocumentoUsuario(resultado.user!);
    return resultado;
  }

  Future<UserCredential> iniciarSesionConApple() async {
    final rawNonce = _generarNonce();
    final nonceHasheado = sha256.convert(utf8.encode(rawNonce)).toString();

    final credencialApple = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonceHasheado,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: credencialApple.identityToken,
      rawNonce: rawNonce,
    );

    final resultado = await _auth.signInWithCredential(oauthCredential);

    final nombreApple = [
      credencialApple.givenName,
      credencialApple.familyName,
    ].where((parte) => parte != null && parte.isNotEmpty).join(' ');
    if (nombreApple.isNotEmpty) {
      await resultado.user!.updateDisplayName(nombreApple);
    }

    await _asegurarDocumentoUsuario(resultado.user!);
    return resultado;
  }

  Future<void> cerrarSesion() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> _asegurarDocumentoUsuario(User user) async {
    final doc = await _usuariosRef.doc(user.uid).get();
    if (doc.exists) return;

    final usuario = Usuario(
      uid: user.uid,
      nombre: user.displayName ?? 'Sin nombre',
      email: user.email ?? '',
      rol: RolUsuario.cliente,
      creadoEn: DateTime.now(),
    );
    await _usuariosRef.doc(user.uid).set(usuario.toMap());
  }

  String _generarNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}