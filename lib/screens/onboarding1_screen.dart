import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  Future<void> _skipOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
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
                Image.asset('assets/images/inicio1.png', height: 240),
                const SizedBox(height: 24),
                const Text(
                  'Resolvé tus necesidades de forma ágil y con bajo costo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Buscá por categoría, compará opciones y contactá directamente a la persona indicada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const Spacer(),
                _buildPaginationRow(
                  context,
                  activeIndex: 0,
                  nextRoute: '/onboarding2',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationRow(
    BuildContext context, {
    required int activeIndex,
    required String nextRoute,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => _skipOnboarding(context),
          child: const Text(
            'Saltar',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
        _circleButton(Icons.arrow_forward, () {
          Navigator.pushReplacementNamed(context, nextRoute);
        }),
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
