import 'package:flutter/material.dart';
import 'dart:async';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

// ==================== PANTALLA 1: TRABAJADOR (PROVEEDOR) ====================
class PaymentConfirmationWorkerScreen extends StatefulWidget {
  final PaymentModel payment;

  const PaymentConfirmationWorkerScreen({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  State<PaymentConfirmationWorkerScreen> createState() =>
      _PaymentConfirmationWorkerScreenState();
}

class _PaymentConfirmationWorkerScreenState
    extends State<PaymentConfirmationWorkerScreen> {
  final PaymentService _paymentService = PaymentService();
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _checkForWarning();
  }

  void _startTimer() {
    _elapsed = widget.payment.timeElapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = widget.payment.timeElapsed;
      });
      
      // Mostrar advertencia después de 10 minutos
      if (_elapsed.inMinutes >= 10 && !widget.payment.shouldShowWarning) {
        _showWarningDialog();
      }
    });
  }

  void _checkForWarning() {
    if (widget.payment.shouldShowWarning && 
        widget.payment.warningShownAt == null) {
      Future.delayed(Duration.zero, _showWarningDialog);
    }
  }

  void _showWarningDialog() {
    if (!mounted) return;
    
    _paymentService.markWarningShown(widget.payment.paymentId!);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentWarningDialog(),
    );
  }

  Future<void> _confirmPayment() async {
    setState(() => _isConfirming = true);

    try {
      await _paymentService.confirmPaymentByProvider(widget.payment.paymentId!);
      
      if (!mounted) return;
      
      // Navegar a la pantalla de agradecimiento (mismo diseño)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentThankYouScreen(
            payment: widget.payment,
            isProvider: true,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isConfirming = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F3F),
              Color(0xFF003366),
              Color(0xFF001F3F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de check
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Color(0xFF001F3F),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  const Text(
                    'Pago Recibido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción
                  const Text(
                    'Confirma que el cliente\nte realizó el pago por el\nservicio.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Marcar como Recibido
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isConfirming ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF001F3F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isConfirming
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF001F3F),
                                ),
                              ),
                            )
                          : const Text(
                              'Marcar como Recibido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Timer y mensaje
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tiempo transcurrido: ${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Asegúrate de haber\nverificado el pago antes\nde confirmar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PANTALLA 2: AGRADECIMIENTO ====================
class PaymentThankYouScreen extends StatelessWidget {
  final PaymentModel payment;
  final bool isProvider;

  const PaymentThankYouScreen({
    Key? key,
    required this.payment,
    this.isProvider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F3F),
              Color(0xFF003366),
              Color(0xFF001F3F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de check
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Color(0xFF001F3F),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Título
                  const Text(
                    '¡Gracias!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Descripción
                  Text(
                    isProvider
                        ? 'Gracias por utilizar nuestro\nservicio para confirmar el\npago del cliente.\n\nTu reputación quedará\nreflejada en tu perfil.'
                        : 'Gracias por utilizar nuestro\nservicio. Te esperamos para\nfuturas solicitudes.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Finalizar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF001F3F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Finalizar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PANTALLA 3: ADVERTENCIA (DIÁLOGO) ====================
class PaymentWarningDialog extends StatelessWidget {
  const PaymentWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5FCC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de advertencia
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.warning,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Título
            const Text(
              '¡ATENCIÓN!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensaje
            const Text(
              'El comprador llamará en el\nconsiderado tiempo para\ncomunicar que no pagó o no\npor el servicio. Recuerda pagar\no tendrás penalti por el\nservicio. Esto puede resultar\nen suspensión\npermanentemente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Botón Entendido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A5FCC),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SCREEN WRAPPER CON STREAM ====================
class PaymentConfirmationScreenWrapper extends StatelessWidget {
  final String paymentId;
  final bool isProvider;

  const PaymentConfirmationScreenWrapper({
    Key? key,
    required this.paymentId,
    required this.isProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentService();

    return StreamBuilder<PaymentModel?>(
      stream: paymentService.paymentStream(paymentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundColor: Color(0xFF001F3F),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Pago no encontrado',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF001F3F),
          );
        }

        final payment = snapshot.data!;

        // Si es proveedor y el pago está pendiente
        if (isProvider && payment.isPending) {
          return PaymentConfirmationWorkerScreen(payment: payment);
        }

        // Si ya fue confirmado o completado
        if (payment.isConfirmedByProvider || payment.isCompleted) {
          return PaymentThankYouScreen(
            payment: payment,
            isProvider: isProvider,
          );
        }

        // Estado desconocido
        return Scaffold(
          body: Center(
            child: Text(
              'Estado del pago: ${payment.status}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF001F3F),
        );
      },
    );
  }
}
