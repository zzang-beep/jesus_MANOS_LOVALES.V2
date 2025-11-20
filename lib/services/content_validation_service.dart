// lib/services/content_validation_service.dart
import 'perspective_api_service.dart';

class ContentValidationService {
  static Future<ValidationResult> validateJobPosting({
    required String title,
    required String description,
    required String category,
  }) async {
    final List<ValidationIssue> issues = [];

    // Validar título con Perspective API
    final titleModeration = await PerspectiveAPIService.analyzeText(title);
    if (!titleModeration.isApproved) {
      issues.add(ValidationIssue(
          field: 'title',
          message: titleModeration.message ?? 'Título inapropiado',
          severity: ValidationSeverity.high));
    }

    // Validar descripción con Perspective API
    final descModeration = await PerspectiveAPIService.analyzeText(description);
    if (!descModeration.isApproved) {
      issues.add(ValidationIssue(
          field: 'description',
          message: descModeration.message ?? 'Descripción inapropiada',
          severity: ValidationSeverity.high));
    }

    // Validaciones básicas de longitud
    if (title.length < 3) {
      issues.add(ValidationIssue(
          field: 'title',
          message: 'El título debe tener al menos 3 caracteres',
          severity: ValidationSeverity.medium));
    }

    if (description.length < 10) {
      issues.add(ValidationIssue(
          field: 'description',
          message: 'La descripción debe tener al menos 10 caracteres',
          severity: ValidationSeverity.medium));
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  static Future<ValidationResult> validateProfile({
    required String name,
    required String bio,
  }) async {
    final List<ValidationIssue> issues = [];

    // Validar nombre con Perspective API
    final nameModeration = await PerspectiveAPIService.analyzeText(name);
    if (!nameModeration.isApproved) {
      issues.add(ValidationIssue(
          field: 'name',
          message: nameModeration.message ?? 'Nombre inapropiado',
          severity: ValidationSeverity.high));
    }

    // Validar biografía con Perspective API
    final bioModeration = await PerspectiveAPIService.analyzeText(bio);
    if (!bioModeration.isApproved) {
      issues.add(ValidationIssue(
          field: 'bio',
          message: bioModeration.message ?? 'Biografía inapropiada',
          severity: ValidationSeverity.high));
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  // Para validar mensajes de chat
  static Future<ValidationResult> validateChatMessage(String message) async {
    final List<ValidationIssue> issues = [];

    final messageModeration = await PerspectiveAPIService.analyzeText(message);
    if (!messageModeration.isApproved) {
      issues.add(ValidationIssue(
          field: 'message',
          message: messageModeration.message ?? 'Mensaje inapropiado',
          severity: ValidationSeverity.high));
    }

    return ValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;

  ValidationResult({required this.isValid, required this.issues});
}

class ValidationIssue {
  final String field;
  final String message;
  final ValidationSeverity severity;

  ValidationIssue({
    required this.field,
    required this.message,
    required this.severity,
  });
}

enum ValidationSeverity { low, medium, high }
