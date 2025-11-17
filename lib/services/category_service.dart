import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final query = await _categoriesCollection
          .where('active', isEqualTo: true)
          .get();

      final categories =
          query.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    } catch (e) {
      throw 'Error al obtener categorías: $e';
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCollection
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) {
            final categories = snapshot.docs
                .map((doc) => CategoryModel.fromFirestore(doc))
                .toList();
            categories.sort((a, b) => a.order.compareTo(b.order));
            return categories;
          },
        );
  }

  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;
      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener categoría: $e';
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      await _categoriesCollection
          .doc(category.categoryId)
          .set(category.toMap());
    } catch (e) {
      throw 'Error al crear categoría: $e';
    }
  }

  Future<void> initializeCategories() async {
    try {
      final existing = await _categoriesCollection.limit(1).get();
      if (existing.docs.isNotEmpty) {
        print('⚠️ Categorías ya existen');
        return;
      }

      print('🚀 Inicializando categorías...');

      final categories = [
        CategoryModel(
          categoryId: 'plomeria',
          name: 'Plomería',
          icon: 'plumbing',
          color: '#1976D2',
          order: 1,
        ),
        CategoryModel(
          categoryId: 'electricidad',
          name: 'Electricidad',
          icon: 'electrical_services',
          color: '#F57C00',
          order: 2,
        ),
        CategoryModel(
          categoryId: 'jardineria',
          name: 'Jardinería',
          icon: 'yard',
          color: '#388E3C',
          order: 3,
        ),
        CategoryModel(
          categoryId: 'limpieza',
          name: 'Limpieza',
          icon: 'cleaning_services',
          color: '#00ACC1',
          order: 4,
        ),
        CategoryModel(
          categoryId: 'reparacion_pc',
          name: 'Reparación PC',
          icon: 'computer',
          color: '#5E35B1',
          order: 5,
        ),
        CategoryModel(
          categoryId: 'clases_particulares',
          name: 'Clases Particulares',
          icon: 'school',
          color: '#D32F2F',
          order: 6,
        ),
        CategoryModel(
          categoryId: 'pintura',
          name: 'Pintura',
          icon: 'format_paint',
          color: '#7B1FA2',
          order: 7,
        ),
        CategoryModel(
          categoryId: 'carpinteria',
          name: 'Carpintería',
          icon: 'carpenter',
          color: '#795548',
          order: 8,
        ),
        CategoryModel(
          categoryId: 'gasista',
          name: 'Gasista',
          icon: 'local_fire_department',
          color: '#E64A19',
          order: 9,
        ),
        CategoryModel(
          categoryId: 'otros',
          name: 'Otros',
          icon: 'more_horiz',
          color: '#616161',
          order: 10,
        ),
      ];

      for (var category in categories) {
        await createCategory(category);
      }

      print('✅ 10 categorías creadas');
    } catch (e) {
      throw 'Error al inicializar categorías: $e';
    }
  }
}
