import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';
import 'payment_success.dart';

class WaitingForConfirmationScreen extends StatelessWidget {
  final String paymentId;

  const WaitingForConfirmationScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    const fondoOscuro = Color(0xFF0A0E21);
    const cardColor1 = Color(0xFF07112A);
    const cardColor2 = Color(0xFF0B1B2F);
    const azulPrincipal = Color(0xFF0F4C81);

    final paymentStream = FirebaseFirestore.instance
        .collection('payments')
        .doc(paymentId)
        .snapshots();

    final paymentService = PaymentService();
    final auth = AuthService();

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text("Confirmación de pago"),
        backgroundColor: azulPrincipal,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: paymentStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snap.hasData || !snap.data!.exists) {
            return const Center(
              child: Text("Solicitud no encontrada",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final status = data["status"] ?? "pending";

          final providerConfirmed = data["providerConfirmed"] == true;
          final clientConfirmed = data["clientConfirmed"] == true;

          if (status == "completed") {
            return const PaymentSuccess();
          }

          final clientId = auth.currentUser?.uid;
          final isClient = clientId != null && clientId == data["clientId"];

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.7, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Icon(
                    providerConfirmed
                        ? Icons.verified
                        : Icons.hourglass_top_rounded,
                    color:
                        providerConfirmed ? Colors.greenAccent : Colors.amber,
                    size: 95,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  providerConfirmed
                      ? "El trabajador confirmó la recepción."
                      : "Esperando que el trabajador confirme el pago...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // TARJETA DE DETALLES
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [cardColor1, cardColor2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detalles del pago",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _infoRow("Alias", data["alias"] ?? "-"),
                      const SizedBox(height: 10),
                      _infoRow("CBU / CVU", data["cbu"] ?? "-"),
                      const SizedBox(height: 10),
                      _infoRow(
                          "Método",
                          data["paymentMethod"] == "cash"
                              ? "Efectivo"
                              : "Transferencia"),
                      const SizedBox(height: 10),
                      _infoRow("Monto", "\$${data["amount"]}"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Spacer(),

                // BOTÓN CLIENTE: marcar que ya pagó
                if (isClient && !clientConfirmed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await paymentService.confirmPaymentByClient(paymentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Has marcado que realizaste el pago"),
                          ),
                        );
                      },
                      child: const Text(
                        "Ya realicé el pago",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                if (!isClient && !providerConfirmed)
                  const Text(
                    "Esperando confirmación del trabajador...",
                    style: TextStyle(color: Colors.white60),
                  ),

                const SizedBox(height: 12),

                // BOTÓN CANCELAR
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("payments")
                          .doc(paymentId)
                          .update({"status": "failed"});

                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar solicitud",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  // === WIDGET INLINE PARA MOSTRAR FILAS DE INFORMACIÓN ===
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
