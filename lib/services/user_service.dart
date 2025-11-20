import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // ============== OBTENER USUARIO POR ID ==============
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener usuario: $e';
    }
  }

  // ============== OBTENER USUARIO (STREAM) ==============
  Stream<UserModel?> getUserStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ============== ACTUALIZAR PERFIL ==============
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? bio,
    String? role,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (role != null) updates['role'] = role;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isEmpty) return;

      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw 'Error al actualizar perfil: $e';
    }
  }

  // ============== ACTUALIZAR RATING DEL USUARIO ==============
  Future<void> updateUserRating(String userId) async {
    try {
      // 1. Obtener todos los ratings del usuario como proveedor
      final ratingsQuery = await _firestore
          .collection('ratings')
          .where('providerId', isEqualTo: userId)
          .get();

      if (ratingsQuery.docs.isEmpty) {
        // Si no hay ratings, poner en 0
        await _usersCollection.doc(userId).update({
          'ratingAvg': 0.0,
          'ratingCount': 0,
        });
        return;
      }

      // 2. Calcular promedio
      double totalScore = 0;
      for (var doc in ratingsQuery.docs) {
        totalScore +=
            (((doc.data() as Map<String, dynamic>?)?['score'] ?? 0) as num)
                .toDouble();
      }

      final avg = totalScore / ratingsQuery.docs.length;
      final count = ratingsQuery.docs.length;

      // 3. Actualizar usuario
      await _usersCollection.doc(userId).update({
        'ratingAvg': double.parse(avg.toStringAsFixed(1)),
        'ratingCount': count,
      });
    } catch (e) {
      throw 'Error al actualizar rating: $e';
    }
  }

  // ============== BUSCAR USUARIOS POR ROL ==============
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final query = await _usersCollection
          .where('role', isEqualTo: role)
          .where('active', isEqualTo: true)
          .limit(50)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error al buscar usuarios: $e';
    }
  }

  // ============== OBTENER PROVEEDORES DESTACADOS ==============
  Future<List<UserModel>> getTopProviders({int limit = 10}) async {
    try {
      final query = await _usersCollection
          .where('role', whereIn: ['provider', 'both'])
          .where('active', isEqualTo: true)
          .orderBy('ratingAvg', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Error al obtener proveedores: $e';
    }
  }

  // ============== DESACTIVAR USUARIO ==============
  Future<void> deactivateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({'active': false});
    } catch (e) {
      throw 'Error al desactivar usuario: $e';
    }
  }

  // ============== REACTIVAR USUARIO ==============
  Future<void> reactivateUser(String userId) async {
    try {
      await _usersCollection.doc(userId).update({'active': true});
    } catch (e) {
      throw 'Error al reactivar usuario: $e';
    }
  }

  // ============== ELIMINAR USUARIO COMPLETAMENTE ==============
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw 'Error al eliminar usuario: $e';
    }
  }
}
