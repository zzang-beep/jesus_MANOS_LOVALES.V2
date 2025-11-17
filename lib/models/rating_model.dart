import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String? ratingId;
  final String serviceId;
  final String providerId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final int score; // 1-5
  final String comment;
  final DateTime createdAt;

  RatingModel({
    this.ratingId,
    required this.serviceId,
    required this.providerId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl = '',
    required this.score,
    this.comment = '',
    required this.createdAt,
  });

  // Validar score
  bool get isValidScore => score >= 1 && score <= 5;

  // Convertir desde Firestore
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RatingModel(
      ratingId: doc.id,
      serviceId: data['serviceId'] ?? '',
      providerId: data['providerId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      score: data['score'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'providerId': providerId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'score': score,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
