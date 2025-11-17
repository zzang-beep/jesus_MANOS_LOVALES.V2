import 'package:flutter/material.dart';

class DetalleCandidatoScreen extends StatelessWidget {
  const DetalleCandidatoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperamos un Map<String, dynamic> con los datos del candidato
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final nombre = args?['nombre'] ?? 'Nombre no disponible';
    final profesion = args?['profesion'] ?? 'Profesión no disponible';
    final experiencia = args?['experiencia'] ?? '';
    final ubicacion = args?['ubicacion'] ?? '';
    final foto = args?['foto'] ?? 'assets/images/logo.png';
    final edad = args?['edad']?.toString() ?? ''; // opcional

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del candidato'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // foto circular
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(foto),
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(profesion, style: const TextStyle(fontSize: 16)),
            if (edad.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Edad: $edad'),
            ],
            const SizedBox(height: 8),
            Text(
              ubicacion,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            if (experiencia.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Experiencia', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(experiencia),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: const Text('Contactar'),
              onPressed: () {
                // acción de ejemplo: por ahora no funcional
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función de contacto no implementada')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
