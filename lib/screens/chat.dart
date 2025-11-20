import 'package:flutter/material.dart';
import '../screens/discover_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../models/chat_contact.dart';
import '../services/chat_contact_service.dart';
import '../screens/payment_dashboard.dart';

// ======================= LISTA DE CONTACTOS =======================
class ChatContactoScreen extends StatefulWidget {
  const ChatContactoScreen({super.key});

  @override
  State<ChatContactoScreen> createState() => _ChatContactoScreenState();
}

class _ChatContactoScreenState extends State<ChatContactoScreen> {
  final ChatContactService _contactService = ChatContactService();
  List<ChatContact> _contactos = [];
  bool _isLoading = true;
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactService.loadContacts();
    if (!mounted) return;
    setState(() {
      _contactos = contacts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo y degradado igual que Home
          SizedBox.expand(
            child: Image.asset('assets/images/background_pattern.png',
                fit: BoxFit.cover),
          ),
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
                const SizedBox(height: 10),
                const Text(
                  "Contactos",
                  style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.blueAccent))
                      : _contactos.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              onRefresh: _loadContacts,
                              child: ListView.builder(
                                itemCount: _contactos.length,
                                itemBuilder: (context, index) {
                                  final contacto = _contactos[index];
                                  return Card(
                                    color: const Color(0xFF1B263B)
                                        .withOpacity(0.8),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: contacto
                                                .photoUrl.isNotEmpty
                                            ? NetworkImage(contacto.photoUrl)
                                            : null,
                                        child: contacto.photoUrl.isEmpty
                                            ? const Icon(Icons.person,
                                                color: Colors.white)
                                            : null,
                                      ),
                                      title: Text(contacto.name,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      subtitle: Text(
                                        contacto.bio.isEmpty
                                            ? 'Zona ${contacto.zone.isEmpty ? 'sin especificar' : contacto.zone}'
                                            : contacto.bio,
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      trailing: contacto.zone.isEmpty
                                          ? null
                                          : Text(
                                              contacto.zone,
                                              style: const TextStyle(
                                                color: Colors.lightBlueAccent,
                                                fontSize: 12,
                                              ),
                                            ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChatScreen(contact: contacto),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, color: Colors.white30, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Todavía no agregaste contactos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buscá candidatos y usa el botón “Contactar” para guardar la conversación.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
              ),
              child: const Text('Buscar candidatos'),
            ),
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

// ======================= CHAT INDIVIDUAL =======================
class ChatScreen extends StatefulWidget {
  final ChatContact contact; // contacto seleccionado

  const ChatScreen({super.key, required this.contact});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Mensajes iniciales simulando coordinación
    _messages.addAll([
      {
        "text":
            "Hola, me gustaría contratarte para ${widget.contact.bio.toLowerCase()}.",
        "isMe": false
      },
      {
        "text": "Hola! Sí, puedo ayudarte. ¿Cuándo quieres hacerlo?",
        "isMe": true
      },
    ]);
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text.trim(), "isMe": true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo igual que Home
          SizedBox.expand(
            child: Image.asset('assets/images/background_pattern.png',
                fit: BoxFit.cover),
          ),
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
                // AppBar simulado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: widget.contact.photoUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(widget.contact.name,
                          style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54, height: 1),
                // Chat
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg["isMe"]
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: msg["isMe"]
                                ? Colors.lightBlueAccent.withOpacity(0.6)
                                : Colors.blueGrey.shade700,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg["text"],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Caja de mensaje + Botón de pago
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Campo de mensaje
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Mensaje...",
                                hintStyle:
                                    const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: Colors.black26,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.lightBlueAccent),
                            onPressed: _send,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // BOTÓN DE INICIAR PAGO
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.payments_outlined,
                              color: Colors.white),
                          label: const Text(
                            "Iniciar pago",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentDashboard(
                                  workerId: widget.contact
                                      .userId, // ✔ CORRECTO según tu modelo
                                  amount:
                                      0.0, // luego lo reemplazamos por el real
                                  chatId: widget.contact
                                      .userId, // si querés uso otro, decime
                                  serviceId:
                                      "service_test", // luego lo cambiamos por el real
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
