import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordCodeScreen extends StatefulWidget {
  const ForgotPasswordCodeScreen({super.key});

  @override
  State<ForgotPasswordCodeScreen> createState() =>
      _ForgotPasswordCodeScreenState();
}

class _ForgotPasswordCodeScreenState extends State<ForgotPasswordCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _authService = AuthService();
  String _email = '';
  bool _sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _email = args;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _extractCode(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http')) {
      try {
        final uri = Uri.parse(trimmed);
        return uri.queryParameters['oobCode'] ?? '';
      } catch (_) {
        return trimmed;
      }
    }
    return trimmed;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _extractCode(_codeController.text);
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos leer el código')),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/forgot-password-change',
      arguments: {'email': _email, 'code': code},
    );
  }

  Future<void> _resend() async {
    if (_email.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _authService.resetPassword(_email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código reenviado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050C1F), Color(0xFF0E1B47)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ingresar código',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Te hemos enviado un código a $_email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Código o enlace completo',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el código';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _continue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A63FF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _sending ? null : _resend,
                        child: _sending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Reenviar código',
                                style: TextStyle(
                                  color: Colors.white70,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
