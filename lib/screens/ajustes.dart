import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manos_locales/screens/payment_dashboard.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/CerrarSesionDummy.dart';
import '../screens/CambiarPass.dart';
import '../screens/trabajos_publicados.dart';
import '../screens/trabajos_realizados.dart';
import 'DeleteAcount.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final userFirebase = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_pattern.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: SafeArea(
            child: StreamBuilder<UserModel?>(
              stream: userFirebase != null
                  ? _userService.getUserStream(userFirebase.uid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                final userModel = snapshot.data;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // BACK BUTTON
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 30),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Configuración",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ------------------ MI PERFIL ------------------
                      _seccionTitulo("Mi Perfil"),

                      menuItem(
                        icon: Icons.person,
                        texto: "Editar datos personales",
                        onTap: () {
                          if (userModel == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(user: userModel),
                            ),
                          );
                        },
                      ),

                      menuItem(
                        icon: Icons.delete,
                        texto: "Borrar cuenta",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DeleteAccount()),
                        ),
                      ),

                      menuItem(
                        icon: Icons.lock,
                        texto: "Cambiar contraseña",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen()),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ------------------ HISTORIAL ------------------
                      _seccionTitulo("Historial"),

                      menuItem(
                        icon: Icons.history,
                        texto: "Trabajos realizados",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ServiciosRealizadosScreen()),
                        ),
                      ),

                      menuItem(
                        icon: Icons.work,
                        texto: "Trabajos publicados",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ServiciosPublicadosScreen()),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ------------------ SEGURIDAD ------------------
                      _seccionTitulo("Seguridad"),

                      menuItem(
                        icon: Icons.security,
                        texto: "Métodos de pago",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentDashboard(
                                    workerId: '',
                                    amount: 0.0,
                                    chatId: '',
                                    serviceId: '',
                                  )),
                        ),
                      ),

                      const Spacer(),

                      // ------------------ CERRAR SESIÓN ------------------
                      Center(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 60, 160),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const Ajustes()),
                            ),
                            child: const Text(
                              "Cerrar sesión",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget menuItem({
    required IconData icon,
    required String texto,
    required Function onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
