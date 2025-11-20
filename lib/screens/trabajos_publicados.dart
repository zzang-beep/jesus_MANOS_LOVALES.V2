import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';
class ServiciosPublicadosScreen extends StatefulWidget {
  const ServiciosPublicadosScreen({super.key});

  @override
  _ServiciosPublicadosScreenState createState() =>
      _ServiciosPublicadosScreenState();
}

class _ServiciosPublicadosScreenState extends State<ServiciosPublicadosScreen> {
  late Future<List<ServiceModel>> futureServices;
  final ServiceService serviceService = ServiceService();

  @override
  void initState() {
    super.initState();
    futureServices = serviceService.getPublishedServices(); // active == true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1220),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              // ruta local a tu imagen de fondo (la convertirá tu build)
              image: AssetImage("assets/images/background_pattern.png"),
              fit: BoxFit.cover,
              opacity: 0.25,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 15),
              const Text(
                "Trabajos publicados",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: FutureBuilder<List<ServiceModel>>(
                  future: futureServices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error al cargar datos',
                            style: const TextStyle(color: Colors.white)),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No tienes trabajos publicados',
                            style: TextStyle(color: Colors.white70, fontSize: 16)),
                      );
                    }

                    final services = snapshot.data!;
                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (_, index) {
                        final s = services[index];
                        return _serviceCard(s);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceCard(ServiceModel s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // izquierda: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  s.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(s.formattedPrice, style: TextStyle(color: Colors.white70)),
                    const SizedBox(width: 12),
                    Text(s.locationText, style: TextStyle(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }
}
