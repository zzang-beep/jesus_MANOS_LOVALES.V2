import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import 'rating_service.dart';
import 'service_service.dart';
import 'user_service.dart';

/// Servicio maestro que coordina TODAS las operaciones entre colecciones
class IntegrationService {
  final RatingService _ratingService = RatingService();
  final ServiceService _serviceService = ServiceService();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== CREAR RATING Y ACTUALIZAR TODO ==============
  Future<void> createRatingAndUpdate({
    required String serviceId,
    required String providerId,
    required String userId,
    required String userName,
    required int score,
    String? comment,
  }) async {
    try {
      print('📝 Creando rating...');

      // 1. Crear rating
      final rating = RatingModel(
        serviceId: serviceId,
        providerId: providerId,
        userId: userId,
        userName: userName,
        score: score,
        comment: comment ?? '',
        createdAt: DateTime.now(),
      );

      await _ratingService.createRating(rating);
      print('✅ Rating creado');

      // 2. Actualizar rating del servicio
      await _serviceService.updateServiceRating(serviceId);
      print('✅ Rating del servicio actualizado');

      // 3. Actualizar rating del proveedor
      await _userService.updateUserRating(providerId);
      print('✅ Rating del proveedor actualizado');
    } catch (e) {
      print('❌ Error en createRatingAndUpdate: $e');
      throw 'Error al crear rating integrado: $e';
    }
  }

  // ============== ELIMINAR RATING Y ACTUALIZAR TODO ==============
  Future<void> deleteRatingAndUpdate({
    required String ratingId,
    required String serviceId,
    required String providerId,
  }) async {
    try {
      await _ratingService.deleteRating(ratingId, providerId);
      await _serviceService.updateServiceRating(serviceId);
      await _userService.updateUserRating(providerId);
    } catch (e) {
      throw 'Error al eliminar rating: $e';
    }
  }

  // ============== ACTUALIZAR DATOS DENORMALIZADOS ==============
  Future<void> updateProviderDataInServices(String providerId) async {
    try {
      print('🔄 Actualizando datos denormalizados para proveedor $providerId');

      final provider = await _userService.getUserById(providerId);
      if (provider == null) {
        print('⚠️ Proveedor no encontrado');
        return;
      }

      final services = await _serviceService.getProviderServices(providerId);
      print('📦 Servicios a actualizar: ${services.length}');

      final batch = _firestore.batch();

      for (var service in services) {
        final ref = _firestore.collection('services').doc(service.serviceId);

        batch.update(ref, {
          'providerName': provider.name,
          'providerPhone': provider.phone,
          'providerPhotoUrl': provider.photoUrl,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
      print('✅ Datos denormalizados actualizados');
    } catch (e) {
      print('❌ Error al actualizar datos denormalizados: $e');
      throw 'Error: $e';
    }
  }

  // ============== OBTENER SERVICIO CON PROVEEDOR ==============
  Future<Map<String, dynamic>> getServiceWithProvider(String serviceId) async {
    try {
      final service = await _serviceService.getServiceById(serviceId);
      if (service == null) throw 'Servicio no encontrado';

      final provider = await _userService.getUserById(service.providerId);
      if (provider == null) throw 'Proveedor no encontrado';

      return {'service': service, 'provider': provider};
    } catch (e) {
      throw 'Error: $e';
    }
  }
}
