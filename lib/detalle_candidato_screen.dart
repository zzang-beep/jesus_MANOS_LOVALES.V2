import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'models/chat_contact.dart';
import 'services/chat_contact_service.dart';
import 'screens/chat_screen.dart';

class DetalleCandidatoScreen extends StatelessWidget {
  const DetalleCandidatoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperamos un Map<String, dynamic> con los datos del candidato
    final args = ModalRoute.of(context)?.settings.arguments;

    String nombre = 'Nombre no disponible';
    String profesion = 'Profesión no disponible';
    String experiencia = 'Sin experiencia declarada';
    String ubicacion = 'Zona sin especificar';
    String descripcion = '';
    String foto = 'assets/images/logo.png';
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    if (args is Map<String, dynamic>) {
      nombre = args['nombre'] ?? nombre;
      profesion = args['profesion'] ?? profesion;
      experiencia = args['experiencia'] ?? experiencia;
      ubicacion = args['zona'] ?? args['ubicacion'] ?? ubicacion;
      descripcion = args['descripcion'] ?? descripcion;
      foto = args['foto'] ?? foto;
      id = args['id']?.toString() ?? id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del candidato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: foto.startsWith('http')
                  ? NetworkImage(foto)
                  : AssetImage(foto) as ImageProvider,
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profesion,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.lightBlueAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    ubicacion,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Experiencia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    experiencia,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sobre la persona',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    descripcion.isEmpty
                        ? 'Aún no hay una descripción detallada para este perfil.'
                        : descripcion,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Agregar a contactos'),
                    onPressed: () => _contactCandidate(
                        context, id, nombre, profesion, ubicacion),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text('Chatear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                      side: const BorderSide(color: Colors.lightBlueAccent),
                    ),
                    onPressed: () => _contactCandidate(
                        context, id, nombre, profesion, ubicacion),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactCandidate(
    BuildContext context,
    String candidateId,
    String name,
    String bio,
    String zona,
  ) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Obtener o crear el chat usando ChatService
      final chatService = ChatService();
      final chatId = await chatService.getOrCreateChat(
        candidateId,
        name,
        //null, // photoUrl - puedes ajustar esto si tienes la URL de la foto
        otherUserZone: zona,
      );

      // Crear el contacto
      final contact = ChatContact(
        userId: candidateId,
        name: name,
        bio: bio,
        zone: zona,
        photoUrl: '', // Puedes ajustar esto si tienes la URL de la foto
      );

      // Agregar a contactos
      await ChatContactService().addContact(contact);

      if (!context.mounted) return;

      // Cerrar el indicador de carga
      Navigator.pop(context);

      // Navegar pasando AMBOS parámetros requeridos
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            contact: contact,
            chatId: chatId, // ✅ Aquí está la corrección - pasar chatId
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loader si hay error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar chat: $e')),
        );
      }
    }
  }
}
