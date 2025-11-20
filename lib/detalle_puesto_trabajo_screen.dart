import 'package:flutter/material.dart';

import 'models/chat_contact.dart';
import 'models/service_model.dart';
import 'models/rating_model.dart';
import 'services/chat_contact_service.dart';
import 'services/rating_service.dart';
import 'screens/chat.dart';
import 'widgets/rating_dialog.dart';

class DetallePuestoScreen extends StatefulWidget {
  const DetallePuestoScreen({super.key});

  @override
  State<DetallePuestoScreen> createState() => _DetallePuestoScreenState();
}

class _DetallePuestoScreenState extends State<DetallePuestoScreen> {
  final ChatContactService _chatContactService = ChatContactService();
  final RatingService _ratingService = RatingService();

  ServiceModel? _service;
  String _titulo = 'Título no disponible';
  String _descripcion = 'Descripción no disponible';
  String _precio = 'A convenir';
  String _ubicacion = 'Zona sin especificar';
  String _foto = 'assets/images/logo.png';
  String _providerName = 'Publicado por un vecino';
  String _providerId = 'sin_id';
  Future<List<RatingModel>>? _ratingsFuture;
  bool _parsedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_parsedArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    _parseArguments(args);

    if (_service?.serviceId != null) {
      _ratingsFuture = _ratingService.getServiceRatings(_service!.serviceId!);
    }
    _parsedArgs = true;
    setState(() {});
  }

  void _parseArguments(dynamic args) {
    if (args is ServiceModel) {
      _service = args;
    } else if (args is Map<String, dynamic>) {
      if (args['servicio'] is ServiceModel) {
        _service = args['servicio'] as ServiceModel;
      }
    }

    _titulo = _service?.title ??
        (args is Map<String, dynamic> ? args['titulo'] as String? : null) ??
        _titulo;
    _descripcion = _service?.description ??
        (args is Map<String, dynamic> ? args['descripcion'] as String? : null) ??
        _descripcion;
    _precio = _service?.formattedPrice ??
        (args is Map<String, dynamic> ? args['precio'] as String? : null) ??
        _precio;
    _ubicacion = _service?.locationText ??
        (args is Map<String, dynamic> ? args['ubicacion'] as String? : null) ??
        _ubicacion;
    final foto =
        _service?.photoUrl ?? (args is Map<String, dynamic> ? args['foto'] as String? : null);
    if ((foto ?? '').isNotEmpty) {
      _foto = foto!;
    }
    _providerName = _service?.providerName ??
        (args is Map<String, dynamic> ? args['proveedor'] as String? : null) ??
        _providerName;
    _providerId = _service?.providerId ??
        (args is Map<String, dynamic> ? args['providerId'] as String? : null) ??
        _providerId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del puesto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: _foto.startsWith('http')
                    ? Image.network(_foto, fit: BoxFit.cover)
                    : Image.asset(_foto, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white54, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _ubicacion,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _precio,
                  style: const TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPublisherCard(),
            const SizedBox(height: 24),
            const Text(
              'Descripción del trabajo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _descripcion,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildRatingSection(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.work_outline),
                    label: const Text('Contactar'),
                    onPressed: () => _contactProvider(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('Ver perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                      side: const BorderSide(color: Colors.lightBlueAccent),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/detalle_candidato',
                        arguments: {
                          'id': _providerId,
                          'nombre': _providerName,
                          'profesion': _titulo,
                          'ubicacion': _ubicacion,
                          'zona': _ubicacion,
                          'descripcion': _descripcion,
                          'experiencia':
                              'Este proveedor aún no cargó su experiencia.',
                          'foto': _service?.providerPhotoUrl ?? _foto,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublisherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001F3F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey.withOpacity(0.3),
            backgroundImage: _service?.providerPhotoUrl.isNotEmpty == true
                ? NetworkImage(_service!.providerPhotoUrl)
                : null,
            child: _service?.providerPhotoUrl.isEmpty ?? true
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _providerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Publicador del aviso',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    if (_service?.serviceId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF001F3F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Las valoraciones estarán disponibles una vez que el servicio esté publicado en la app.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return FutureBuilder<List<RatingModel>>(
      future: _ratingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF001F3F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child:
                  CircularProgressIndicator(color: Colors.lightBlueAccent),
            ),
          );
        }

        final ratings = snapshot.data ?? [];
        final average = ratings.isEmpty
            ? _service!.ratingAvg
            : _ratingService.calculateAverage(ratings);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF001F3F),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    ratings.isEmpty && average == 0
                        ? 'Sin valoraciones'
                        : '$average (${ratings.length} valoraciones)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _service?.serviceId == null
                        ? null
                        : () => _openRatingDialog(),
                    icon: const Icon(Icons.rate_review, color: Colors.white70),
                    label: const Text(
                      'Calificar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (ratings.isEmpty)
                const Text(
                  'Sé el primero en dejar una valoración sobre este trabajo.',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ...ratings.take(3).map(
                  (rating) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              rating.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < rating.score
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rating.comment.isEmpty
                              ? 'Sin comentario'
                              : rating.comment,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRatingDialog() async {
    if (_service?.serviceId == null) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RatingDialog(
        serviceId: _service!.serviceId!,
        providerId: _service!.providerId,
      ),
    );

    if (result == true) {
      if (!mounted) return;
      setState(() {
        _ratingsFuture = _ratingService.getServiceRatings(_service!.serviceId!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Calificación enviada')),
      );
    }
  }

  Future<void> _contactProvider() async {
    final contact = ChatContact(
      userId: _providerId,
      name: _providerName,
      bio: _titulo,
      zone: _ubicacion,
    );

    await _chatContactService.addContact(contact);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(contact: contact)),
    );
  }
}
