import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _servicesCollection =
      FirebaseFirestore.instance.collection('services');

  Future<String> createService({
    required ServiceModel service,
    required UserModel provider,
  }) async {
    try {
      final serviceData = service.copyWith(updatedAt: DateTime.now());

      final docRef = await _servicesCollection.add(serviceData.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Error al crear servicio: $e';
    }
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _servicesCollection.doc(serviceId).get();
      if (!doc.exists) return null;
      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener servicio: $e';
    }
  }

  Future<List<ServiceModel>> getAllServices({int limit = 20}) async {
    try {
      final query = await _servicesCollection
          .where('active', isEqualTo: true)
          .limit(limit)
          .get();

      final services =
          query.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
      services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return services;
    } catch (e) {
      throw 'Error al obtener servicios: $e';
    }
  }

  Future<List<ServiceModel>> getServicesByCategory(
    String category, {
    int limit = 20,
  }) async {
    try {
      final query = await _servicesCollection
          .where('category', isEqualTo: category)
          .where('active', isEqualTo: true)
          .limit(limit)
          .get();

      final services =
          query.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
      services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return services;
    } catch (e) {
      throw 'Error al obtener servicios: $e';
    }
  }

  Future<List<ServiceModel>> getProviderServices(String providerId) async {
    try {
      final result = await _servicesCollection
          .where('providerId', isEqualTo: providerId)
          .where('active', isEqualTo: true)
          .get();

      final services =
          result.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
      services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return services;
    } catch (e) {
      throw 'Error al obtener servicios del proveedor: $e';
    }
  }

  Future<void> updateServiceRating(String serviceId) async {
    try {
      final ratingsQuery = await _firestore
          .collection('ratings')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      if (ratingsQuery.docs.isEmpty) {
        await _servicesCollection.doc(serviceId).update({
          'ratingAvg': 0.0,
          'ratingCount': 0,
        });
        return;
      }

      double totalScore = 0;
      for (var doc in ratingsQuery.docs) {
        totalScore +=
            (((doc.data() as Map<String, dynamic>?)?['score'] ?? 0) as num)
                .toDouble();
      }

      final avg = totalScore / ratingsQuery.docs.length;
      final count = ratingsQuery.docs.length;

      await _servicesCollection.doc(serviceId).update({
        'ratingAvg': double.parse(avg.toStringAsFixed(1)),
        'ratingCount': count,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error al actualizar rating: $e';
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'active': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error al eliminar servicio: $e';
    }
  }

  // FUNCIÓN FALTANTE - AGREGAR A service_service.dart
  Future<void> updateServiceStatus(String serviceId, String status) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error al actualizar estado: $e';
    }
  }

  Future<void> completeService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'active': false,
        'status': 'completed',
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error al completar servicio: $e';
    }
  }
}
