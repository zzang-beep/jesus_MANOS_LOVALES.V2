import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String categoryId;
  final String name;
  final String icon;
  final String color;
  final int order;
  final bool active;

  CategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    this.color = '#1976D2',
    this.order = 0,
    this.active = true,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryModel(
      categoryId: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'build',
      color: data['color'] ?? '#1976D2',
      order: data['order'] ?? 0,
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
      'active': active,
    };
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF1976D2);
    }
  }

  IconData get iconData {
    final iconMap = {
      'plumbing': Icons.plumbing,
      'electrical_services': Icons.electrical_services,
      'yard': Icons.yard,
      'cleaning_services': Icons.cleaning_services,
      'computer': Icons.computer,
      'school': Icons.school,
      'format_paint': Icons.format_paint,
      'carpenter': Icons.carpenter,
      'local_fire_department': Icons.local_fire_department,
      'more_horiz': Icons.more_horiz,
      'build': Icons.build,
    };

    return iconMap[icon] ?? Icons.build;
  }
}
