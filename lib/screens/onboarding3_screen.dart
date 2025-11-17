import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  Future<void> _finishAndGoTerms(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('seenOnboarding', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1220), Color(0xFF0F1630)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Image.asset('assets/images/inicio3.png', height: 240),
                const SizedBox(height: 24),
                const Text(
                  'Impulsamos la ayuda local entre vecinos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cada conexión fortalece tu barrio y ayuda a que más personas encuentren trabajo cerca de casa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const Spacer(),
                _buildPaginationRow(context, activeIndex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationRow(BuildContext context, {required int activeIndex}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleButton(Icons.arrow_back, () {
          Navigator.pushReplacementNamed(context, '/onboarding2');
        }),
        Row(
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    i == activeIndex ? const Color(0xFF5B6BFF) : Colors.white24,
              ),
            );
          }),
        ),
        _circleButton(Icons.check, () => _finishAndGoTerms(context)),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
