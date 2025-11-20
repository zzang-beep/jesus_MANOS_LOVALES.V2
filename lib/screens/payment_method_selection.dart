import 'package:flutter/material.dart';
import 'payment_details.dart';

class PaymentMethodSelection extends StatelessWidget {
  final String workerId;
  final double amount;
  final String chatId;
  final String serviceId;
  final String? workerName; // opcional, si querés mostrar nombre en vez de id

  const PaymentMethodSelection({
    super.key,
    required this.workerId,
    required this.amount,
    required this.chatId,
    required this.serviceId,
    this.workerName,
  });

  @override
  Widget build(BuildContext context) {
    const azulPrincipal = Color(0xFF0F4C81);
    const azulClaro = Color(0xFF64B5F6);
    const fondoOscuro = Color(0xFF0A0E21);

    final displayName =
        (workerName != null && workerName!.isNotEmpty) ? workerName! : workerId;

    Widget methodCard({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text('Método de pago'),
        backgroundColor: azulPrincipal,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // patrón de fondo si existe
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_pattern.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.35),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.45),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // encabezado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments, color: Colors.white70),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Monto: ARS ${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Sin impuestos',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // explicación
                  const Text('Elige cómo querés pagar:',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),

                  // tarjetas de métodos
                  methodCard(
                    icon: Icons.money,
                    title: 'Efectivo',
                    subtitle: 'Pago en mano al trabajador',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentDetails(
                            workerId: workerId,
                            amount: amount,
                            chatId: chatId,
                            serviceId: serviceId,
                            method: 'cash',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  methodCard(
                    icon: Icons.swap_horiz,
                    title: 'Transferencia',
                    subtitle: 'Enviar a alias / CBU del trabajador',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentDetails(
                            workerId: workerId,
                            amount: amount,
                            chatId: chatId,
                            serviceId: serviceId,
                            method: 'transfer',
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // nota y botón cancelar
                  const Text(
                    'Recuerda: este flujo es simulado — no se realiza cobro real.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Volver',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
