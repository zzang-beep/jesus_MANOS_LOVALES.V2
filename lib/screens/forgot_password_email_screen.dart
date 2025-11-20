import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState
    extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enviamos instrucciones a ${_emailController.text.trim()}',
          ),
        ),
      );
      Navigator.pushNamed(
        context,
        '/forgot-password-code',
        arguments: _emailController.text.trim(),
      );
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
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ForgotPasswordScaffold(
      title: '¿Olvidaste tu contraseña?',
      subtitle:
          'Ingresa el correo asociado a tu cuenta para enviarte un código de recuperación.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _PasswordField(
              controller: _emailController,
              label: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un correo';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A63FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Enviar código',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: const Text(
                'Volver al inicio de sesión',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ForgotPasswordScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final TextInputType keyboardType;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
