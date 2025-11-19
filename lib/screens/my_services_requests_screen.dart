import 'package:flutter/material.dart';

class MyServicesRequestsScreen extends StatelessWidget {
  const MyServicesRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Datos temporales (después conectar con Firestore)
    final requests = [
      {
        'name': 'Ludmila Gorriti',
        'status': 'Rechazado',
        'statusColor': Colors.red,
        'avatar': '',
        'zone': 'Zona Sur',
        'serviceTitle': 'Busco niñera',
      },
      {
        'name': 'Luciano Aguilera',
        'status': 'Enviado',
        'statusColor': Colors.orange,
        'avatar': '',
        'zone': 'Zona Norte',
        'serviceTitle': 'Clases de apoyo escolar',
      },
      {
        'name': 'Pablo Carral',
        'status': 'Aceptado',
        'statusColor': Colors.green,
        'avatar': '',
        'zone': 'Zona Oeste',
        'serviceTitle': 'Reparación de filtraciones',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000B1F),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mis solicitudes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Título del servicio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001F3F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Busco niñera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/detalle_puesto',
                            arguments: {
                              'titulo': 'Busco niñera',
                              'descripcion':
                                  'Necesito apoyo por las tardes en Villa Urquiza.',
                              'precio': 'A convenir',
                              'ubicacion': 'Zona Norte',
                              'foto': 'assets/images/inicio1.png',
                            },
                          );
                        },
                        child: const Text('Ver detalles'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sección Solicitudes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001F3F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solicitudes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Lista de solicitudes
                      if (requests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Aún no recibiste solicitudes.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ...requests.map((request) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue[900],
                                      child: const Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request['name'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            request['serviceTitle'] as String,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (request['statusColor'] as Color)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              request['statusColor'] as Color,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            request['status'] == 'Aceptado'
                                                ? Icons.check_circle
                                                : request['status'] ==
                                                        'Rechazado'
                                                    ? Icons.cancel
                                                    : Icons.access_time,
                                            size: 14,
                                            color: request['statusColor']
                                                as Color,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            request['status'] as String,
                                            style: TextStyle(
                                              color: request['statusColor']
                                                  as Color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 20,
                                  color: Colors.white12,
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white38, size: 18),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        request['zone'] as String,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/detalle_candidato',
                                          arguments: {
                                            'nombre': request['name'],
                                            'profesion':
                                                request['serviceTitle'],
                                            'ubicacion': request['zone'],
                                            'experiencia':
                                                'Referencia enviada mediante tu publicación.',
                                            'foto': 'assets/images/inicio2.png',
                                          },
                                        );
                                      },
                                      child: const Text('Ver detalles'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
