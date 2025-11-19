import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneVerificationService {
  String? _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Envía el OTP y espera hasta que se dispare codeSent (o falla).
  Future<void> sendOTP(String phone) async {
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // A veces se verifica automáticamente (simulación en Android)
        try {
          // Si hay user logueado, linkear; sino loguear con el credential.
          final user = _auth.currentUser;
          if (user != null) {
            await user.linkWithCredential(credential);
            // Actualizar Firestore:
            await _firestore.collection('users').doc(user.uid).update({
              'phoneVerified': true,
            });
          } else {
            await _auth.signInWithCredential(credential);
          }
        } catch (_) {
          // ignorar errores aquí; el flujo seguirá
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Esperamos hasta que se haya llamado a codeSent / completed / failed / timeout
    return completer.future;
  }

  /// Verifica el código ingresado por el usuario.
  /// Intenta linkear la credencial con el usuario actualmente autenticado (email).
  Future<bool> verifyCode(String smsCode) async {
    if (_verificationId == null) return false;

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Intentar linkear la credencial al usuario actual
        try {
          await currentUser.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          // Si la credencial ya esté en uso o ya vinculada, intentar hacer signIn
          if (e.code == 'credential-already-in-use' ||
              e.code == 'provider-already-linked') {
            await _auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }

        // Marcar verificado en Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'phoneVerified': true,
        });
        return true;
      } else {
        // No hay usuario actual: sólo sign in
        await _auth.signInWithCredential(credential);

        // Si se logueó con ese número, marcar en Firestore si existe doc
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          final docRef = _firestore.collection('users').doc(uid);
          final doc = await docRef.get();
          if (doc.exists) {
            await docRef.update({'phoneVerified': true});
          }
        }
        return true;
      }
    } catch (e) {
      // Error al verificar el código
      return false;
    }
  }

  /// Permite reenviar el OTP si hace falta — sólo reusamos sendOTP
  Future<void> resendOTP(String phone) async {
    // Puedes aplicar rate limiting a nivel UI antes de llamar acá
    await sendOTP(phone);
  }
}
