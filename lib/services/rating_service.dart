import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import 'user_service.dart';
import 'service_service.dart';

class RatingService {
  final CollectionReference _ratingsCollection =
      FirebaseFirestore.instance.collection('ratings');
  final UserService _userService = UserService();
  final ServiceService _serviceService = ServiceService();

  // ============== CREAR RATING ==============
  Future<void> createRating(RatingModel rating) async {
    try {
      // 1. Validar score
      if (!rating.isValidScore) {
        throw 'La valoración debe ser entre 1 y 5';
      }

      // 2. Verificar que no haya valorado ya este servicio
      final existingRating = await _ratingsCollection
          .where('serviceId', isEqualTo: rating.serviceId)
          .where('userId', isEqualTo: rating.userId)
          .limit(1)
          .get();

      if (existingRating.docs.isNotEmpty) {
        throw 'Ya has valorado este servicio';
      }

      // 3. Crear rating
      await _ratingsCollection.add(rating.toMap());

      // 4. Actualizar rating del proveedor
      await _userService.updateUserRating(rating.providerId);

      // 5. Actualizar rating del servicio
      await _serviceService.updateServiceRating(rating.serviceId);
    } catch (e) {
      throw 'Error al crear valoración: $e';
    }
  }

  // ============== OBTENER RATINGS DE UN PROVEEDOR ==============
  Future<List<RatingModel>> getProviderRatings(String providerId) async {
    try {
      final query = await _ratingsCollection
          .where('providerId', isEqualTo: providerId)
          .limit(50)
          .get();

      final ratings =
          query.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ratings;
    } catch (e) {
      throw 'Error al obtener valoraciones: $e';
    }
  }

  // ============== OBTENER RATINGS DE UN SERVICIO ==============
  Future<List<RatingModel>> getServiceRatings(String serviceId) async {
    try {
      final query = await _ratingsCollection
          .where('serviceId', isEqualTo: serviceId)
          .limit(50)
          .get();

      final ratings =
          query.docs.map((doc) => RatingModel.fromFirestore(doc)).toList();
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ratings;
    } catch (e) {
      throw 'Error al obtener valoraciones: $e';
    }
  }

  // ============== OBTENER RATINGS (STREAM) ==============
  Stream<List<RatingModel>> getServiceRatingsStream(String serviceId) {
    return _ratingsCollection
        .where('serviceId', isEqualTo: serviceId)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) {
            final ratings = snapshot.docs
                .map((doc) => RatingModel.fromFirestore(doc))
                .toList();
            ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ratings;
          },
        );
  }

  // ============== ELIMINAR RATING ==============
  Future<void> deleteRating(String ratingId, String providerId) async {
    try {
      await _ratingsCollection.doc(ratingId).delete();

      // Actualizar rating del proveedor
      await _userService.updateUserRating(providerId);
    } catch (e) {
      throw 'Error al eliminar valoración: $e';
    }
  }

  // ============== VERIFICAR SI USUARIO YA VALORÓ ==============
  Future<bool> hasUserRatedService({
    required String userId,
    required String serviceId,
  }) async {
    try {
      final query = await _ratingsCollection
          .where('serviceId', isEqualTo: serviceId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ============== CALCULAR PROMEDIO (HELPER) ==============
  double calculateAverage(List<RatingModel> ratings) {
    if (ratings.isEmpty) return 0.0;

    final total = ratings.fold<int>(0, (sum, rating) => sum + rating.score);
    return total / ratings.length;
  }

  // ============== OBTENER DISTRIBUCIÓN DE RATINGS ==============
  Future<Map<int, int>> getRatingDistribution(String providerId) async {
    try {
      final ratings = await getProviderRatings(providerId);

      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var rating in ratings) {
        distribution[rating.score] = (distribution[rating.score] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      throw 'Error al obtener distribución: $e';
    }
  }
}
