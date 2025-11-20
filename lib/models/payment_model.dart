import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? paymentId;
  final String chatId;
  final String serviceId;
  final String providerId;
  final String clientId;
  final double amount;

  // Estados: pending → provider confirms → client confirms → completed
  final String status;

  final String paymentMethod;
  final String? transactionId;

  // NEW: alias / cbu (opcional, pero importantes para transferencias)
  final String? alias;
  final String? cbu;

  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? warningShownAt;

  // 🔥 Nuevos estados para confirmar pago P2P
  final bool clientConfirmed;
  final bool providerConfirmed;

  PaymentModel({
    this.paymentId,
    required this.chatId,
    required this.serviceId,
    required this.providerId,
    required this.clientId,
    required this.amount,
    this.status = 'pending',
    required this.paymentMethod,
    this.transactionId,
    this.alias,
    this.cbu,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.warningShownAt,
    this.clientConfirmed = false,
    this.providerConfirmed = false,
  });

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PaymentModel(
      paymentId: doc.id,
      chatId: data['chatId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      providerId: data['providerId'] ?? '',
      clientId: data['clientId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'alias',
      transactionId: data['transactionId'],
      alias: data['alias'] as String?,
      cbu: data['cbu'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      confirmedAt: data['confirmedAt'] != null
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      warningShownAt: data['warningShownAt'] != null
          ? (data['warningShownAt'] as Timestamp).toDate()
          : null,
      clientConfirmed: data['clientConfirmed'] ?? false,
      providerConfirmed: data['providerConfirmed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'serviceId': serviceId,
      'providerId': providerId,
      'clientId': clientId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'alias': alias,
      'cbu': cbu,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt':
          confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'warningShownAt':
          warningShownAt != null ? Timestamp.fromDate(warningShownAt!) : null,
      'clientConfirmed': clientConfirmed,
      'providerConfirmed': providerConfirmed,
    };
  }

  PaymentModel copyWith({
    String? status,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? warningShownAt,
    bool? clientConfirmed,
    bool? providerConfirmed,
    String? alias,
    String? cbu,
  }) {
    return PaymentModel(
      paymentId: paymentId,
      chatId: chatId,
      serviceId: serviceId,
      providerId: providerId,
      clientId: clientId,
      amount: amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      alias: alias ?? this.alias,
      cbu: cbu ?? this.cbu,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      warningShownAt: warningShownAt ?? this.warningShownAt,
      clientConfirmed: clientConfirmed ?? this.clientConfirmed,
      providerConfirmed: providerConfirmed ?? this.providerConfirmed,
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmedByProvider => providerConfirmed;
  bool get isConfirmedByClient => clientConfirmed;
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  Duration get timeElapsed => DateTime.now().difference(createdAt);

  bool get shouldShowWarning => timeElapsed.inMinutes >= 10 && isPending;
}
