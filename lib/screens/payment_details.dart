import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_input.dart';

class PaymentDetails extends StatefulWidget {
  final String workerId;
  final double amount;
  final String chatId;
  final String serviceId;
  final String method; // 'cash' or 'transfer'

  const PaymentDetails({
    super.key,
    required this.workerId,
    required this.amount,
    required this.chatId,
    required this.serviceId,
    required this.method,
  });

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  late TextEditingController _amountController;
  final azulPrincipal = const Color(0xFF1976D2);
  final azulClaro = const Color(0xFF64B5F6);
  final fondoOscuro = const Color(0xFF0A0E21);

  @override
  void initState() {
    super.initState();
    // Inicializa el controller con el monto pasado
    _amountController =
        TextEditingController(text: widget.amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _parseAmount() {
    final text = _amountController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(text);
    return value ?? widget.amount;
  }

  void _onContinue() {
    final finalAmount = _parseAmount();
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido mayor a 0'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentInput(
          workerId: widget.workerId,
          amount: finalAmount,
          chatId: widget.chatId,
          serviceId: widget.serviceId,
          method: widget.method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methodLabel = widget.method == 'cash' ? 'Efectivo' : 'Transferencia';

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: const Text('Detalle del pago'),
        backgroundColor: azulPrincipal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              // Card principal
              Container(
                width: double.infinity,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Info trabajador
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trabajador',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.workerId,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Método: $methodLabel',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // placeholder para rating u otro tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Servicio',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Precio editable a la derecha
                    Container(
                      width: 140,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Precio',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          // Campo editable de monto con estilo
                          TextField(
                            controller: _amountController,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.,]')),
                            ],
                            decoration: const InputDecoration(
                              prefixText: 'ARS ',
                              prefixStyle: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Descripción / notas
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Detalles',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 8),
                    Text(
                      'Revisa el monto y método. Si elegiste transferencia, en la siguiente pantalla podrás ingresar alias/CBU y titular.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azulPrincipal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, letterSpacing: 0.2),
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
