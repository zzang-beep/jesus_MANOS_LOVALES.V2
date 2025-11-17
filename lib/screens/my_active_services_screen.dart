import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/service_service.dart';
import '../services/auth_service.dart';
import '../models/service_model.dart';

class MyActiveServicesScreen extends StatefulWidget {
  const MyActiveServicesScreen({Key? key}) : super(key: key);

  @override
  State<MyActiveServicesScreen> createState() => _MyActiveServicesScreenState();
}

class _MyActiveServicesScreenState extends State<MyActiveServicesScreen> {
  final _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        final services = await _serviceService.getProviderServices(userId);
        setState(() {
          _services = services;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _finalizeJob(String serviceId) async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001F3F),
        title: const Text(
          '¿Finalizar trabajo?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que deseas marcar este trabajo como finalizado?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // TODO: Actualizar estado del servicio a "finalizado"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trabajo finalizado')),
      );
      _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Mis servicios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de servicios
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue))
                    : _services.isEmpty
                        ? Center(
                            child: Text(
                              'No tienes servicios activos',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              final service = _services[index];
                              return _buildServiceCard(service);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Encargado',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Proveedor (en este caso, el usuario asignado)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[900],
                backgroundImage: service.providerPhotoUrl.isNotEmpty
                    ? NetworkImage(service.providerPhotoUrl)
                    : null,
                child: service.providerPhotoUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                service.providerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Botón Finalizar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _finalizeJob(service.serviceId!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Finalizar trabajo'),
            ),
          ),
        ],
      ),
    );
  }
}
