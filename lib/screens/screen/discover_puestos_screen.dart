import 'package:flutter/material.dart';
import '../widgets/discover_profile_card.dart';

class DiscoverPuestosScreen extends StatefulWidget {
  const DiscoverPuestosScreen({super.key});

  @override
  State<DiscoverPuestosScreen> createState() => _DiscoverPuestosScreenState();
}

class _DiscoverPuestosScreenState extends State<DiscoverPuestosScreen> {

  final List<Map<String, dynamic>> puestos = [
    {
      "titulo": "Electricista para urgencias",
      "descripcion": "Reparación inmediata de cortocircuitos y fallas.",
      "precio": "\$10.000",
      "ubicacion": "Zona Norte",
      "foto": "assets/images/inicio1.png",
    },
    {
      "titulo": "Profesor de Matemáticas",
      "descripcion": "Clases particulares para secundaria.",
      "precio": "\$5.000",
      "ubicacion": "Zona Sur",
      "foto": "assets/images/inicio2.png",
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

            // --------------------------
            // TABS
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab("Puestos", true),
                const SizedBox(width: 12),
                _buildTab("Candidatos", false),
              ],
            ),

            const SizedBox(height: 20),

            // --------------------------
            // LISTA DE PUESTOS
            // --------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: puestos.map((item) {
                  return DiscoverProfileCard(
                    data: item,
                    isPuesto: true,
                    onTapAvatar: () {
                      Navigator.pushNamed(
                        context,
                        "/detalle_puesto",
                        arguments: item,
                      );
                    },
                    onTapCard: () {
                      Navigator.pushNamed(
                        context,
                        "/detalle_puesto",
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

  Widget _buildTab(String label, bool isPuestosTab) {
    final isActive = isPuestosTab;

    return GestureDetector(
      onTap: () {
        if (!isPuestosTab) {
          Navigator.pushReplacementNamed(context, "/discover_candidatos");
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
