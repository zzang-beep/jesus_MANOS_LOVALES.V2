import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../services/category_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script MAESTRO que inicializa TODO el backend
class MasterInitializer {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryService _categoryService = CategoryService();

  // ============== INICIALIZAR TODO ==============
  Future<void> initializeEverything() async {
    try {
      print('\n🚀 ========================================');
      print('   INICIALIZACIÓN COMPLETA DEL BACKEND');
      print('========================================\n');

      // PASO 1: Categorías
      print('📂 PASO 1/4: Inicializando categorías...');
      await _categoryService.initializeCategories();
      await Future.delayed(Duration(seconds: 2));

      // PASO 2: Usuarios
      print('\n👥 PASO 2/4: Creando usuarios demo...');
      final userIds = await _createDemoUsers();
      await Future.delayed(Duration(seconds: 2));

      // PASO 3: Servicios
      print('\n🛠️ PASO 3/4: Creando servicios demo...');
      final serviceIds = await _createDemoServices(userIds);
      await Future.delayed(Duration(seconds: 2));

      // PASO 4: Ratings
      print('\n⭐ PASO 4/4: Creando ratings demo...');
      await _createDemoRatings(userIds, serviceIds);

      print('\n✅ ========================================');
      print('   ¡INICIALIZACIÓN COMPLETADA!');
      print('========================================');
      print('📊 Resumen:');
      print('   ✅ 10 categorías creadas');
      print('   ✅ 5 usuarios demo creados');
      print('   ✅ 15 servicios demo creados');
      print('   ✅ 10 ratings demo creados\n');
    } catch (e) {
      print('\n❌ ERROR CRÍTICO: $e\n');
      rethrow;
    }
  }

  // ============== CREAR USUARIOS DEMO ==============
  Future<Map<String, String>> _createDemoUsers() async {
    final userIds = <String, String>{};

    final demoUsers = [
      {
        'email': 'demo@manoslocales.com',
        'password': 'demo123456',
        'name': 'Usuario Demo',
        'phone': '+5491123456789',
        'bio': 'Cuenta de demostración',
        'role': 'both',
        'key': 'demo',
      },
      {
        'email': 'juan.plomero@manoslocales.com',
        'password': 'plomero123',
        'name': 'Juan Pérez',
        'phone': '+5491134567890',
        'bio': 'Plomero con 15 años de experiencia',
        'role': 'provider',
        'key': 'plomero',
      },
      {
        'email': 'maria.electricista@manoslocales.com',
        'password': 'electrica123',
        'name': 'María González',
        'phone': '+5491145678901',
        'bio': 'Electricista matriculada',
        'role': 'provider',
        'key': 'electricista',
      },
      {
        'email': 'carlos.jardinero@manoslocales.com',
        'password': 'jardin123',
        'name': 'Carlos Rodríguez',
        'phone': '+5491156789012',
        'bio': 'Jardinero profesional',
        'role': 'provider',
        'key': 'jardinero',
      },
      {
        'email': 'cliente1@manoslocales.com',
        'password': 'cliente123',
        'name': 'Ana Martínez',
        'phone': '+5491167890123',
        'bio': 'Cliente frecuente',
        'role': 'client',
        'key': 'cliente',
      },
    ];

    for (var userData in demoUsers) {
      try {
        final existing = await _firestore
            .collection('users')
            .where('email', isEqualTo: userData['email'])
            .limit(1)
            .get();

        String userId;

        if (existing.docs.isNotEmpty) {
          userId = existing.docs.first.id;
          print('   ⚠️  ${userData['name']} ya existe');
        } else {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: userData['email']!,
            password: userData['password']!,
          );

          userId = userCredential.user!.uid;

          final user = UserModel(
            userId: userId,
            name: userData['name']!,
            email: userData['email']!,
            phone: userData['phone']!,
            bio: userData['bio']!,
            role: userData['role']!,
            phoneVerified: true, // Demo users son verificados
            createdAt: DateTime.now(),
          );

          await _firestore.collection('users').doc(userId).set(user.toMap());
          await _auth.signOut();

          print('   ✅ ${userData['name']} creado');
        }

        userIds[userData['key']!] = userId;
      } catch (e) {
        print('   ❌ Error con ${userData['name']}: $e');
      }
    }

