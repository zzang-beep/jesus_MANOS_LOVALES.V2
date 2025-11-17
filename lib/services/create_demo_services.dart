import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import '../services/category_service.dart';

class DemoServicesCreator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CategoryService _categoryService = CategoryService();

  // ============== CREAR TODOS LOS SERVICIOS DEMO ==============
  Future<void> createAllDemoServices() async {
    try {
      print('🚀 Creando servicios demo...');

      // Primero inicializar categorías
      await _categoryService.initializeCategories();

      // Obtener usuarios proveedores
      final providers = await _firestore
          .collection('users')
          .where('role', whereIn: ['provider', 'both']).get();

      if (providers.docs.isEmpty) {
        print('⚠️ No hay proveedores. Crea usuarios primero (Dev 1).');
        return;
      }

      // Lista de servicios demo
      final demoServices = _getDemoServicesList(providers.docs);

      // Crear servicios
      for (var serviceData in demoServices) {
        await _createDemoService(serviceData);
      }

      print('✅ Servicios demo creados exitosamente');
    } catch (e) {
      print('❌ Error al crear servicios demo: $e');
    }
  }

  // ============== LISTA DE SERVICIOS DEMO ==============
  List<Map<String, dynamic>> _getDemoServicesList(
    List<QueryDocumentSnapshot> providers,
  ) {
    // Distribuir servicios entre proveedores
    return [
      // PLOMERÍA
      {
        'title': 'Reparación de cañerías y pérdidas',
        'category': 'plomeria',
        'description':
            'Arreglo de pérdidas de agua, cambio de cañerías, destapaciones. Trabajo garantizado. Atención urgencias 24hs.',
        'price': 3500.0,
        'priceText': 'Desde \$3500',
        'locationText': 'Palermo, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },
      {
        'title': 'Instalación de termotanques',
        'category': 'plomeria',
        'description':
            'Instalación y reparación de termotanques eléctricos y a gas. Servicio con garantía.',
        'price': 5000.0,
        'priceText': 'Desde \$5000',
        'locationText': 'Belgrano, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },

      // ELECTRICIDAD
      {
        'title': 'Instalaciones eléctricas residenciales',
        'category': 'electricidad',
        'description':
            'Instalación de enchufes, llaves, tableros eléctricos. Matriculado y con seguro.',
        'price': 4000.0,
        'priceText': 'Desde \$4000',
        'locationText': 'Villa Urquiza, CABA',
        'providerId': providers.length > 1 ? providers[1].id : providers[0].id,
        'providerName': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },
      {
        'title': 'Reparación de cortocircuitos',
        'category': 'electricidad',
        'description':
            'Detección y reparación de fallas eléctricas, cortocircuitos, térmica que salta.',
        'price': 2500.0,
        'priceText': 'Desde \$2500',
        'locationText': 'Caballito, CABA',
        'providerId': providers.length > 1 ? providers[1].id : providers[0].id,
        'providerName': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },

      // JARDINERÍA
      {
        'title': 'Mantenimiento de jardines',
        'category': 'jardineria',
        'description':
            'Corte de césped, poda de árboles y arbustos, limpieza de jardín. Servicio semanal o quincenal.',
        'price': 3000.0,
        'priceText': 'Desde \$3000/mes',
        'locationText': 'Núñez, CABA',
        'providerId': providers.length > 2 ? providers[2].id : providers[0].id,
        'providerName': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },
      {
        'title': 'Diseño de espacios verdes',
        'category': 'jardineria',
        'description':
            'Creación y diseño de jardines, parquización, instalación de riego automático.',
        'price': null,
        'priceText': 'A convenir según proyecto',
        'locationText': 'San Isidro, GBA Norte',
        'providerId': providers.length > 2 ? providers[2].id : providers[0].id,
        'providerName': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },

      // LIMPIEZA
      {
        'title': 'Limpieza profunda de hogar',
        'category': 'limpieza',
        'description':
            'Limpieza completa de departamentos y casas. Incluye cocina, baños, ventanas. Productos ecológicos.',
        'price': 2500.0,
        'priceText': '\$2500 por ambiente',
        'locationText': 'Recoleta, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },
      {
        'title': 'Limpieza de fin de obra',
        'category': 'limpieza',
        'description':
            'Limpieza post construcción o remodelación. Retiro de escombros, limpieza de vidrios y pisos.',
        'price': 8000.0,
        'priceText': 'Desde \$8000',
        'locationText': 'Almagro, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },

      // REPARACIÓN PC
      {
        'title': 'Reparación de computadoras',
        'category': 'reparacion_pc',
        'description':
            'Formateo, instalación de Windows, eliminación de virus, cambio de componentes. Servicio a domicilio.',
        'price': 3000.0,
        'priceText': 'Desde \$3000',
        'locationText': 'Villa Crespo, CABA',
        'providerId': providers.length > 1 ? providers[1].id : providers[0].id,
        'providerName': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },
      {
        'title': 'Actualización y armado de PC',
        'category': 'reparacion_pc',
        'description':
            'Armado de PC gamer, actualización de componentes, optimización de rendimiento.',
        'price': 2000.0,
        'priceText': 'Desde \$2000 (sin componentes)',
        'locationText': 'Flores, CABA',
        'providerId': providers.length > 1 ? providers[1].id : providers[0].id,
        'providerName': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },

      // CLASES PARTICULARES
      {
        'title': 'Clases de matemática y física',
        'category': 'clases_particulares',
        'description':
            'Profesor de secundaria con 10 años de experiencia. Clases online o presencial.',
        'price': 2000.0,
        'priceText': '\$2000 por hora',
        'locationText': 'Colegiales, CABA',
        'providerId': providers.length > 2 ? providers[2].id : providers[0].id,
        'providerName': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },
      {
        'title': 'Clases de inglés todos los niveles',
        'category': 'clases_particulares',
        'description':
            'Profesora certificada Cambridge. Clases individuales o grupales. Material incluido.',
        'price': 1800.0,
        'priceText': '\$1800 por hora',
        'locationText': 'Barrio Norte, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },

      // PINTURA
      {
        'title': 'Pintura de interiores y exteriores',
        'category': 'pintura',
        'description':
            'Pintura profesional de ambientes, fachadas, rejas. Presupuesto sin cargo.',
        'price': 1500.0,
        'priceText': 'Desde \$1500 por m²',
        'locationText': 'Devoto, CABA',
        'providerId': providers.length > 1 ? providers[1].id : providers[0].id,
        'providerName': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 1
            ? ((providers[1].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },

      // CARPINTERÍA
      {
        'title': 'Reparación y fabricación de muebles',
        'category': 'carpinteria',
        'description':
            'Muebles a medida, reparación de sillas y mesas, restauración de madera.',
        'price': null,
        'priceText': 'A convenir según trabajo',
        'locationText': 'Boedo, CABA',
        'providerId': providers.length > 2 ? providers[2].id : providers[0].id,
        'providerName': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['name'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['name'] ?? ''),
        'providerPhone': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['phone'] ?? '')
            : ((providers[0].data() as Map<String, dynamic>?)?['phone'] ?? ''),
        'providerPhotoUrl': providers.length > 2
            ? ((providers[2].data() as Map<String, dynamic>?)?['photoUrl'] ??
                '')
            : ((providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ??
                ''),
      },

      // GASISTA
      {
        'title': 'Instalación de gas y calefacción',
        'category': 'gasista',
        'description':
            'Gasista matriculado. Instalación de cocinas, calefones, estufas. Certificación y garantía.',
        'price': 4500.0,
        'priceText': 'Desde \$4500',
        'locationText': 'Paternal, CABA',
        'providerId': providers[0].id,
        'providerName':
            (providers[0].data() as Map<String, dynamic>?)?['name'] ?? '',
        'providerPhone':
            (providers[0].data() as Map<String, dynamic>?)?['phone'] ?? '',
        'providerPhotoUrl':
            (providers[0].data() as Map<String, dynamic>?)?['photoUrl'] ?? '',
      },
    ];
  }

  // ============== CREAR UN SERVICIO DEMO ==============
  Future<void> _createDemoService(Map<String, dynamic> serviceData) async {
    try {
      // Verificar si ya existe un servicio similar
      final existing = await _firestore
          .collection('services')
          .where('title', isEqualTo: serviceData['title'])
          .where('providerId', isEqualTo: serviceData['providerId'])
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print('⚠️ Servicio "${serviceData['title']}" ya existe, saltando...');
        return;
      }

      // Crear servicio
      final service = ServiceModel(
        title: serviceData['title'],
        category: serviceData['category'],
        description: serviceData['description'],
        price: serviceData['price'],
        priceText: serviceData['priceText'],
        providerId: serviceData['providerId'],
        providerName: serviceData['providerName'],
        providerPhone: serviceData['providerPhone'],
        providerPhotoUrl: serviceData['providerPhotoUrl'],
        locationText: serviceData['locationText'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('services').add(service.toMap());
      print('✅ Servicio creado: ${serviceData['title']}');
    } catch (e) {
      print('❌ Error al crear servicio "${serviceData['title']}": $e');
    }
  }

  // ============== ELIMINAR TODOS LOS SERVICIOS DEMO ==============
  Future<void> deleteAllDemoServices() async {
    try {
      print('🗑️ Eliminando servicios demo...');

      final services = await _firestore.collection('services').get();
      for (var doc in services.docs) {
        await doc.reference.delete();
      }

      print('✅ Servicios demo eliminados');
    } catch (e) {
      print('❌ Error al eliminar servicios: $e');
    }
  }
}
