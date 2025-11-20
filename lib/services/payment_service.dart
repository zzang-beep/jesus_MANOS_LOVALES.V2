import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _paymentsCollection =
      FirebaseFirestore.instance.collection('payments');

  // Crear pago nuevo
  Future<String> createPayment(PaymentModel payment) async {
    try {
      // Conviertelo a mapa
      final data = payment.toMap();

      // Si el método es 'alias' (transferencia) y no viene alias, intentamos buscarlo en users/{providerId}
      if ((data['paymentMethod'] == 'alias' ||
              data['paymentMethod'] == 'transfer') &&
          (data['alias'] == null || (data['alias'] as String).isEmpty)) {
        // Buscar datos del proveedor en users collection
        final userDoc =
            await _firestore.collection('users').doc(payment.providerId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final providerAlias = userData['alias'] as String?;
          final providerCbu = userData['cbu'] as String?;
          if (providerAlias != null && providerAlias.isNotEmpty) {
            data['alias'] = providerAlias;
          }
          if (providerCbu != null && providerCbu.isNotEmpty) {
            data['cbu'] = providerCbu;
          }
        }
      }

      // Si es transferencia/alias y aun no tenemos alias -> error (forzamos al UI a pedirlo)
      if ((data['paymentMethod'] == 'alias' ||
              data['paymentMethod'] == 'transfer') &&
          (data['alias'] == null || (data['alias'] as String).isEmpty)) {
        throw 'Falta alias para transferencia. El proveedor no tiene alias guardado.';
      }

      // Asegurar createdAt con serverTimestamp
      data['createdAt'] = FieldValue.serverTimestamp();

      // Guardar en Firestore
      final docRef = await _paymentsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw 'Error al crear pago: $e';
    }
  }

  // Obtener pago por ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (!doc.exists) return null;
      return PaymentModel.fromFirestore(doc);
    } catch (e) {
      throw 'Error al obtener pago: $e';
    }
  }

  // Stream de un pago
  Stream<PaymentModel?> paymentStream(String paymentId) {
    return _paymentsCollection.doc(paymentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PaymentModel.fromFirestore(doc);
    });
  }

  // Obtener pago activo por chat
  Future<PaymentModel?> getPaymentByChatId(String chatId) async {
    try {
      final query = await _paymentsCollection
          .where('chatId', isEqualTo: chatId)
          .where('status', whereIn: ['pending', 'confirmed_by_provider'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return PaymentModel.fromFirestore(query.docs.first);
    } catch (e) {
      throw 'Error al obtener pago por chat: $e';
    }
  }

  // Stream de pago por chat
  Stream<PaymentModel?> paymentStreamByChatId(String chatId) {
    return _paymentsCollection
        .where('chatId', isEqualTo: chatId)
        .where('status', whereIn: ['pending', 'confirmed_by_provider'])
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return PaymentModel.fromFirestore(snapshot.docs.first);
        });
  }

  // ============================
  // 🔥 NUEVO: Confirmación P2P
  // ============================

  // Proveedor confirma
  Future<void> confirmPaymentByProvider(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'providerConfirmed': true,
        'confirmedAt': Timestamp.now(),
      });

      await tryCompletePayment(paymentId);
    } catch (e) {
      throw 'Error confirmando proveedor: $e';
    }
  }

  // Cliente confirma
  Future<void> confirmPaymentByClient(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'clientConfirmed': true,
      });

      await tryCompletePayment(paymentId);
    } catch (e) {
      throw 'Error confirmando cliente: $e';
    }
  }

  // Si ambos confirmaron → complete
  Future<void> tryCompletePayment(String paymentId) async {
    final doc = await _paymentsCollection.doc(paymentId).get();
    final data = doc.data() as Map<String, dynamic>;

    final clientOk = data['clientConfirmed'] == true;
    final providerOk = data['providerConfirmed'] == true;

    if (clientOk && providerOk) {
      await _paymentsCollection.doc(paymentId).update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
    }
  }

  // Marcar advertencia
  Future<void> markWarningShown(String paymentId) async {
    await _paymentsCollection.doc(paymentId).update({
      'warningShownAt': Timestamp.now(),
    });
  }

  // Cancelar pago
  Future<void> cancelPayment(String paymentId) async {
    await _paymentsCollection.doc(paymentId).update({
      'status': 'failed',
    });
  }

  // Obtener pagos pendientes del proveedor
  Future<List<PaymentModel>> getPendingPaymentsByProvider(
      String providerId) async {
    final query = await _paymentsCollection
        .where('providerId', isEqualTo: providerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
  }

  // Obtener pagos confirmados por proveedor para notificar al cliente
  Future<List<PaymentModel>> getConfirmedPaymentsByClient(
      String clientId) async {
    final query = await _paymentsCollection
        .where('clientId', isEqualTo: clientId)
        .where('providerConfirmed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
  }
}
