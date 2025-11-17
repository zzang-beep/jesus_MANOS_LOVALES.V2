import 'package:flutter/material.dart';

class DiscoverProfileCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isPuesto;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapCard;

  const DiscoverProfileCard({
    Key? key,
    required this.data,
    required this.isPuesto,
    required this.onTapAvatar,
    required this.onTapCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF001A3E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------
            // ENCABEZADO CON AVATAR Y NOMBRE
            // ----------------------------------
            Row(
              children: [
                GestureDetector(
                  onTap: onTapAvatar,
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPuesto ? data["titulo"] : data["nombre"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ----------------------------------
            // UBICACIÓN + PRECIO
            // ----------------------------------
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  data["ubicacion"] ?? "Sin ubicación",
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  data["precio"] ?? "—",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ----------------------------------
            // PROFESIÓN O DESCRIPCIÓN
            // ----------------------------------
            Row(
              children: [
                Icon(
                  isPuesto ? Icons.description : Icons.handyman,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isPuesto ? data["descripcion"] : data["profesion"],
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------
            // EXPERIENCIA
            // ----------------------------------
            Row(
              children: [
                const Icon(Icons.star, color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data["experiencia"] ?? "—",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
