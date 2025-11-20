// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'content_validation_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear o obtener chat existente
  Future<String> getOrCreateChat(String otherUserId, String otherUserName,
      {String? otherUserPhotoUrl, String? otherUserZone}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'Usuario no autenticado';

    final users = [currentUser.uid, otherUserId]..sort();
    final chatId = 'chat_${users[0]}_${users[1]}';

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        await _firestore.collection('chats').doc(chatId).set({
          'chatId': chatId,
          'participants': {
            currentUser.uid: true,
            otherUserId: true,
          },
          'participantInfo': {
            currentUser.uid: {
              'name': currentUser.displayName ?? 'Usuario',
              'photoUrl': currentUser.photoURL ?? '',
              'zone': '',
            },
            otherUserId: {
              'name': otherUserName,
              'photoUrl': otherUserPhotoUrl ?? '',
              'zone': otherUserZone ?? '',
            },
          },
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'unreadCount': {
            currentUser.uid: 0,
            otherUserId: 0,
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Chat creado: $chatId');
      } else {
        print('✅ Chat existente: $chatId');
      }

      return chatId;
    } catch (e) {
      print('❌ Error al crear/obtener chat: $e');
      throw 'Error al crear chat: $e';
    }
  }

  // Enviar mensaje con moderación
  Future<void> sendMessage(String chatId, String text,
      {bool isSystem = false}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'Usuario no autenticado';

    // Validar contenido del mensaje
    if (!isSystem) {
      final validation =
          await ContentValidationService.validateChatMessage(text);
      if (!validation.isValid) {
        throw validation.issues.first.message;
      }
    }

    final messageId =
        'msg_${DateTime.now().millisecondsSinceEpoch}_${currentUser.uid}';

    final messageData = {
      'messageId': messageId,
      'senderId': currentUser.uid,
      'senderName': currentUser.displayName ?? 'Usuario',
      'text': text,
      'type': isSystem ? 'system' : 'text',
      'readBy': {
        currentUser.uid: true,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp':
          FieldValue.serverTimestamp(), // Usar FieldValue en lugar de DateTime
      'isSystemMessage': isSystem,
    };

    try {
      // Guardar mensaje en la subcolección
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(messageData);

      // Actualizar último mensaje en el chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageSender': currentUser.uid,
      });

      // Incrementar contador de no leídos para otros participantes
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final participants =
            chatData['participants'] as Map<String, dynamic>? ?? {};

        final batch = _firestore.batch();
        for (final participantId in participants.keys) {
          if (participantId != currentUser.uid) {
            batch.update(_firestore.collection('chats').doc(chatId), {
              'unreadCount.$participantId': FieldValue.increment(1),
            });
          }
        }
        if (participants.keys.length > 1) {
          await batch.commit();
        }
      }

      print('✅ Mensaje guardado correctamente: $messageId');
    } catch (e) {
      print('❌ Error al guardar mensaje: $e');
      throw 'Error al enviar mensaje: $e';
    }
  }

  // Obtener stream de mensajes
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
      print('Error en stream de mensajes: $error');
    });
  }

  // Obtener lista de chats del usuario
  Stream<QuerySnapshot> getUserChatsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'Usuario no autenticado';

    return _firestore
        .collection('chats')
        .where('participants.${currentUser.uid}', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Resetear contador de no leídos
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${currentUser.uid}': 0,
    });

    // Marcar mensajes como leídos
    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('readBy.${currentUser.uid}', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {
        'readBy.${currentUser.uid}': true,
      });
    }

    if (messagesSnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  // Enviar mensaje del sistema (para pagos)
  Future<void> sendSystemMessage(String chatId, String text,
      {bool isPaymentRequest = false}) async {
    final systemMessageData = {
      'messageId': 'sys_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': 'system',
      'senderName': 'Sistema',
      'text': text,
      'type': isPaymentRequest ? 'payment' : 'system',
      'readBy': <String, bool>{}, // ✅ Map vacío explícito
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': DateTime.now(),
      'isSystemMessage': true,
      'isPaymentRequest': isPaymentRequest,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(systemMessageData['messageId'] as String) // ✅ Conversión explícita
        .set(systemMessageData);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSender': 'system',
    });
  }

  // Método auxiliar para obtener información del chat de forma segura
  Future<Map<String, dynamic>?> getChatInfo(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final data = chatDoc.data();
        // Convertir todos los campos a tipos seguros
        return {
          'chatId': data?['chatId']?.toString() ?? chatId,
          'lastMessage': data?['lastMessage']?.toString() ?? '',
          'lastMessageAt': data?['lastMessageAt'],
          'participants': data?['participants'] as Map<String, dynamic>? ?? {},
          'participantInfo':
              data?['participantInfo'] as Map<String, dynamic>? ?? {},
          'unreadCount': data?['unreadCount'] as Map<String, dynamic>? ?? {},
        };
      }
      return null;
    } catch (e) {
      print('Error getting chat info: $e');
      return null;
    }
  }

  // Método para verificar si un chat existe
  Future<bool> chatExists(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      return chatDoc.exists;
    } catch (e) {
      print('Error checking if chat exists: $e');
      return false;
    }
  }

  // Método para eliminar un chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Primero eliminar todos los mensajes
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Luego eliminar el chat
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
    } catch (e) {
      print('Error deleting chat: $e');
      throw 'No se pudo eliminar el chat';
    }
  }
}
