import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Future<void> _acceptTerms(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('acceptedTerms', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Términos y Condiciones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 80),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manos Locales',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contenedor del texto
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121828),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF1976D2),
                      width: 1,
                    ),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      '''
Al usar la aplicación Manos Locales, el usuario acepta estos términos. 
La app conecta a vecinos que ofrecen y buscan servicios locales, facilitando el contacto directo sin intermediarios. 
Cada usuario es responsable de la información y servicios que publica, así como de los acuerdos que realice fuera de la plataforma. 
Manos Locales no garantiza la calidad ni cumplimiento de los servicios ofrecidos. 

Las publicaciones deben ser veraces, respetuosas y legales; la app puede editar o eliminar contenido inapropiado. 
La comunicación se realiza mediante medios externos (WhatsApp, llamada o correo), sin supervisión de la app. 
Los datos personales se usan solo para el funcionamiento del servicio y no se comparten con terceros sin permiso. 

Las valoraciones deben ser honestas y respetuosas. 
Manos Locales no se hace responsable por daños, pérdidas o incumplimientos derivados del uso de la app. 
El uso continuo implica la aceptación de posibles actualizaciones de estos términos.
                      ''',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón principal (azul)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptTerms(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Aceptar y continuar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón de texto (volver)
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Volver e iniciar sesión',
                    style: TextStyle(
                      color: Color(0xFF64B5F6),
                      fontWeight: FontWeight.w500,
                    ),
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
