import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../services/service_service.dart';
import 'package:geocoding/geocoding.dart';

class MapaServiciosScreen extends StatefulWidget {
  final String? filterCategory;
  
  const MapaServiciosScreen({Key? key, this.filterCategory}) : super(key: key);

  @override
  State<MapaServiciosScreen> createState() => _MapaServiciosScreenState();
}

class _MapaServiciosScreenState extends State<MapaServiciosScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ServiceService _serviceService = ServiceService();
  
  // Estado
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filteredServices = [];
  Set<Marker> _markers = {};
  ServiceModel? _selectedService;
  bool _isLoading = true;
  Position? _currentPosition;
  String? _errorMessage;
  
  // Posición por defecto (San Miguel de Tucumán)
  static const LatLng _defaultPosition = LatLng(-26.8241, -65.2226);
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadServices();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultPosition();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultPosition();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultPosition();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      _setDefaultPosition();
    }
  }

  void _setDefaultPosition() {
    setState(() => _currentPosition = Position(
      latitude: _defaultPosition.latitude,
      longitude: _defaultPosition.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    ));
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    
    try {
      List<ServiceModel> services;
      
      if (widget.filterCategory != null) {
        services = await _serviceService.getServicesByCategory(widget.filterCategory!);
      } else {
        services = await _serviceService.getAllServices(limit: 50);
      }

      _allServices = services;
      _filteredServices = services;
      
      await _createMarkersFromServices();
      
      setState(() => _isLoading = false);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar servicios: $e';
      });
    }
  }

  Future<void> _createMarkersFromServices() async {
    final Set<Marker> markers = {};
    
    // Mapa para agrupar servicios por ubicación
    final Map<String, List<ServiceModel>> servicesByLocation = {};
    
    for (var service in _filteredServices) {
      final location = service.locationText.toLowerCase().trim();
      if (!servicesByLocation.containsKey(location)) {
        servicesByLocation[location] = [];
      }
      servicesByLocation[location]!.add(service);
    }

    // Crear un marcador por cada ubicación única
    int markerIndex = 0;
    for (var entry in servicesByLocation.entries) {
      try {
        final LatLng? coordinates = await _getCoordinatesFromLocation(entry.key);
        
        if (coordinates != null) {
          final services = entry.value;
          final marker = Marker(
            markerId: MarkerId('location_$markerIndex'),
            position: coordinates,
            icon: _selectedService != null && 
                  services.any((s) => s.serviceId == _selectedService!.serviceId)
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(
              title: entry.key,
              snippet: '${services.length} servicio${services.length > 1 ? 's' : ''}',
            ),
            onTap: () => _onMarkerTapped(services.first),
          );
          
          markers.add(marker);
          markerIndex++;
        }
      } catch (e) {
        print('Error procesando ubicación ${entry.key}: $e');
      }
    }

    setState(() => _markers = markers);
  }

  Future<LatLng?> _getCoordinatesFromLocation(String locationText) async {
    // Cache de ubicaciones comunes en Tucumán
    final Map<String, LatLng> commonLocations = {
      'san miguel de tucumán': LatLng(-26.8241, -65.2226),
      'tucuman': LatLng(-26.8241, -65.2226),
      'yerba buena': LatLng(-26.8167, -65.3000),
      'tafi viejo': LatLng(-26.7333, -65.2667),
      'banda del rio sali': LatLng(-26.8386, -65.1847),
      'concepcion': LatLng(-27.3456, -65.5931),
      'san remo': LatLng(-26.8261, -65.2246),
      'centro': LatLng(-26.8283, -65.2176),
      'palermo': LatLng(-26.8200, -65.2100),
    };

    final normalizedLocation = locationText.toLowerCase().trim();
    
    // Buscar en cache primero
    if (commonLocations.containsKey(normalizedLocation)) {
      return commonLocations[normalizedLocation];
    }

    // Intentar geocodificar
    try {
      final locations = await locationFromAddress('$locationText, Tucumán, Argentina');
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Error geocodificando $locationText: $e');
    }

    // Ubicación por defecto con pequeño offset aleatorio
    final random = DateTime.now().millisecond / 1000;
    return LatLng(
      _defaultPosition.latitude + (random * 0.05 - 0.025),
      _defaultPosition.longitude + (random * 0.05 - 0.025),
    );
  }

  void _onMarkerTapped(ServiceModel service) {
    setState(() => _selectedService = service);
    _createMarkersFromServices();
  }

  Future<void> _centerMapOnUserLocation() async {
    if (_currentPosition != null) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Cargando servicios...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildMapSection(),
        _buildServicesSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.filterCategory != null
                      ? 'Servicios de ${widget.filterCategory}'
                      : 'Descubre servicios cerca de ti',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${_filteredServices.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final initialPosition = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultPosition;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 13.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
            if (_selectedService != null) _buildInfoCard(),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF001F3F),
                onPressed: _centerMapOnUserLocation,
                child: const Icon(Icons.my_location, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    if (_selectedService == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 60,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF001F3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedService!.providerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _selectedService!.locationText,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _selectedService!.category,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    if (_filteredServices.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search_off, color: Colors.white54, size: 60),
              SizedBox(height: 16),
              Text(
                'No hay servicios disponibles',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Servicios cercanos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredServices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final service = _filteredServices[index];
                  return _buildServiceCard(service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final isNegotiable = service.price == null || service.priceText.toLowerCase().contains('convenir');
    
    return InkWell(
      onTap: () => _onMarkerTapped(service),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedService?.serviceId == service.serviceId
              ? const Color(0xFF003366)
              : const Color(0xFF002B5C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedService?.serviceId == service.serviceId
                ? Colors.blue
                : Colors.white.withOpacity(0.2),
            width: _selectedService?.serviceId == service.serviceId ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage: service.providerPhotoUrl.isNotEmpty
                  ? NetworkImage(service.providerPhotoUrl)
                  : null,
              child: service.providerPhotoUrl.isEmpty
                  ? Text(
                      service.providerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF001F3F),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.providerName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.locationText,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNegotiable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Text(
                            'Negociable',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.work, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        service.category,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      if (service.ratingCount > 0) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${service.ratingAvg.toStringAsFixed(1)} (${service.ratingCount})',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ] else
                        const Text(
                          'Sin calificaciones',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
