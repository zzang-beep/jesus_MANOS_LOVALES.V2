import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final bool phoneVerified;
  final String verificationCode;
  final DateTime? verificationCodeExpiry;
  final String photoUrl;
  final String bio;
  final String role;
  final double ratingAvg;
  final int ratingCount;
  final DateTime createdAt;
  final bool active;
  final String direccion;
  final String zona; // ⬅️ NUEVO CAMPO

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.phoneVerified = false,
    this.verificationCode = '',
    this.verificationCodeExpiry,
    this.photoUrl = '',
    this.bio = '',
    this.role = 'client',
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    this.active = true,
    this.direccion = '',
    this.zona = '', // ⬅️ NUEVO VALOR POR DEFECTO
  });

  // ============== Helper: puede ofrecer servicios ==============
  bool get canProvideServices {
    return (role == 'provider' || role == 'both') && phoneVerified;
  }

  // ============== Helper: validar código ==============
  bool isCodeValid(String code) {
    if (verificationCode.isEmpty || verificationCodeExpiry == null) {
      return false;
    }

    return verificationCode == code &&
        DateTime.now().isBefore(verificationCodeExpiry!);
  }

  // ============== Helper: expiración del código ==============
  bool get isCodeExpired {
    if (verificationCodeExpiry == null) return true;
    return DateTime.now().isAfter(verificationCodeExpiry!);
  }

  // ================== Convertir desde Firestore ==================
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      phoneVerified: data['phoneVerified'] ?? false,
      verificationCode: data['verificationCode'] ?? '',
      verificationCodeExpiry: data['verificationCodeExpiry'] != null
          ? (data['verificationCodeExpiry'] as Timestamp).toDate()
          : null,
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      role: data['role'] ?? 'client',
      ratingAvg: (data['ratingAvg'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      active: data['active'] ?? true,
      direccion: data['direccion'] ?? '',
      zona: data['zona'] ?? '', // ⬅️ NUEVO CAMPO
    );
  }

  // ================== Convertir a Map ==================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'phoneVerified': phoneVerified,
      'verificationCode': verificationCode,
      'verificationCodeExpiry': verificationCodeExpiry != null
          ? Timestamp.fromDate(verificationCodeExpiry!)
          : null,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'active': active,
      'direccion': direccion,
      'zona': zona, // ⬅️ NUEVO CAMPO
    };
  }

  // ================== CopyWith ==================
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    bool? phoneVerified,
    String? verificationCode,
    DateTime? verificationCodeExpiry,
    String? photoUrl,
    String? bio,
    String? role,
    double? ratingAvg,
    int? ratingCount,
    DateTime? createdAt,
    bool? active,
    String? direccion,
    String? zona, // ⬅️ NUEVO CAMPO
  }) {
    return UserModel(
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      verificationCode: verificationCode ?? this.verificationCode,
      verificationCodeExpiry: verificationCodeExpiry ?? this.verificationCodeExpiry,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      direccion: direccion ?? this.direccion,
      zona: zona ?? this.zona, // ⬅️ NUEVO CAMPO
    );
  }
}