    return userIds;
  }

  // ============== CREAR SERVICIOS DEMO ==============
  Future<List<String>> _createDemoServices(Map<String, String> userIds) async {
    final serviceIds = <String>[];

    final demoServices = [
      // PLOMERÍA
      {
        'title': 'Reparación de cañerías y pérdidas',
        'category': 'plomeria',
        'description':
            'Arreglo de pérdidas de agua, cambio de cañerías, destapaciones. Trabajo garantizado. Atención urgencias 24hs.',
        'price': 3500.0,
        'priceText': 'Desde \$3500',
        'locationText': 'Palermo, CABA',
        'providerKey': 'plomero',
      },
      {
        'title': 'Instalación de termotanques',
        'category': 'plomeria',
        'description':
            'Instalación y reparación de termotanques eléctricos y a gas.',
        'price': 5000.0,
        'priceText': 'Desde \$5000',
        'locationText': 'Belgrano, CABA',
        'providerKey': 'plomero',
      },

      // ELECTRICIDAD
      {
        'title': 'Instalaciones eléctricas residenciales',
        'category': 'electricidad',
        'description':
            'Instalación de enchufes, llaves, tableros. Matriculado.',
        'price': 4000.0,
        'priceText': 'Desde \$4000',
        'locationText': 'Villa Urquiza, CABA',
        'providerKey': 'electricista',
      },
      {
        'title': 'Reparación de cortocircuitos',
        'category': 'electricidad',
        'description': 'Detección y reparación de fallas eléctricas.',
        'price': 2500.0,
        'priceText': 'Desde \$2500',
        'locationText': 'Caballito, CABA',
        'providerKey': 'electricista',
      },

      // JARDINERÍA
      {
        'title': 'Mantenimiento de jardines',
        'category': 'jardineria',
        'description': 'Corte de césped, poda de árboles, limpieza de jardín.',
        'price': 3000.0,
        'priceText': 'Desde \$3000/mes',
        'locationText': 'Núñez, CABA',
        'providerKey': 'jardinero',
      },
      {
        'title': 'Diseño de espacios verdes',
        'category': 'jardineria',
        'description': 'Creación y diseño de jardines, parquización.',
        'price': null,
        'priceText': 'A convenir',
        'locationText': 'San Isidro, GBA Norte',
        'providerKey': 'jardinero',
      },

      // LIMPIEZA
      {
        'title': 'Limpieza profunda de hogar',
        'category': 'limpieza',
        'description': 'Limpieza completa. Productos ecológicos.',
        'price': 2500.0,
        'priceText': '\$2500 por ambiente',
        'locationText': 'Recoleta, CABA',
        'providerKey': 'demo',
      },
      {
        'title': 'Limpieza de fin de obra',
        'category': 'limpieza',
        'description': 'Limpieza post construcción o remodelación.',
        'price': 8000.0,
        'priceText': 'Desde \$8000',
        'locationText': 'Almagro, CABA',
        'providerKey': 'demo',
      },

      // REPARACIÓN PC
      {
        'title': 'Reparación de computadoras',
        'category': 'reparacion_pc',
        'description':
            'Formateo, instalación de Windows, eliminación de virus.',
        'price': 3000.0,
        'priceText': 'Desde \$3000',
        'locationText': 'Villa Crespo, CABA',
        'providerKey': 'electricista',
      },
      {
        'title': 'Actualización y armado de PC',
        'category': 'reparacion_pc',
        'description': 'Armado de PC gamer, actualización de componentes.',
        'price': 2000.0,
        'priceText': 'Desde \$2000',
        'locationText': 'Flores, CABA',
        'providerKey': 'electricista',
      },

      // CLASES PARTICULARES
      {
        'title': 'Clases de matemática y física',
        'category': 'clases_particulares',
        'description':
            'Profesor con 10 años de experiencia. Online o presencial.',
        'price': 2000.0,
        'priceText': '\$2000 por hora',
        'locationText': 'Colegiales, CABA',
        'providerKey': 'jardinero',
      },
      {
        'title': 'Clases de inglés todos los niveles',
        'category': 'clases_particulares',
        'description': 'Profesora certificada Cambridge. Material incluido.',
        'price': 1800.0,
        'priceText': '\$1800 por hora',
        'locationText': 'Barrio Norte, CABA',
        'providerKey': 'demo',
      },

      // PINTURA
      {
        'title': 'Pintura de interiores y exteriores',
        'category': 'pintura',
        'description': 'Pintura profesional de ambientes, fachadas, rejas.',
        'price': 1500.0,
        'priceText': 'Desde \$1500 por m²',
        'locationText': 'Devoto, CABA',
        'providerKey': 'plomero',
      },

      // CARPINTERÍA
      {
        'title': 'Reparación y fabricación de muebles',
        'category': 'carpinteria',
        'description': 'Muebles a medida, reparación de sillas y mesas.',
        'price': null,
        'priceText': 'A convenir',
        'locationText': 'Boedo, CABA',
        'providerKey': 'jardinero',
      },

      // GASISTA
      {
        'title': 'Instalación de gas y calefacción',
        'category': 'gasista',
        'description':
            'Gasista matriculado. Instalación de cocinas, calefones.',
        'price': 4500.0,
        'priceText': 'Desde \$4500',
        'locationText': 'Paternal, CABA',
        'providerKey': 'plomero',
      },
    ];

    for (var serviceData in demoServices) {
      try {
        final providerId = userIds[serviceData['providerKey']]!;

        // Obtener datos del proveedor
        final providerDoc =
            await _firestore.collection('users').doc(providerId).get();
        final providerData = providerDoc.data()!;

        // Verificar si ya existe
        final existing = await _firestore
            .collection('services')
            .where('title', isEqualTo: serviceData['title'])
            .where('providerId', isEqualTo: providerId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          serviceIds.add(existing.docs.first.id);
          print('   ⚠️  "${serviceData['title']}" ya existe');
          continue;
        }

        final service = ServiceModel(
          title: serviceData['title'] as String,
          category: serviceData['category'] as String,
          description: serviceData['description'] as String,
          price: serviceData['price'] as double?,
          priceText: serviceData['priceText'] as String,
          providerId: providerId,
          providerName: providerData['name'],
          providerPhone: providerData['phone'],
          providerPhotoUrl: providerData['photoUrl'] ?? '',
          locationText: serviceData['locationText'] as String,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final docRef =
            await _firestore.collection('services').add(service.toMap());
        serviceIds.add(docRef.id);

        print('   ✅ "${serviceData['title']}" creado');
      } catch (e) {
        print('   ❌ Error con "${serviceData['title']}": $e');
      }
    }

    return serviceIds;
  }

  // ============== CREAR RATINGS DEMO ==============
  Future<void> _createDemoRatings(
    Map<String, String> userIds,
    List<String> serviceIds,
  ) async {
    if (serviceIds.isEmpty) {
      print('   ⚠️  No hay servicios para crear ratings');
      return;
    }

    final demoRatings = [
      {
        'serviceIndex': 0,
        'userKey': 'cliente',
        'score': 5,
        'comment': 'Excelente servicio, muy profesional y puntual',
      },
      {
        'serviceIndex': 0,
        'userKey': 'demo',
        'score': 4,
        'comment': 'Muy buen trabajo, recomendado',
      },
      {
        'serviceIndex': 1,
        'userKey': 'cliente',
        'score': 5,
        'comment': 'Impecable instalación, volvería a contratar',
      },
      {
        'serviceIndex': 2,
        'userKey': 'demo',
        'score': 5,
        'comment': 'Súper profesional, trabajo de calidad',
      },
      {
        'serviceIndex': 2,
        'userKey': 'cliente',
        'score': 4,
        'comment': 'Buen servicio y precio justo',
      },
      {
        'serviceIndex': 3,
        'userKey': 'demo',
        'score': 5,
        'comment': 'Solucionó el problema rápidamente',
      },
      {
        'serviceIndex': 4,
        'userKey': 'cliente',
        'score': 4,
        'comment': 'Mi jardín quedó hermoso',
      },
      {
        'serviceIndex': 6,
        'userKey': 'demo',
        'score': 5,
        'comment': 'Dejó todo impecable, muy detallista',
      },
      {
        'serviceIndex': 8,
        'userKey': 'cliente',
        'score': 5,
        'comment': 'Arregló mi PC en menos de una hora',
      },
      {
        'serviceIndex': 10,
        'userKey': 'demo',
        'score': 4,
        'comment': 'Excelente profesor, muy paciente',
      },
    ];

    for (var ratingData in demoRatings) {
      try {
        final serviceIndex = ratingData['serviceIndex'] as int;
        if (serviceIndex >= serviceIds.length) continue;

        final serviceId = serviceIds[serviceIndex];
        final userId = userIds[ratingData['userKey']]!;

        // Verificar si ya existe
        final existing = await _firestore
            .collection('ratings')
            .where('serviceId', isEqualTo: serviceId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          print('   ⚠️  Rating ya existe');
          continue;
        }

        // Obtener datos del servicio y usuario
        final serviceDoc =
            await _firestore.collection('services').doc(serviceId).get();
        final serviceData = serviceDoc.data()!;
        final providerId = serviceData['providerId'];

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data()!;

        await _firestore.collection('ratings').add({
          'serviceId': serviceId,
          'providerId': providerId,
          'userId': userId,
          'userName': userData['name'],
          'userPhotoUrl': userData['photoUrl'] ?? '',
          'score': ratingData['score'],
          'comment': ratingData['comment'],
          'createdAt': Timestamp.now(),
        });

        print('   ✅ Rating creado para servicio #$serviceIndex');
      } catch (e) {
        print('   ❌ Error al crear rating: $e');
      }
    }

    // Actualizar promedios
    print('\n🔄 Actualizando promedios...');
    await _updateAllRatings(serviceIds, userIds);
  }

  // ============== ACTUALIZAR TODOS LOS RATINGS ==============
  Future<void> _updateAllRatings(
    List<String> serviceIds,
    Map<String, String> userIds,
  ) async {
    try {
      // Actualizar servicios
      for (var serviceId in serviceIds) {
        final ratingsQuery = await _firestore
            .collection('ratings')
            .where('serviceId', isEqualTo: serviceId)
            .get();

        if (ratingsQuery.docs.isEmpty) continue;

        double totalScore = 0;
        for (var doc in ratingsQuery.docs) {
          totalScore +=
              ((doc.data() as Map<String, dynamic>?)?['score'] ?? 0).toDouble();
        }

        final avg = totalScore / ratingsQuery.docs.length;
        final count = ratingsQuery.docs.length;

        await _firestore.collection('services').doc(serviceId).update({
          'ratingAvg': double.parse(avg.toStringAsFixed(1)),
          'ratingCount': count,
        });
      }

      // Actualizar proveedores
      for (var userId in userIds.values) {
        final ratingsQuery = await _firestore
            .collection('ratings')
            .where('providerId', isEqualTo: userId)
            .get();

        if (ratingsQuery.docs.isEmpty) continue;

        double totalScore = 0;
        for (var doc in ratingsQuery.docs) {
          totalScore +=
              ((doc.data() as Map<String, dynamic>?)?['score'] ?? 0).toDouble();
        }

        final avg = totalScore / ratingsQuery.docs.length;
        final count = ratingsQuery.docs.length;

        await _firestore.collection('users').doc(userId).update({
          'ratingAvg': double.parse(avg.toStringAsFixed(1)),
          'ratingCount': count,
        });
      }

      print('   ✅ Promedios actualizados');
    } catch (e) {
      print('   ❌ Error al actualizar promedios: $e');
    }
  }

  // ============== LIMPIAR TODO ==============
  Future<void> cleanEverything() async {
    try {
      print('\n🗑️  Limpiando base de datos...\n');

      // Eliminar servicios
      final services = await _firestore.collection('services').get();
      for (var doc in services.docs) {
        await doc.reference.delete();
      }
      print('   ✅ Servicios eliminados');

      // Eliminar ratings
      final ratings = await _firestore.collection('ratings').get();
      for (var doc in ratings.docs) {
        await doc.reference.delete();
      }
      print('   ✅ Ratings eliminados');

      // Eliminar usuarios
      final users = await _firestore.collection('users').get();
      for (var doc in users.docs) {
        await doc.reference.delete();
      }
      print('   ✅ Usuarios eliminados');

      // Eliminar categorías
      final categories = await _firestore.collection('categories').get();
      for (var doc in categories.docs) {
        await doc.reference.delete();
      }
      print('   ✅ Categorías eliminadas');

      print('\n✅ Base de datos limpiada\n');
    } catch (e) {
      print('\n❌ Error al limpiar: $e\n');
    }
  }

  // ============== VERIFICAR ESTADO ==============
  Future<void> checkStatus() async {
    try {
      print('\n🔍 Verificando estado del backend...\n');

      final users = await _firestore.collection('users').get();
      print('👥 Usuarios: ${users.docs.length}');

      final categories = await _firestore.collection('categories').get();
      print('📂 Categorías: ${categories.docs.length}');

      final services = await _firestore
          .collection('services')
          .where('active', isEqualTo: true)
          .get();
      print('🛠️  Servicios activos: ${services.docs.length}');

      final ratings = await _firestore.collection('ratings').get();
      print('⭐ Ratings: ${ratings.docs.length}');

      print('\n✅ Verificación completa\n');
    } catch (e) {
      print('\n❌ Error en verificación: $e\n');
    }
  }

  // ============== MIGRAR USUARIOS EXISTENTES ==============
  Future<void> migrateExistingUsers() async {
    try {
      print('\n🔄 Migrando usuarios existentes...\n');

      final usersSnapshot = await _firestore.collection('users').get();
      int updated = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('phoneVerified')) {
          await doc.reference.update({
            'phoneVerified': false,
            'verificationCode': '',
            'verificationCodeExpiry': null,
          });
          updated++;
          print('   ✅ Usuario ${doc.id} migrado');
        }
      }

      print('\n✅ Migración completada: $updated usuarios actualizados\n');
    } catch (e) {
      print('\n❌ Error en migración: $e\n');
    }
  }
}
