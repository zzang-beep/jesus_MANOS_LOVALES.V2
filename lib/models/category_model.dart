import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String icon;
  final String color; // HEX
  final int order;
  final bool active;
  final bool isCustom;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    required this.active,
    this.isCustom = false,
  });

  // ---- FROM FIRESTORE ----
  factory CategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return CategoryModel(
      categoryId: id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'more_horiz',
      color: data['color'] ?? '#1976D2',
      order: data['order'] ?? 999,
      active: data['active'] ?? false,
      isCustom: data['isCustom'] ?? false,
    );
  }

  // ---- TO FIRESTORE ----
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
      'active': active,
      'isCustom': isCustom,
    };
  }

  // ---- Para categoría personalizada ----
  static CategoryModel custom(String value) {
    return CategoryModel(
      categoryId: "custom-${value.toLowerCase().replaceAll(' ', '-')}",
      name: value,
      icon: "edit",
      color: "#555555",
      order: 999,
      active: true,
      isCustom: true,
    );
  }

  // ---- Helper methods ----
  bool get isFallback => categoryId.startsWith('fallback-');

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF1976D2); // Color por defecto
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;

  @override
  String toString() {
    return 'CategoryModel(categoryId: $categoryId, name: $name, active: $active)';
  }
}
