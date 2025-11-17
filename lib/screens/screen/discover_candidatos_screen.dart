import 'package:flutter/material.dart';
import '../widgets/discover_profile_card.dart';

class DiscoverCandidatosScreen extends StatefulWidget {
  const DiscoverCandidatosScreen({super.key});

  @override
  State<DiscoverCandidatosScreen> createState() =>
      _DiscoverCandidatosScreenState();
}

class _DiscoverCandidatosScreenState extends State<DiscoverCandidatosScreen> {

  final List<Map<String, dynamic>> candidatos = [
    {
      "nombre": "Juan Rodríguez",
      "profesion": "Plomero Profesional",
      "experiencia": "5 años de experiencia",
      "ubicacion": "Zona Oeste",
      "foto": "assets/images/inicio3.png",
    },
    {
      "nombre": "María López",
      "profesion": "Niñera con referencias",
      "experiencia": "3 años de experiencia",
      "ubicacion": "Zona Este",
      "foto": "assets/images/inicio1.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Descubrir",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Puestos", false),
                const SizedBox(width: 12),
                _buildTab("Candidatos", true),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: candidatos.map((item) {
                  return DiscoverProfileCard(
                    data: item,
                    isPuesto: false,
                    onTapAvatar: () {
                      Navigator.pushNamed(
                        context,
                        "/detalle_candidato",
                        arguments: item,
                      );
                    },
                    onTapCard: () {
                      Navigator.pushNamed(
                        context,
                        "/detalle_candidato",
                        arguments: item,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isCandidatoTab) {
    final isActive = isCandidatoTab;

    return GestureDetector(
      onTap: () {
        if (!isCandidatoTab) {
          Navigator.pushReplacementNamed(context, "/discover_puestos");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.white,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
