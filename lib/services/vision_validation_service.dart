// lib/services/vision_validation_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisionValidationService {
  static const String _apiKey =
      'AIzaSyCpgWGfyuuoT9w-HccHzw8PRnjPnLXXJt0'; // Reemplaza con tu API Key real
  static const String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  static Future<VisionValidationResult> validateProfileImage(
      File imageFile) async {
    try {
      // Convertir imagen a base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Crear request para Google Vision API
      final response = await http.post(
        Uri.parse('$_visionUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {
                  'type': 'LABEL_DETECTION',
                  'maxResults': 10,
                },
                {
                  'type': 'SAFE_SEARCH_DETECTION',
                  'maxResults': 10,
                },
                {
                  'type': 'FACE_DETECTION',
                  'maxResults': 10,
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        return _parseVisionResponse(response.body);
      } else {
        throw 'Error en Vision API: ${response.statusCode}';
      }
    } catch (e) {
      // Fallback a validación local básica
      return _fallbackValidation();
    }
  }

  static VisionValidationResult _parseVisionResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    final responses = data['responses'][0];

    // Verificar Safe Search (contenido inapropiado)
    final safeSearch = responses['safeSearchAnnotation'];
    if (safeSearch != null) {
      final adult = safeSearch['adult'];
      final violence = safeSearch['violence'];
      final racy = safeSearch['racy'];

      if (adult == 'LIKELY' ||
          adult == 'VERY_LIKELY' ||
          violence == 'LIKELY' ||
          violence == 'VERY_LIKELY' ||
          racy == 'LIKELY' ||
          racy == 'VERY_LIKELY') {
        return VisionValidationResult(
            isValid: false,
            message: '❌ La imagen contiene contenido inapropiado');
      }
    }

    // Verificar etiquetas (labels)
    final labels = responses['labelAnnotations'] ?? [];
    final labelDescriptions = labels
        .map<String>((label) => label['description'].toString().toLowerCase())
        .toList();

    // Etiquetas que indican que es una persona
    final personLabels = [
      'person',
      'human',
      'face',
      'portrait',
      'selfie',
      'headshot'
    ];

    // Etiquetas que indican objetos no permitidos
    final forbiddenLabels = [
      'animal',
      'cat',
      'dog',
      'pet',
      'vehicle',
      'car',
      'building',
      'house',
      'landscape',
      'nature',
      'food',
      'plant',
      'flower',
      'object',
      'electronics',
      'weapon',
      'violence',
      'cartoon',
      'drawing',
      'text',
      'logo',
      'brand'
    ];

    bool isPerson = labelDescriptions.any((label) =>
        personLabels.any((personLabel) => label.contains(personLabel)));

    bool hasForbiddenContent = labelDescriptions.any((label) =>
        forbiddenLabels.any((forbidden) => label.contains(forbidden)));

    // Verificar detección de rostros
    final faces = responses['faceAnnotations'] ?? [];
    bool hasFaces = faces.isNotEmpty;

    // Reglas de validación
    if (hasForbiddenContent && !isPerson) {
      return VisionValidationResult(
          isValid: false,
          message:
              '❌ Solo se permiten fotos de personas, no objetos o animales');
    }

    if (!isPerson && !hasFaces) {
      return VisionValidationResult(
          isValid: false, message: '❌ No se detectó una persona en la foto');
    }

    if (hasFaces) {
      // Validar calidad del rostro detectado
      final face = faces[0];
      final detectionConfidence = face['detectionConfidence'] ?? 0.0;

      if (detectionConfidence < 0.5) {
        return VisionValidationResult(
            isValid: false, message: '❌ Rostro detectado con baja calidad');
      }
    }

    return VisionValidationResult(
        isValid: true, message: '✅ Foto válida - Persona detectada');
  }

  static VisionValidationResult _fallbackValidation() {
    // Fallback básico - en caso de error de API, permitir la imagen
    // Pero mostrar advertencia
    return VisionValidationResult(
        isValid: true,
        message: '⚠️ Validación no disponible - Se acepta la imagen',
        isFallback: true);
  }
}

class VisionValidationResult {
  final bool isValid;
  final String message;
  final bool isFallback;

  VisionValidationResult({
    required this.isValid,
    required this.message,
    this.isFallback = false,
  });
}
