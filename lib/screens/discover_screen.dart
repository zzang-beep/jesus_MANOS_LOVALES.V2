import 'package:flutter/material.dart';
import '../services/service_service.dart';
import '../services/category_service.dart';
import '../models/service_model.dart';
import '../models/category_model.dart';
import '../widgets/service_card_discover.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'widgets/discover_profile_card.dart';
import '../screens/unified_chat_list_screen.dart' hide HomeDashboardScreen;
import '../screens/profile_screen.dart';
import '../screens/home_dashboard_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _serviceService = ServiceService();
  final _categoryService = CategoryService();
  int _selectedIndex = 2; // Índice seleccionado en el BottomNavBar
  List<ServiceModel> _services = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _showingCandidates = false;

  // Filtros
  String? _selectedZone;
  List<String> _selectedJobTypes = [];

  // Zonas disponibles
  final List<String> _zones = [
    'Zona Norte',
    'Zona Sur',
    'Zona Este',
    'Zona Oeste',
  ];

  // Tipos de empleo (basados en categorías)
  final List<String> _jobTypes = [
    'Servicios de Hogar',
    'Tecnología',
    'Automación',
    'Educación y Clases',
    'Todos',
  ];

  final List<Map<String, dynamic>> _demoCandidates = [
    {
      "id": "cand_juan",
      "nombre": "Juan Rodríguez",
      "profesion": "Plomero Profesional",
      "experiencia":
          "5 años de experiencia resolviendo urgencias domiciliarias.",
      "ubicacion": "Zona Oeste",
      "zona": "Zona Oeste",
      "descripcion":
          "Especialista en instalaciones y reparaciones sin romper paredes.",
      "foto": "assets/images/inicio3.png",
    },
    {
      "id": "cand_maria",
      "nombre": "María López",
      "profesion": "Niñera con referencias",
      "experiencia": "3 años acompañando familias en Palermo y Núñez.",
      "ubicacion": "Zona Este",
      "zona": "Zona Este",
      "descripcion":
          "Docente de nivel inicial con disponibilidad part-time y primeros auxilios.",
      "foto": "assets/images/inicio1.png",
    },
    {
      "id": "cand_lucas",
      "nombre": "Lucas Fernández",
      "profesion": "Profesor de matemáticas",
      "experiencia": "10 años enseñando con enfoque personalizado.",
      "ubicacion": "Zona Norte",
      "zona": "Zona Norte",
      "descripcion": "Clases virtuales y presenciales para nivel secundario.",
      "foto": "assets/images/inicio2.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _categoryService.getAllCategories();
      final services = await _serviceService.getAllServices(limit: 50);

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _services = _filterServices(services);
      });
    } catch (e) {
      print('Error loading discover data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ServiceModel> _filterServices(List<ServiceModel> services) {
    List<ServiceModel> filtered = services;

    // Filtrar por zona
    if (_selectedZone != null && _selectedZone!.isNotEmpty) {
      filtered = filtered.where((service) {
        return service.locationText
            .toLowerCase()
            .contains(_getZoneKeyword(_selectedZone!));
      }).toList();
    }

    // Filtrar por tipo de empleo (categorías)
    if (_selectedJobTypes.isNotEmpty && !_selectedJobTypes.contains('Todos')) {
      filtered = filtered.where((service) {
        return _matchesJobType(service.category);
      }).toList();
    }

    return filtered;
  }

  String _getZoneKeyword(String zone) {
    switch (zone) {
      case 'Zona Norte':
        return 'norte|belgrano|nuñez|palermo|colegiales|urquiza';
      case 'Zona Sur':
        return 'sur|boca|barracas|pompeya|parque';
      case 'Zona Este':
        return 'este|puerto madero|retiro|recoleta';
      case 'Zona Oeste':
        return 'oeste|caballito|flores|devoto|paternal';
      default:
        return '';
    }
  }

  bool _matchesJobType(String category) {
    for (var jobType in _selectedJobTypes) {
      switch (jobType) {
        case 'Servicios de Hogar':
          if ([
            'limpieza',
            'plomeria',
            'electricidad',
            'gasista',
            'pintura',
            'carpinteria'
          ].contains(category)) {
            return true;
          }
          break;
        case 'Tecnología':
          if (category == 'reparacion_pc') return true;
          break;
        case 'Automación':
          if (category == 'electricidad') return true;
          break;
        case 'Educación y Clases':
          if (category == 'clases_particulares') return true;
          break;
      }
    }
    return false;
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        title: 'Localización',
        icon: Icons.location_on,
        options: _zones,
        selectedOption: _selectedZone,
        onSelected: (value) {
          setState(() {
            _selectedZone = value;
            _loadData();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showJobTypeFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        List<String> tempSelection = List.from(_selectedJobTypes);
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF001F3F),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                border:
                    Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work, color: Colors.blue[300]),
                      const SizedBox(width: 12),
                      const Text(
                        'Tipo de empleo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._jobTypes.map((jobType) {
                    final isSelected = tempSelection.contains(jobType);
                    return CheckboxListTile(
                      title: Text(
                        jobType,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: isSelected,
                      activeColor: Colors.blue,
                      checkColor: Colors.white,
                      onChanged: (value) {
                        modalSetState(() {
                          if (jobType == 'Todos') {
                            if (value == true) {
                              tempSelection = ['Todos'];
                            } else {
                              tempSelection.clear();
                            }
                          } else {
                            if (value == true) {
                              tempSelection.remove('Todos');
                              tempSelection.add(jobType);
                            } else {
                              tempSelection.remove(jobType);
                            }
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedJobTypes = tempSelection;
                        });
                        _loadData();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000B1F),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F3F), // Azul oscuro
              Color(0xFF000B1F), // Azul más oscuro
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descubrir',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTab(
                          'Puestos de trabajo',
                          isSelected: !_showingCandidates,
                          showCandidates: false,
                        ),
                        const SizedBox(width: 12),
                        _buildTab(
                          'Candidatos',
                          isSelected: _showingCandidates,
                          showCandidates: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.location_on,
                        label: _selectedZone ?? 'Zona (Toca para elegir)',
                        onTap: _showLocationFilter,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterButton(
                        icon: Icons.work,
                        label: _selectedJobTypes.isEmpty
                            ? 'Todos'
                            : _selectedJobTypes.length == 1
                                ? _selectedJobTypes.first
                                : '${_selectedJobTypes.length} seleccionados',
                        onTap: _showJobTypeFilter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Lista de servicios (Manos locales)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _showingCandidates ? 'Talentos locales' : 'Manos locales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Grid de servicios
              Expanded(
                child: _showingCandidates
                    ? _buildCandidatesList()
                    : _buildServiceList(),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildServiceList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay servicios disponibles',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return ServiceCardDiscover(
          service: _services[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detalle_puesto',
              arguments: {
                'servicio': _services[index],
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCandidatesList() {
    if (_demoCandidates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline, color: Colors.white30, size: 72),
              const SizedBox(height: 12),
              const Text(
                'Aún no hay candidatos destacados para tu zona.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Publicá un servicio o ampliá tus filtros para encontrar nuevos perfiles.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showLocationFilter,
                icon: const Icon(Icons.location_on,
                    color: Colors.lightBlueAccent),
                label: const Text(
                  'Elegir otra zona',
                  style: TextStyle(color: Colors.lightBlueAccent),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _demoCandidates.length,
      itemBuilder: (context, index) {
        final candidate = _demoCandidates[index];
        return DiscoverProfileCard(
          data: candidate,
          isPuesto: false,
          onTapAvatar: () {
            Navigator.pushNamed(
              context,
              '/detalle_candidato',
              arguments: candidate,
            );
          },
          onTapCard: () {
            Navigator.pushNamed(
              context,
              '/detalle_candidato',
              arguments: candidate,
            );
          },
        );
      },
    );
  }

  Widget _buildTab(String label,
      {required bool isSelected, required bool showCandidates}) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        setState(() {
          _showingCandidates = showCandidates;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF001F3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[300], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400], size: 20),
          ],
        ),
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
              MaterialPageRoute(builder: (_) => const UnifiedChatListScreen()),
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
