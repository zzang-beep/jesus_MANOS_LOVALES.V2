import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DemoDataCreator {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============== CREAR TODOS LOS USUARIOS DEMO ==============
  Future<void> createAllDemoUsers() async {
    try {
      print('🚀 Creando usuarios demo...');

      final demoUsers = [
        {
          'email': 'demo@manoslocales.com',
          'password': 'demo123456',
          'name': 'Usuario Demo',
          'phone': '+5491123456789',
          'bio': 'Cuenta de demostración para probar la app',
          'role': 'both',
        },
        {
          'email': 'juan.plomero@manoslocales.com',
          'password': 'plomero123',
          'name': 'Juan Pérez',
          'phone': '+5491134567890',
          'bio':
              'Plomero con 15 años de experiencia. Trabajos de calidad y garantía.',
          'role': 'provider',
        },
        {
          'email': 'maria.electricista@manoslocales.com',
          'password': 'electrica123',
          'name': 'María González',
          'phone': '+5491145678901',
          'bio':
              'Electricista matriculada. Instalaciones y reparaciones eléctricas.',
          'role': 'provider',
        },
        {
          'email': 'carlos.jardinero@manoslocales.com',
          'password': 'jardin123',
          'name': 'Carlos Rodríguez',
          'phone': '+5491156789012',
          'bio':
              'Jardinero profesional. Mantenimiento y diseño de espacios verdes.',
          'role': 'provider',
        },
        {
          'email': 'cliente1@manoslocales.com',
          'password': 'cliente123',
          'name': 'Ana Martínez',
          'phone': '+5491167890123',
          'bio': 'Cliente frecuente de servicios',
          'role': 'client',
        },
      ];

      for (var userData in demoUsers) {
        await _createDemoUser(
          email: userData['email']!,
          password: userData['password']!,
          name: userData['name']!,
          phone: userData['phone']!,
          bio: userData['bio']!,
          role: userData['role']!,
        );
      }

      print('✅ Usuarios demo creados exitosamente');
    } catch (e) {
      print('❌ Error al crear usuarios demo: $e');
    }
  }

  // ============== CREAR UN USUARIO DEMO ==============
  Future<void> _createDemoUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String bio,
    required String role,
  }) async {
    try {
      // Verificar si el usuario ya existe
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        print('⚠️ Usuario $email ya existe, saltando...');
        return;
      }

      // Crear usuario en Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Crear documento en Firestore
      final user = UserModel(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.userId).set(user.toMap());

      print('✅ Usuario creado: $email');

      // Cerrar sesión para crear el siguiente
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ Email $email ya existe en Auth');
      } else {
        print('❌ Error con $email: ${e.message}');
      }
    } catch (e) {
      print('❌ Error al crear $email: $e');
    }
  }

  // ============== CREAR RATINGS DEMO ==============
  Future<void> createDemoRatings() async {
    try {
      print('🚀 Creando ratings demo...');

      // Obtener proveedores
      final providers = await _firestore
          .collection('users')
          .where('role', whereIn: ['provider', 'both']).get();

      if (providers.docs.isEmpty) {
        print('⚠️ No hay proveedores para crear ratings');
        return;
      }

      // Obtener clientes
      final clients = await _firestore
          .collection('users')
          .where('role', whereIn: ['client', 'both']).get();

      if (clients.docs.isEmpty) {
        print('⚠️ No hay clientes para crear ratings');
        return;
      }

      // Crear ratings de ejemplo
      final demoRatings = [
        {
          'providerId': providers.docs[0].id,
          'userId': clients.docs[0].id,
          'userName':
              (clients.docs[0].data() as Map<String, dynamic>?)?['name'] ?? '',
          'score': 5,
          'comment': 'Excelente servicio, muy profesional y puntual',
        },
        {
          'providerId': providers.docs[0].id,
          'userId':
              clients.docs.length > 1 ? clients.docs[1].id : clients.docs[0].id,
          'userName': clients.docs.length > 1
              ? ((clients.docs[1].data() as Map<String, dynamic>?)?['name'] ??
                  '')
              : ((clients.docs[0].data() as Map<String, dynamic>?)?['name'] ??
                  ''),
          'score': 4,
          'comment': 'Muy buen trabajo, recomendado',
        },
        {
          'providerId': providers.docs.length > 1
              ? providers.docs[1].id
              : providers.docs[0].id,
          'userId': clients.docs[0].id,
          'userName':
              (clients.docs[0].data() as Map<String, dynamic>?)?['name'] ?? '',
          'score': 5,
          'comment': 'Impecable, volvería a contratar sin dudas',
        },
      ];

      for (var ratingData in demoRatings) {
        await _firestore.collection('ratings').add({
          'serviceId': 'demo-service-id', // Dev 2 reemplazará con IDs reales
          'providerId': ratingData['providerId'],
          'userId': ratingData['userId'],
          'userName': ratingData['userName'],
          'userPhotoUrl': '',
          'score': ratingData['score'],
          'comment': ratingData['comment'],
          'createdAt': Timestamp.now(),
        });
      }

      print('✅ Ratings demo creados exitosamente');
    } catch (e) {
      print('❌ Error al crear ratings demo: $e');
    }
  }

  // ============== ELIMINAR TODOS LOS DATOS DEMO ==============
  Future<void> deleteAllDemoData() async {
    try {
      print('🗑️ Eliminando datos demo...');

      // Eliminar usuarios
      final users = await _firestore.collection('users').get();
      for (var doc in users.docs) {
        await doc.reference.delete();
      }

      // Eliminar ratings
      final ratings = await _firestore.collection('ratings').get();
      for (var doc in ratings.docs) {
        await doc.reference.delete();
      }

      print('✅ Datos demo eliminados');
    } catch (e) {
      print('❌ Error al eliminar datos: $e');
    }
  }
}
