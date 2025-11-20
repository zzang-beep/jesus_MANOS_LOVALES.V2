import 'dart:convert';
import 'package:http/http.dart' as http;

class PerspectiveAPIService {
  static const String _apiKey = 'AIzaSyCOU0KXv2hPoTXaJll7_xUkYi6W1g6TuoI';
  static const String _baseUrl =
      'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

  static Future<ModerationResult> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'comment': {'text': text},
          'languages': ['es', 'en'], // Español e inglés
          'requestedAttributes': {
            'TOXICITY': {},
            'SEVERE_TOXICITY': {},
            'IDENTITY_ATTACK': {},
            'INSULT': {},
            'PROFANITY': {},
            'THREAT': {},
            'SEXUALLY_EXPLICIT': {},
            'FLIRTATION': {},
          },
          'doNotStore': true, // No guardar datos para privacidad
        }),
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw 'Error en API: ${response.statusCode}';
      }
    } catch (e) {
      // Fallback a lista local si la API falla
      return _fallbackModeration(text);
    }
  }

  static ModerationResult _parseResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    final attributeScores = data['attributeScores'];

    // Umbrales de tolerancia (ajustables)
    const thresholds = {
      'TOXICITY': 0.7,
      'SEVERE_TOXICITY': 0.6,
      'IDENTITY_ATTACK': 0.7,
      'INSULT': 0.7,
      'PROFANITY': 0.6,
      'THREAT': 0.8,
      'SEXUALLY_EXPLICIT': 0.5,
      'FLIRTATION': 0.7,
    };

    final List<String> flags = [];
    double highestScore = 0.0;

    for (final attribute in thresholds.keys) {
      final score =
          attributeScores[attribute]?['summaryScore']?['value'] ?? 0.0;
      if (score > thresholds[attribute]!) {
        flags.add(attribute);
        if (score > highestScore) highestScore = score;
      }
    }

    if (flags.isNotEmpty) {
      return ModerationResult(
        isApproved: false,
        confidence: highestScore,
        flags: flags,
        message: _getErrorMessage(flags),
      );
    }

    return ModerationResult(isApproved: true, confidence: 0.9);
  }

  static String _getErrorMessage(List<String> flags) {
    if (flags.contains('SEXUALLY_EXPLICIT') || flags.contains('PROFANITY')) {
      return '❌ Contenido sexual o lenguaje inapropiado detectado';
    } else if (flags.contains('TOXICITY') || flags.contains('INSULT')) {
      return '❌ Contenido tóxico o insultos detectados';
    } else if (flags.contains('THREAT')) {
      return '❌ Contenido amenazante detectado';
    } else if (flags.contains('FLIRTATION')) {
      return '❌ Contenido inapropiadamente coqueto detectado';
    }
    return '❌ Contenido inapropiado detectado';
  }

  static ModerationResult _fallbackModeration(String text) {
    // Lista local como respaldo
    final inappropriateWords = [
      'pene',
      'verga',
      'pija',
      'pito',
      'paja',
      'pajas',
      'masturbar',
      'masturbacion',
      'sexo',
      'follar',
      'coger',
      'coito',
      'copular',
      'culo',
      'ano',
      'vagina',
      'pechos',
      'tetas',
      'prostituta',
      'escort',
      'puta',
      'zorra',
      'perra',
      'porno',
      'xxx',
      'onlyfans',
      'desnudo',
      'desnuda',
      'masturbación',
      'droga',
      'marihuana',
      'cocaina',
      'alcohol',
      'borracho',
      'drogas',
      'insulto',
      'idiota',
      'estupido',
      'imbecil',
      'retrasado',
      'subnormal',
      'matarte',
      'matar',
      'muerte',
      'suicidio',
      'estúpido',
      'imbécil',
    ];

    final lowerText = text.toLowerCase();
    for (final word in inappropriateWords) {
      if (lowerText.contains(word)) {
        return ModerationResult(
          isApproved: false,
          confidence: 0.9,
          flags: ['banned_word'],
          message: 'Contenido inapropiado detectado',
        );
      }
    }

    return ModerationResult(isApproved: true, confidence: 0.8);
  }
}

class ModerationResult {
  final bool isApproved;
  final double confidence;
  final List<String> flags;
  final String? message;

  ModerationResult({
    required this.isApproved,
    this.confidence = 1.0,
    this.flags = const [],
    this.message,
  });
}
