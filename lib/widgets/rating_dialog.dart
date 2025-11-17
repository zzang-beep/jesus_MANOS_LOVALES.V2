import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:manos_locales/services/integration_service.dart';
import 'package:manos_locales/services/auth_service.dart';
import 'package:manos_locales/services/user_service.dart';

class RatingDialog extends StatefulWidget {
  final String serviceId;
  final String providerId;

  const RatingDialog({
    Key? key,
    required this.serviceId,
    required this.providerId,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una calificación')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId == null) throw 'Debes iniciar sesión';

      final userService = UserService();
      final user = await userService.getUserById(userId);

      if (user == null) throw 'Usuario no encontrado';

      final integrationService = IntegrationService();
      await integrationService.createRatingAndUpdate(
        serviceId: widget.serviceId,
        providerId: widget.providerId,
        userId: user.userId,
        userName: user.name,
        score: _selectedRating,
      );

      Navigator.pop(context, true); // Cerrar dialog con éxito
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90E2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const Text(
              'Calificar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Estrellas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  icon: Icon(
                    star <= _selectedRating ? Icons.star : Icons.star_border,
                    size: 48,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _selectedRating = star);
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            // Texto de calificación
            if (_selectedRating > 0)
              Text(
                _getRatingText(_selectedRating),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 30),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Enviar calificación',
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

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}

// Función helper para mostrar el diálogo
Future<void> showRatingDialog(
  BuildContext context, {
  required String serviceId,
  required String providerId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => RatingDialog(
      serviceId: serviceId,
      providerId: providerId,
    ),
  );
  if (result == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Calificación enviada')),
    );
  }
}
