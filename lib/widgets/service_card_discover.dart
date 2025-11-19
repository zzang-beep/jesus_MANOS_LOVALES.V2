import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/service_model.dart';

class ServiceCardDiscover extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCardDiscover({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF001F3F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar del proveedor
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue[900],
              backgroundImage: service.providerPhotoUrl.isNotEmpty
                  ? NetworkImage(service.providerPhotoUrl)
                  : null,
              child: service.providerPhotoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // Información del servicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.locationText,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Categoría y precio
                  Row(
                    children: [
                      // Categoría badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryName(service.category),
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Precio
                      Text(
                        service.formattedPrice,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rating y botón negociable
                  Row(
                    children: [
                      if (service.ratingCount > 0) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.ratingAvg}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // Badge negociable
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Colors.green[300],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Negociable',
                              style: TextStyle(
                                color: Colors.green[300],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final Map<String, String> categoryNames = {
      'plomeria': 'Plomería',
      'electricidad': 'Electricidad',
      'jardineria': 'Jardinería',
      'limpieza': 'Limpieza',
      'reparacion_pc': 'Reparación PC',
      'clases_particulares': 'Clases',
      'pintura': 'Pintura',
      'carpinteria': 'Carpintería',
      'gasista': 'Gasista',
      'otros': 'Otros',
    };

    return categoryNames[categoryId] ?? categoryId;
  }
}
