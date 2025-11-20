import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';
import '../services/auth_service.dart';
import 'waiting_for_confirmation.dart';

class PaymentInput extends StatefulWidget {
  final String workerId;
  final double amount;
  final String chatId;
  final String serviceId;
  final String method;

  const PaymentInput({
    super.key,
    required this.workerId,
    required this.amount,
    required this.chatId,
    required this.serviceId,
    required this.method,
  });

  @override
  State<PaymentInput> createState() => _PaymentInputState();
}

class _PaymentInputState extends State<PaymentInput> {
  final _aliasCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _cbuCtrl = TextEditingController();
  final _paymentService = PaymentService();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _titularCtrl.dispose();
    _cbuCtrl.dispose();
    super.dispose();
  }

  Future<bool?> _showSummaryDialog({
    required double amount,
    required String method,
    String? alias,
    String? cbu,
    String? titular,
  }) {
    final azulPrincipal = const Color(0xFF1976D2);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0E21),
          title: Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.white70),
              const SizedBox(width: 8),
              const Text('Resumen de pago',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow(
                  'Método', method == 'cash' ? 'Efectivo' : 'Transferencia'),
              const SizedBox(height: 8),
              _buildSummaryRow('Monto', 'ARS ${amount.toStringAsFixed(2)}'),
              if (method != 'cash') ...[
                const SizedBox(height: 8),
                _buildSummaryRow('Alias', alias ?? '-'),
                const SizedBox(height: 6),
                _buildSummaryRow('CBU', cbu?.isNotEmpty == true ? cbu! : '-'),
                const SizedBox(height: 6),
                _buildSummaryRow(
                    'Titular', titular?.isNotEmpty == true ? titular! : '-'),
              ],
              const SizedBox(height: 8),
              const Text(
                'Confirmá que los datos son correctos. Este pago es simulado (no hay cobro real).',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: azulPrincipal),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600))),
      ],
    );
  }

  Future<void> _onConfirmPressed() async {
    final isTransfer = widget.method == 'transfer';

    // Validaciones básicas
    if (isTransfer && _aliasCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ingresa el alias para la transferencia'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Mostrar resumen de pago (diálogo propio)
    final confirmed = await _showSummaryDialog(
      amount: widget.amount,
      method: widget.method,
      alias: _aliasCtrl.text.trim(),
      cbu: _cbuCtrl.text.trim(),
      titular: _titularCtrl.text.trim(),
    );

    if (confirmed != true) return;

    // Crear PaymentModel y llamar al servicio
    setState(() => _loading = true);

    final clientId = _auth.currentUser?.uid;
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Debes iniciar sesión'),
          backgroundColor: Colors.redAccent));
      setState(() => _loading = false);
      return;
    }

    final payment = PaymentModel(
      chatId: widget.chatId,
      serviceId: widget.serviceId,
      providerId: widget.workerId,
      clientId: clientId,
      amount: widget.amount,
      paymentMethod: widget.method == 'cash' ? 'cash' : 'alias',
      alias: widget.method == 'transfer' ? _aliasCtrl.text.trim() : null,
      cbu: widget.method == 'transfer' ? _cbuCtrl.text.trim() : null,
      createdAt: DateTime.now(),
    );

    try {
      final paymentId = await _paymentService.createPayment(payment);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingForConfirmationScreen(paymentId: paymentId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error creando pago: $e'),
          backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azulPrincipal = const Color(0xFF1976D2);
    final fondoOscuro = const Color(0xFF0A0E21);
    final isTransfer = widget.method == 'transfer';

    return Scaffold(
      backgroundColor: fondoOscuro,
      appBar: AppBar(
        title: Text(
            widget.method == 'cash' ? 'Pago en efectivo' : 'Transferencia'),
        backgroundColor: azulPrincipal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            children: [
              // Card principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.white70),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(widget.workerId,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('ARS ${widget.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isTransfer
                          ? 'Completa los datos para transferencia'
                          : 'Confirma que vas a pagar en efectivo al finalizar el servicio',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Campos (si transferencia)
              if (isTransfer)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos de la cuenta destino',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 10),

                      // Alias
                      TextField(
                        controller: _aliasCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Alias (donde llegará la plata)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: azulPrincipal)),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Titular
                      TextField(
                        controller: _titularCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nombre del titular (opcional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: azulPrincipal)),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // CBU
                      TextField(
                        controller: _cbuCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: 'CBU / CVU (opcional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white12),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: azulPrincipal)),
                          filled: true,
                          fillColor: Colors.white12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              if (!isTransfer)
                Container(
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Pago en efectivo',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 8),
                      Text(
                        'Realiza el pago en efectivo al trabajador al finalizar el servicio. Confirmá cuando esté hecho.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Botón confirmar
              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onConfirmPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulPrincipal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Confirmar pago',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
