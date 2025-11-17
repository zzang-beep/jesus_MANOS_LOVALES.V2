import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _servicesCollection =>
      _firestore.collection('services');

  // ============== BÚSQUEDA SIMPLE POR TÍTULO ==============
  Future<List<ServiceModel>> searchByTitle(String query) async {
    try {
      if (query.isEmpty) return [];

      // Firestore no soporta búsqueda full-text, entonces usamos startAt/endAt
      final lowerQuery = query.toLowerCase();

      final result = await _servicesCollection
          .where('active', isEqualTo: true)
          .orderBy('title')
          .startAt([lowerQuery])
          .endAt(['$lowerQuery\uf8ff'])
          .limit(20)
          .get();

      return result.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
    } catch (e) {
      // Si falla, buscar client-side
      return await _searchClientSide(query);
    }
  }

  // ============== BÚSQUEDA CLIENT-SIDE (Fallback) ==============
  Future<List<ServiceModel>> _searchClientSide(String query) async {
    try {
      final allServices = await _servicesCollection
          .where('active', isEqualTo: true)
          .limit(100)
          .get();

      final lowerQuery = query.toLowerCase();

      return allServices.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .where(
            (service) =>
                service.title.toLowerCase().contains(lowerQuery) ||
                service.description.toLowerCase().contains(lowerQuery) ||
                service.providerName.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      throw 'Error en búsqueda: $e';
    }
  }

  // ============== FILTRAR POR CATEGORÍA Y LOCALIDAD ==============
  Future<List<ServiceModel>> filterServices({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int limit = 20,
  }) async {
    try {
      Query query = _servicesCollection.where('active', isEqualTo: true);

      // Filtro por categoría
      if (category != null && category.isNotEmpty && category != 'todos') {
        query = query.where('category', isEqualTo: category);
      }

      // Ordenar por fecha
      query = query.limit(limit);

      final result = await query.get();
      List<ServiceModel> services =
          result.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();

      // Filtros adicionales client-side
      if (location != null && location.isNotEmpty) {
        services = services
            .where(
              (s) =>
                  s.locationText.toLowerCase().contains(location.toLowerCase()),
            )
            .toList();
      }

      if (minPrice != null) {
        services = services
            .where((s) => s.price != null && s.price! >= minPrice)
            .toList();
      }

      if (maxPrice != null) {
        services = services
            .where((s) => s.price != null && s.price! <= maxPrice)
            .toList();
      }

      return services;
    } catch (e) {
      throw 'Error al filtrar servicios: $e';
    }
  }

  // ============== BÚSQUEDA AVANZADA ==============
  Future<List<ServiceModel>> advancedSearch({
    String? searchText,
    String? category,
    String? location,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'recent', // 'recent', 'rating', 'price_low', 'price_high'
    int limit = 20,
  }) async {
    try {
      // 1. Obtener servicios con filtros básicos
      List<ServiceModel> services = await filterServices(
        category: category,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: 100, // Obtener más para filtrar después
      );

      // 2. Filtrar por texto de búsqueda
      if (searchText != null && searchText.isNotEmpty) {
        final lowerQuery = searchText.toLowerCase();
        services = services
            .where(
              (service) =>
                  service.title.toLowerCase().contains(lowerQuery) ||
                  service.description.toLowerCase().contains(lowerQuery) ||
                  service.providerName.toLowerCase().contains(lowerQuery) ||
                  service.category.toLowerCase().contains(lowerQuery),
            )
            .toList();
      }

      // 3. Filtrar por rating mínimo
      if (minRating != null) {
        services = services.where((s) => s.ratingAvg >= minRating).toList();
      }

      // 4. Ordenar según criterio
      switch (sortBy) {
        case 'rating':
          services.sort((a, b) {
            if (b.ratingCount == 0 && a.ratingCount == 0) return 0;
            if (b.ratingCount == 0) return -1;
            if (a.ratingCount == 0) return 1;
            return b.ratingAvg.compareTo(a.ratingAvg);
          });
          break;
        case 'price_low':
          services.sort((a, b) {
            if (a.price == null) return 1;
            if (b.price == null) return -1;
            return a.price!.compareTo(b.price!);
          });
          break;
        case 'price_high':
          services.sort((a, b) {
            if (a.price == null) return 1;
            if (b.price == null) return -1;
            return b.price!.compareTo(a.price!);
          });
          break;
        case 'recent':
        default:
          services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      // 5. Limitar resultados
      return services.take(limit).toList();
    } catch (e) {
      throw 'Error en búsqueda avanzada: $e';
    }
  }

  // ============== AUTOCOMPLETADO ==============
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final services = await searchByTitle(query);

      // Retornar títulos únicos
      return services.map((s) => s.title).toSet().take(5).toList();
    } catch (e) {
      return [];
    }
  }

  // ============== SERVICIOS RELACIONADOS ==============
  Future<List<ServiceModel>> getRelatedServices(
    String serviceId,
    String category, {
    int limit = 5,
  }) async {
    try {
      final services = await _servicesCollection
          .where('category', isEqualTo: category)
          .where('active', isEqualTo: true)
          .orderBy('ratingAvg', descending: true)
          .limit(limit + 1) // +1 para excluir el actual
          .get();

      return services.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .where((service) => service.serviceId != serviceId)
          .take(limit)
          .toList();
    } catch (e) {
      throw 'Error al obtener servicios relacionados: $e';
    }
  }

  // ============== BÚSQUEDA POR PROXIMIDAD (Para v2 con geolocalización) ==============
  // Esta función es un placeholder para cuando implementen geolocalización
  Future<List<ServiceModel>> searchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    // TODO: Implementar con GeoFlutterFire en v2
    throw 'Búsqueda por proximidad no implementada en MVP';
  }
}
