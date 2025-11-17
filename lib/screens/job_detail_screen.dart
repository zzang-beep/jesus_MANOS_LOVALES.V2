import 'package:flutter/material.dart';
import '../services/service_service.dart';
import '../models/service_model.dart';

class JobDetailScreen extends StatefulWidget {
  final String serviceId;
  final String status; // "En proceso" o "Finalizado"

  const JobDetailScreen({
    Key? key,
    required this.serviceId,
    this.status = "En proceso",
  }) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _serviceService = ServiceService();
  ServiceModel? _service;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  Future<void> _loadService() async {
    try {
      final service = await _serviceService.getServiceById(widget.serviceId);
      setState(() {
        _service = service;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF000B1F),
        body:
            const Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    if (_service == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000B1F),
        body: const Center(
          child: Text('Servicio no encontrado',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mis trabajos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Título del trabajo
                  Text(
                    _service!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Proveedor
                  Text(
                    'De ${_service!.providerName}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001F3F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _service!.description,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Información adicional
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001F3F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información adicional',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ubicación
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _service!.locationText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Sueldo
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sueldo: ${_service!.priceText}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Estado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.status == "Finalizado"
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.status == "Finalizado"
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.status == "Finalizado"
                              ? Icons.check_circle
                              : Icons.access_time,
                          color: widget.status == "Finalizado"
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.status,
                          style: TextStyle(
                            color: widget.status == "Finalizado"
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
