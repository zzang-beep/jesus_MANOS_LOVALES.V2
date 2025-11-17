import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final bool phoneVerified; // ← NUEVO
  final String verificationCode; // ← NUEVO
  final DateTime? verificationCodeExpiry; // ← NUEVO
  final String photoUrl;
  final String bio;
  final String role;
  final double ratingAvg;
  final int ratingCount;
  final DateTime createdAt;
  final bool active;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.phoneVerified = false, // ← NUEVO
    this.verificationCode = '', // ← NUEVO
    this.verificationCodeExpiry, // ← NUEVO
    this.photoUrl = '',
    this.bio = '',
    this.role = 'client',
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    this.active = true,
  });

  // ============== NUEVO: Helper para verificar si puede ofrecer servicios ==============
  bool get canProvideServices {
    // Solo proveedores verificados pueden publicar servicios
    return (role == 'provider' || role == 'both') && phoneVerified;
  }

  // ============== NUEVO: Helper para verificar si el código es válido ==============
  bool isCodeValid(String code) {
    if (verificationCode.isEmpty || verificationCodeExpiry == null) {
      return false;
    }

    return verificationCode == code &&
        DateTime.now().isBefore(verificationCodeExpiry!);
  }

  // ============== NUEVO: Helper para verificar si el código expiró ==============
  bool get isCodeExpired {
    if (verificationCodeExpiry == null) return true;
    return DateTime.now().isAfter(verificationCodeExpiry!);
  }

  // Convertir desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      phoneVerified: data['phoneVerified'] ?? false, // ← NUEVO
      verificationCode: data['verificationCode'] ?? '', // ← NUEVO
      verificationCodeExpiry:
          data['verificationCodeExpiry'] !=
              null // ← NUEVO
          ? (data['verificationCodeExpiry'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      role: data['role'] ?? 'client',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      active: data['active'] ?? true,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'phoneVerified': phoneVerified, // ← NUEVO
      'verificationCode': verificationCode, // ← NUEVO
      'verificationCodeExpiry':
          verificationCodeExpiry !=
              null // ← NUEVO
          ? Timestamp.fromDate(verificationCodeExpiry!)
          : null,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'active': active,
    };
  }

  // CopyWith para actualizaciones
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    bool? phoneVerified, // ← NUEVO
    String? verificationCode, // ← NUEVO
    DateTime? verificationCodeExpiry, // ← NUEVO
    String? photoUrl,
    String? bio,
    String? role,
    double? ratingAvg,
    int? ratingCount,
    DateTime? createdAt,
    bool? active,
  }) {
    return UserModel(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified, // ← NUEVO
      verificationCode: verificationCode ?? this.verificationCode, // ← NUEVO
      verificationCodeExpiry:
          verificationCodeExpiry ?? this.verificationCodeExpiry, // ← NUEVO
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }
}
