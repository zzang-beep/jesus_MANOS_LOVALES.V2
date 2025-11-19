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
    final zone = data["zona"] ?? data["ubicacion"] ?? "Zona sin especificar";
    final photo = data["foto"] as String?;

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
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    backgroundImage: photo != null
                        ? (photo.startsWith('http')
                            ? NetworkImage(photo)
                            : AssetImage(photo) as ImageProvider)
                        : null,
                    child: photo == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 30)
                        : null,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    zone,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 11,
                    ),
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
                  data["ubicacion"] ?? zone,
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  data["precio"] ??
                      (isPuesto ? "—" : "Disponible para presupuestos"),
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
                    isPuesto
                        ? (data["descripcion"] ?? "Sin descripción")
                        : data["profesion"],
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
