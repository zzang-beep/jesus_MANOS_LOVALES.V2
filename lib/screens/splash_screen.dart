// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startApp();
    });
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final acceptedTerms = prefs.getBool('acceptedTerms') ?? false;

    if (!mounted) return;

    try {
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        await currentUser.reload();
        if (!currentUser.emailVerified) {
          Navigator.pushReplacementNamed(context, '/verify-email');
          return;
        }

        final user = await _userService.getUserById(currentUser.uid);
        if (user == null) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        if (!user.phoneVerified) {
          Navigator.pushReplacementNamed(context, '/verify-phone');
          return;
        }

        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
    } catch (e) {
      // Si hay cualquier error consultando Firebase, reenvía al login
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error iniciando la app: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding1');
      return;
    }

    if (!acceptedTerms) {
      Navigator.pushReplacementNamed(context, '/terms');
      return;
    }

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1220),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 250,
              height: 250,
              errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              'Manos Locales',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFF5B6BFF)),
          ],
        ),
      ),
    );
  }
}
