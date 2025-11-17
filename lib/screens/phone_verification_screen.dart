import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/phone_verification_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _codeController = TextEditingController();
  final _phoneService = PhoneVerificationService();
  String? _userId;
  String? _realPhone;
  String? _phoneMasked;

  bool _loading = false;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndSendCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Carga usuario → obtiene teléfono → envía OTP una sola vez
  Future<void> _loadUserAndSendCode() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final uid = sp.getString('userId');
      setState(() => _userId = uid);

      if (uid == null) return;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final phone = doc.data()?['phone'] as String?;
      if (phone != null && phone.isNotEmpty) {
        _realPhone = phone;
        _phoneMasked = _maskPhone(phone);

        // Enviar OTP al abrir pantalla
        await _phoneService.sendOTP(phone);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error inicializando: $e")),
        );
      }
    }

    if (mounted) setState(() => _initializing = false);
  }

  /// Enmascara el teléfono para UI
  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      final last = digits.substring(digits.length - 4);
      final prefix = phone.replaceAll(last, '');
      return '$prefix**';
    }
    return phone;
  }

  /// Verifica código ingresado
  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showMessage("Ingresa el código recibido");
      return;
    }

    setState(() => _loading = true);

    try {
      final ok = await _phoneService.verifyCode(_codeController.text.trim());
      if (ok) {
        final sp = await SharedPreferences.getInstance();
        await sp.setBool('loggedIn', true);

        _showMessage("Teléfono verificado ✅");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage("Código incorrecto ❌");
      }
    } catch (e) {
      _showMessage("Error: $e", error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Reenvía nuevo OTP
  Future<void> _resendCode() async {
    if (_realPhone == null) {
      _showMessage("No se encontró número telefónico", error: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await _phoneService.resendOTP(_realPhone!);
      _showMessage("Código reenviado ✅");
    } catch (e) {
      _showMessage("Error al reenviar: $e", error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final azulPrincipal = const Color(0xFF1976D2);
    final fondoOscuro = const Color(0xFF0A0E21);

    return Scaffold(
      backgroundColor: fondoOscuro,
      body: SafeArea(
        child: _initializing
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sms, color: Colors.white, size: 100),
                    const SizedBox(height: 30),
                    const Text(
                      'Verificación de teléfono',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (_phoneMasked != null)
                      Text(
                        'Se envió un SMS a $_phoneMasked',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 25),

                    // INPUT code
                    TextField(
                      controller: _codeController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Código SMS',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white30)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        counterStyle: TextStyle(color: Colors.white70),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            children: [
                              // botón verificar
                              ElevatedButton(
                                onPressed: _verifyCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: azulPrincipal,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Verificar código',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // botón reenviar
                              OutlinedButton(
                                onPressed: _resendCode,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white70),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Reenviar código',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
