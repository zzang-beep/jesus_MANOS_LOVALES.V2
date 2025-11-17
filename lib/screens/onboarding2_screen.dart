import 'package:flutter/material.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

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
                Image.asset('assets/images/inicio2.png', height: 240),
                const SizedBox(height: 24),
                const Text(
                  'Ofrecé tu oficio y hacé crecer tu trabajo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Publicá tus servicios, mostrà tu experiencia y recibí valoraciones de tus clientes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const Spacer(),
                _buildPaginationRow(context, activeIndex: 1),
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
          Navigator.pushReplacementNamed(context, '/onboarding1');
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
        _circleButton(Icons.arrow_forward, () {
          Navigator.pushReplacementNamed(context, '/onboarding3');
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
