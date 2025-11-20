import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<CategoryModel> _cachedCategories = [];
  DateTime? _lastFetchTime;
  static const Duration cacheDuration = Duration(minutes: 5);

  // Obtener todas las categorías activas con caché
  Future<List<CategoryModel>> getAllCategories() async {
    // Verificar si tenemos datos en caché y si no han expirado
    if (_cachedCategories.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedCategories;
    }

    try {
      final query = await _db
          .collection('categories')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();

      _cachedCategories = query.docs.map((doc) {
        return CategoryModel.fromMap(doc.id, doc.data());
      }).toList();

      _lastFetchTime = DateTime.now();

      return _cachedCategories;
    } catch (e) {
      print('Error fetching categories: $e');
      // Si hay error pero tenemos caché, devolver caché
      if (_cachedCategories.isNotEmpty) {
        return _cachedCategories;
      }
      throw Exception('No se pudieron cargar las categorías');
    }
  }

  // Obtener categoría por ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    final categories = await getAllCategories();
    return categories.firstWhere(
      (category) => category.categoryId == categoryId,
      orElse: () => CategoryModel(
        categoryId: 'unknown',
        name: 'Desconocido',
        icon: 'help',
        color: '#666666',
        order: 999,
        active: false,
      ),
    );
  }

  // Filtrar categorías por nombre
  Future<List<CategoryModel>> searchCategories(String query) async {
    final categories = await getAllCategories();
    if (query.isEmpty) return categories;

    return categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Obtener categorías populares (las primeras 6 por orden)
  Future<List<CategoryModel>> getPopularCategories() async {
    final categories = await getAllCategories();
    return categories.take(6).toList();
  }

  // Agregar categoría personalizada
  Future<CategoryModel> createCustomCategory(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception("El nombre de la categoría no puede estar vacío.");
    }

    // Crear documento en Firestore para categoría personalizada
    final docRef = await _db.collection('categories_custom').add({
      'name': cleanName,
      'icon': 'edit',
      'color': '#555555',
      'order': 999,
      'active': true,
      'isCustom': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Invalidar caché
    _cachedCategories = [];
    _lastFetchTime = null;

    return CategoryModel(
      categoryId: docRef.id,
      name: cleanName,
      icon: 'edit',
      color: '#555555',
      order: 999,
      active: true,
    );
  }

  // Forzar refresco de categorías
  Future<void> refreshCategories() async {
    _cachedCategories = [];
    _lastFetchTime = null;
    await getAllCategories();
  }
}
