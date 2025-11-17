import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String? serviceId;
  final String title;
  final String category;
  final String description;
  final double? price;
  final String priceText;
  final String photoUrl;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String providerPhotoUrl;
  final String locationText;
  final double ratingAvg;
  final int ratingCount;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    this.serviceId,
    required this.title,
    required this.category,
    required this.description,
    this.price,
    this.priceText = 'A convenir',
    this.photoUrl = '',
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    this.providerPhotoUrl = '',
    required this.locationText,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ServiceModel(
      serviceId: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble(),
      priceText: data['priceText'] ?? 'A convenir',
      photoUrl: data['photoUrl'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      providerPhone: data['providerPhone'] ?? '',
      providerPhotoUrl: data['providerPhotoUrl'] ?? '',
      locationText: data['locationText'] ?? '',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'priceText': priceText,
      'photoUrl': photoUrl,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerPhotoUrl': providerPhotoUrl,
      'locationText': locationText,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ServiceModel copyWith({
    String? title,
    String? category,
    String? description,
    double? price,
    String? priceText,
    String? photoUrl,
    String? locationText,
    double? ratingAvg,
    int? ratingCount,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      serviceId: serviceId,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      priceText: priceText ?? this.priceText,
      photoUrl: photoUrl ?? this.photoUrl,
      providerId: providerId,
      providerName: providerName,
      providerPhone: providerPhone,
      providerPhotoUrl: providerPhotoUrl,
      locationText: locationText ?? this.locationText,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice {
    if (price == null) return priceText;
    return '\$${price!.toStringAsFixed(0)}';
  }

  bool get hasPhoto => photoUrl.isNotEmpty;
}
