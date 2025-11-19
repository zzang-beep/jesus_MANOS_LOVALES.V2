import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manos_locales/screens/profile_screen.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

// 🔹 IMPORTAR PANTALLAS NECESARIAS
import '../screens/discover_screen.dart';
import 'chat.dart';
import 'add_job_screen.dart'; // Para hacer publicación
import 'my_active_services_screen.dart'; // Para mis servicios
import 'my_services_requests_screen.dart'; // Para servicios/solicitudes
import '../services/service_service.dart'; // Para cargar trabajos
import '../models/service_model.dart'; // Para el modelo de servicios

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _userService = UserService();
  final _serviceService = ServiceService(); // Servicio para cargar trabajos

  UserModel? _currentUser;
  bool _loading = true;
  int _selectedIndex = 0;
  List<ServiceModel> _assignedJobs = []; // Lista de trabajos asignados

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAssignedJobs(); // Cargar trabajos al iniciar
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final user = await _userService.getUserById(uid);
    setState(() {
      _currentUser = user;
      _loading = false;
    });
  }

  // 🔹 CARGAR TRABAJOS ASIGNADOS DESDE FIREBASE
  Future<void> _loadAssignedJobs() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final services = await _serviceService.getProviderServices(uid);
        setState(() {
          _assignedJobs = services;
        });
      }
    } catch (e) {
      print('Error al cargar trabajos asignados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Degradado sobre el fondo para mejor lectura
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _currentUser == null
                    ? _buildLoggedOutState(context)
                    : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        // Perfil
                        CircleAvatar(
                          radius: 55,
                          backgroundImage:
                              (_currentUser?.photoUrl ?? "").isNotEmpty
                                  ? NetworkImage(_currentUser!.photoUrl)
                                  : null,
                          child: (_currentUser?.photoUrl ?? "").isEmpty
                              ? const Icon(Icons.person, size: 55)
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "¡Hola ${_currentUser?.name ?? "Usuario"}!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        _buildSummaryRow(),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        const SizedBox(height: 25),

                        // Tarjeta de Próximos trabajos (dinámica)
                        _buildAssignedJobsCard(),
                        const SizedBox(height: 20),

                        // Tarjeta de Hacer publicación con botón
                        _buildPublicationCard(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _summaryChip(
            label: 'Trabajos asignados',
            value: _assignedJobs.length.toString(),
          ),
          const SizedBox(width: 12),
          _summaryChip(
            label: 'Solicitudes activas',
            value: '—',
          ),
        ],
      ),
    );
  }

  Widget _summaryChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _HomeAction(
        title: 'Mis servicios activos',
        subtitle: 'Revisa los trabajos donde estás participando.',
        icon: Icons.work_outline,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyActiveServicesScreen()),
          );
        },
      ),
      _HomeAction(
        title: 'Mis solicitudes',
        subtitle: 'Gestioná a quienes quieren trabajar con vos.',
        icon: Icons.assignment_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MyServicesRequestsScreen()),
          );
        },
      ),
      _HomeAction(
        title: 'Descubrir candidatos',
        subtitle: 'Encontrá nuevas manos locales por zona.',
        icon: Icons.people_alt_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiscoverScreen()),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _quickActionCard(action),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _quickActionCard(_HomeAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: Colors.lightBlueAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  // TARJETA DE TRABAJOS ASIGNADOS (DINÁMICA)
  Widget _buildAssignedJobsCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Próximos trabajos",
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_assignedJobs.isEmpty)
            const Text(
              "No tienes próximos trabajos asignados para hoy. ¡Publica un servicio ahora!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          else
            Column(
              children: _assignedJobs
                  .take(3)
                  .map((job) => _buildJobItem(job))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ITEM INDIVIDUAL DE TRABAJO
  Widget _buildJobItem(ServiceModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.work, color: Colors.lightBlueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  job.description.length > 50
                      ? '${job.description.substring(0, 50)}...'
                      : job.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              job.formattedPrice,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DE PUBLICACIÓN CON BOTÓN
  Widget _buildPublicationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Hacer publicación",
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Comparte novedades o asignaciones rápidamente.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddJobScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Crear Publicación",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NAV BAR CON ICONOS MASCULINOS
  Widget _bottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0D1B2A),
      selectedItemColor: Colors.lightBlueAccent,
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navegación según el índice tocado
        switch (index) {
          case 0: // Inicio
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
            );
            break;

          case 1: // Chat
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatContactoScreen()),
            );
            break;

          case 2: // Buscar (Discover)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DiscoverScreen()),
            );
            break;

          case 3: // Perfil
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Perfil"),
      ],
    );
  }
}

class _HomeAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

  Widget _buildLoggedOutState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline,
                color: Colors.white70, size: 72),
            const SizedBox(height: 20),
            const Text(
              'Inicia sesión para ver tu tablero',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ir a iniciar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
