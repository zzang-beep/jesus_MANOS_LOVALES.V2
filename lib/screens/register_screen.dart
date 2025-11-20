import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/phone_verification_service.dart';
import '../models/user_model.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  final _phone = TextEditingController();

  bool _accepted = false;
  bool _loading = false;

  final AuthService _authService = AuthService();
  final PhoneVerificationService _phoneService = PhoneVerificationService();

  // Map para controlar visibilidad por label
  final Map<String, bool> _obscure = {};

  // Normaliza a +549XXXXXXXXX (Argentina). Ajusta si tu región cambia.
  String normalizePhone(String input) {
    String phone = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.startsWith('549')) return '+$phone';
    if (phone.startsWith('54')) return '+549${phone.substring(2)}';
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (phone.startsWith('9')) phone = phone.substring(1);

    return '+549$phone';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes aceptar los términos')));
      return;
    }

    if (_pass.text != _pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')));
      return;
    }

    setState(() => _loading = true);

    try {
      final formattedPhone = normalizePhone(_phone.text);

      // Crear usuario (Firebase Auth + Firestore en AuthService.signUp)
      final UserModel? newUser = await _authService.signUp(
        email: _email.text.trim(),
        password: _pass.text.trim(),
        name: _name.text.trim(),
        phone: formattedPhone,
      );

      if (newUser == null) throw 'Error al crear usuario';

      // Guardar userId localmente (para que otras pantallas lo consulten)
      final sp = await SharedPreferences.getInstance();
      await sp.setString('userId', newUser.userId);
      await sp.setBool('loggedIn', false); // aún no completo verificación

      // Enviar mail de verificación (Firebase)
      await _authService.sendEmailVerification();

      // NO enviar OTP desde aquí (lo hará PhoneVerificationScreen)
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/verify-email');
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('email address is already in use') ||
          msg.contains('email-already-in-use')) {
        msg = 'Este correo ya está registrado.';
      } else if (msg.contains('network')) {
        msg = 'Error de conexión.';
      } else if (msg.contains('password') || msg.contains('weak-password')) {
        msg = 'La contraseña es demasiado débil.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final azulPrincipal = const Color(0xFF1976D2);
    final azulClaro = const Color(0xFF64B5F6);
    final fondoOscuro = const Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: fondoOscuro,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LOGO
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 80),
                    ),
                  ),

                  const Text(
                    'CREAR CUENTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInput(_name, 'Nombre de usuario'),
                  const SizedBox(height: 12),
                  _buildInput(_email, 'Email',
                      inputType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildInput(_pass, 'Contraseña',
                      obscure: true, enableVisibilityToggle: true),
                  const SizedBox(height: 12),
                  _buildInput(_pass2, 'Repetir contraseña',
                      obscure: true, enableVisibilityToggle: true),
                  const SizedBox(height: 12),
                  _buildInput(_phone, 'Número de teléfono',
                      inputType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // Términos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _accepted,
                        activeColor: azulPrincipal,
                        onChanged: (v) =>
                            setState(() => _accepted = v ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // push para NO recrear el form al volver
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TermsScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                              children: [
                                const TextSpan(
                                    text: 'Al crear una cuenta, acepta los '),
                                TextSpan(
                                  text: 'términos y condiciones',
                                  style: TextStyle(
                                      color: azulClaro,
                                      decoration: TextDecoration.underline),
                                ),
                                const TextSpan(text: ' de la empresa.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: azulPrincipal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _submit,
                            child: const Text('Registrarse',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),

                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70),
                        children: [
                          const TextSpan(text: '¿Ya tienes una cuenta? '),
                          TextSpan(
                            text: 'Iniciar sesión',
                            style: TextStyle(
                                color: azulClaro,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ],
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

  Widget _buildInput(TextEditingController controller, String label,
      {bool obscure = false,
      TextInputType inputType = TextInputType.text,
      bool enableVisibilityToggle = false}) {
    // inicializar valor si no existe
    if (obscure && !_obscure.containsKey(label)) {
      _obscure[label] = true;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscure ? (_obscure[label] ?? true) : false,
      keyboardType: inputType,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo obligatorio';
        if (label.toLowerCase().contains('email') &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
          return 'Email inválido';
        }
        if (label.toLowerCase().contains('contraseña') && v.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white)),
        filled: true,
        fillColor: Colors.white10,
        suffixIcon: enableVisibilityToggle
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _obscure[label] = !(_obscure[label] ?? true);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    _obscure[label] == true
                        ? 'assets/images/eye2.png'
                        : 'assets/images/eye.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(
                      _obscure[label] == true
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
