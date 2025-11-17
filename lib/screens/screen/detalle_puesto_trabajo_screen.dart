import 'package:flutter/material.dart';

class DetallePuestoScreen extends StatelessWidget {
  const DetallePuestoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Esperamos un Map<String, dynamic> con los datos del puesto
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final titulo = args?['titulo'] ?? 'Título no disponible';
    final descripcion = args?['descripcion'] ?? 'Descripción no disponible';
    final precio = args?['precio'] ?? '';
    final ubicacion = args?['ubicacion'] ?? '';
    final foto = args?['foto'] ?? 'assets/images/logo.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del puesto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagen del puesto
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(foto),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            if (precio.isNotEmpty) Text('Precio estimado: $precio'),
            const SizedBox(height: 6),
            if (ubicacion.isNotEmpty) Text('Ubicación: $ubicacion'),
            const SizedBox(height: 12),
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(descripcion),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.work),
              label: const Text('Postular / Contactar'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función no implementada aún')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
