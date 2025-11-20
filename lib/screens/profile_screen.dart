import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/unified_chat_list_screen.dart'
    hide UserModel, HomeDashboardScreen;
import '../screens/discover_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Iniciar sesión'),
          ),
        ),
      );
    }

    final uid = currentUser.uid;

    return StreamBuilder<UserModel?>(
      stream: _userService.getUserStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Usuario no encontrado')),
          );
        }

        final locationText =
            user.phone.isNotEmpty ? user.phone : 'Ubicación no disponible';
        final highlightText = user.bio.isNotEmpty
            ? user.bio
            : 'Los vecinos destacan tu puntualidad y buena atención.';
        final aboutText = user.bio.isNotEmpty
            ? user.bio
            : 'Añade una breve descripción para que los vecinos te conozcan.';

        return Scaffold(
          body: Stack(
            children: [
              // Fondo de pantalla
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/background_pattern.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Degradado sobre el fondo
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Perfil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                                border: Border.all(
                                  color: const Color(0xFF6B7CFF),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: user.photoUrl.isNotEmpty
                                    ? NetworkImage(user.photoUrl)
                                    : const AssetImage('assets/images/logo.png')
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              user.name.isNotEmpty
                                  ? user.name
                                  : 'Usuario sin nombre',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  locationText,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _RatingSection(rating: user.ratingAvg),
                            const SizedBox(height: 12),
                            Text(
                              highlightText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sobre mí',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                aboutText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _PrimaryButton(
                              label: 'Editar perfil',
                              color: const Color(0xFF5E5CF9),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(user: user),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _PrimaryButton(
                              label: 'Cerrar sesión',
                              color: const Color(0xFF121A59),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (!context.mounted) return;
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const _BottomNavBar(activeIndex: 3), // Índice 3 para Perfil
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            ...List.generate(5, (index) {
              final filled = rating >= index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: 20,
                  color: const Color(0xFF8E5CFF),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeDashboardScreen(), // Índice 0: Inicio
      const UnifiedChatListScreen(), // Índice 1: Chat
      const DiscoverScreen(), // Índice 2: Buscar
      ProfileScreen(), // Índice 3: Perfil
    ];
    final icons = [
      Icons.home_outlined,
      Icons.chat_bubble_outline,
      Icons.search,
      Icons.person
    ];

    final labels = ['Inicio', 'Chat', 'Buscar', 'Perfil'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (index) {
          final icon = icons[index];
          final label = labels[index];
          final isActive = index == activeIndex;
          return GestureDetector(
              // 👈 Añadir el Detector de Gestos
              onTap: () {
                // Navegar a la pantalla correspondiente
                // Reemplazar la pantalla actual si ya estamos en un nivel profundo
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => screens[index]),
                );
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  icon,
                  // Usamos isActive (basado en el índice) para el color
                  color: isActive ? Colors.lightBlueAccent : Colors.white54,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.lightBlueAccent : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ]));
        }),
      ),
    );
  }
}
