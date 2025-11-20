import 'package:flutter/material.dart';

class ConfirmPaymentDialog extends StatelessWidget {
  final double amount;
  final String method;
  final String? alias;
  final String? cbu;
  final String? titular;

  const ConfirmPaymentDialog({
    super.key,
    required this.amount,
    required this.method,
    this.alias,
    this.cbu,
    this.titular,
  });

  @override
  Widget build(BuildContext context) {
    final methodLabel = method == 'cash' ? 'Efectivo' : 'Transferencia';

    return AlertDialog(
      title: const Text('Confirmar pago'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monto: ARS ${amount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text('Método: $methodLabel'),
          if (alias != null && alias!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Alias: $alias'),
          ],
          if (titular != null && titular!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Titular: $titular'),
          ],
          if (cbu != null && cbu!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('CBU: $cbu'),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar')),
        ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar')),
      ],
    );
  }
}
