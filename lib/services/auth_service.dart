import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =====================================================
  // ===============      REGISTRO      ==================
  // =====================================================
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'client',
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Crear documento en Firestore
      final user = UserModel(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        phoneVerified: false,
        verificationCode: '',
        verificationCodeExpiry: null,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.userId).set(user.toMap());

      notifyListeners();
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error al crear cuenta: $e';
    }
  }

  // =====================================================
  // ===============       LOGIN        ===================
  // =====================================================
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw 'Usuario no encontrado en la base de datos';
      }

      notifyListeners();
      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error al iniciar sesión: $e';
    }
  }

  // =====================================================
  // ===============       LOGOUT       ===================
  // =====================================================
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      throw 'Error al cerrar sesión: $e';
    }
  }

  // =====================================================
  // ============ OBTENER DATOS DEL USUARIO ===============
  // =====================================================
  Future<UserModel?> getUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final userDoc =
      await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
  }

  // =====================================================
  // ========== RESTABLECER CONTRASEÑA ====================
  // =====================================================
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // =====================================================
  // ========== VERIFICAR EMAIL ===========================
  // =====================================================
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Error al enviar verificación: $e';
    }
  }

  // =====================================================
  // ========== ELIMINAR CUENTA (SOFT DELETE) =============
  // =====================================================
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) throw 'No hay usuario autenticado';

      await _firestore.collection('users').doc(userId).update({
        'active': false,
      });

      // También puedes eliminar de Firebase Auth:
      // await currentUser?.delete();

      notifyListeners();
    } catch (e) {
      throw 'Error al eliminar cuenta: $e';
    }
  }

  // =====================================================
  // =============== LOGIN DEMO ===========================
  // =====================================================
  Future<UserModel?> signInAsDemo() async {
    return signIn(email: 'demo@manoslocales.com', password: 'demo123456');
  }

  // =====================================================
  // =============== MANEJO DE ERRORES ====================
  // =====================================================
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
