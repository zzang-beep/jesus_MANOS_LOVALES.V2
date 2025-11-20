import 'package:flutter/material.dart';
import 'payment_method_selection.dart';

class PaymentDashboard extends StatelessWidget {
  final String workerId;
  final String? workerName; // opcional: mostrar nombre en vez de id
  final double amount;
  final String chatId;
  final String serviceId;

  const PaymentDashboard({
    super.key,
    required this.workerId,
    required this.amount,
    required this.chatId,
    required this.serviceId,
    this.workerName,
  });

  @override
  Widget build(BuildContext context) {
    const azulPrincipal = Color(0xFF0F4C81); // tono azul profundo
    const azulClaro = Color(0xFF64B5F6);
    const fondoOscuro = Color(0xFF0A0E21);

    final displayName =
        (workerName != null && workerName!.isNotEmpty) ? workerName! : workerId;

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text('Realizar pago'),
        backgroundColor: azulPrincipal,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // fondo con patrón (si ya tenés assets/images/background_pattern.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_pattern.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.35),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // overlay con gradiente
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABECERA CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // avatar placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.person, color: Colors.white70),
                        ),
                        const SizedBox(width: 14),

                        // nombre + subtitulo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Vas a pagar por el servicio acordado',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Monto pequeño arriba derecha
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Monto',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(
                              'ARS ${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONTENIDO PRINCIPAL: tarjeta con detalle y acciones
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white10,
                            Colors.white12,
                          ],
                        ),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Detalles del pago',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 10),

                          // fila precio grande
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Precio acordado',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text('ARS ${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // info adicional (puedes extender con rating, servicio)
                          Row(
                            children: [
                              // tag method
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Pago directo',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('Sin impuestos',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // descripción más grande
                          const Text('Notas',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 8),
                          const Text(
                            'Revisa el monto y seleccioná el método. Si elegís transferencia, podrás ingresar alias/CBU y titular en la siguiente pantalla.',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 13),
                          ),

                          const Spacer(),

                          // Botones: Seleccionar método & Cancelar
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentMethodSelection(
                                          workerId: workerId,
                                          amount: amount,
                                          chatId: chatId,
                                          serviceId: serviceId,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azulPrincipal,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Seleccionar método',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
