import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_contact.dart';

class ChatContactService {
  static const _storageKey = 'chat_contacts';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ChatContact>> loadContacts() async {
    try {
      // Primero intentar cargar desde Firestore
      final contacts = await _loadFirestoreContacts();
      if (contacts.isNotEmpty) {
        await _saveContactsToLocal(contacts);
        return contacts;
      }

      // Fallback a local
      return await _loadLocalContacts();
    } catch (e) {
      print('Error loading contacts: $e');
      return await _loadLocalContacts();
    }
  }

  Future<List<ChatContact>> _loadFirestoreContacts() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('participants.${currentUser.uid}', isEqualTo: true)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final contacts = <ChatContact>[];

      for (final chatDoc in chatsSnapshot.docs) {
        final chatData = chatDoc.data();
        final participants =
            chatData['participantInfo'] as Map<String, dynamic>? ?? {};

        // Encontrar el otro usuario (no el actual)
        String? otherUserId;
        Map<String, dynamic>? otherUserInfo;

        for (final userId in participants.keys) {
          if (userId != currentUser.uid) {
            otherUserId = userId;
            otherUserInfo = participants[userId] as Map<String, dynamic>?;
            break;
          }
        }

        if (otherUserId != null && otherUserInfo != null) {
          // Convertir explícitamente los valores a String
          final name = otherUserInfo['name']?.toString() ?? 'Usuario';
          final photoUrl = otherUserInfo['photoUrl']?.toString() ?? '';
          final zone = otherUserInfo['zone']?.toString() ?? '';
          final lastMessage = chatData['lastMessage']?.toString() ?? '';

          final contact = ChatContact(
            userId: otherUserId,
            name: name,
            photoUrl: photoUrl,
            bio: lastMessage,
            zone: zone,
          );
          contacts.add(contact);
        }
      }

      return contacts;
    } catch (e) {
      print('Error loading firestore contacts: $e');
      return [];
    }
  }

  Future<List<ChatContact>> _loadLocalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];
    return rawList
        .map((item) {
          try {
            final map = jsonDecode(item) as Map<String, dynamic>;
            return ChatContact.fromMap(map);
          } catch (e) {
            print('Error parsing contact: $e');
            return ChatContact(
              userId: 'error',
              name: 'Error',
              photoUrl: '',
              bio: '',
              zone: '',
            );
          }
        })
        .where((contact) => contact.userId != 'error')
        .toList();
  }

  Future<void> _saveContactsToLocal(List<ChatContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> addContact(ChatContact contact) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Primero crear/actualizar en Firestore
      final users = [currentUser.uid, contact.userId]..sort();
      final chatId = 'chat_${users[0]}_${users[1]}';

      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'participants': {
          currentUser.uid: true,
          contact.userId: true,
        },
        'participantInfo': {
          currentUser.uid: {
            'name': currentUser.displayName ?? 'Usuario',
            'photoUrl': currentUser.photoURL ?? '',
            'zone': '',
          },
          contact.userId: {
            'name': contact.name,
            'photoUrl': contact.photoUrl,
            'zone': contact.zone,
          },
        },
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': {
          currentUser.uid: 0,
          contact.userId: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Luego guardar localmente
      final prefs = await SharedPreferences.getInstance();
      final contacts = await _loadLocalContacts();

      contacts.removeWhere((c) => c.userId == contact.userId);
      contacts.insert(0, contact);

      final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (e) {
      print('Error adding contact: $e');
      // Fallback solo local
      final prefs = await SharedPreferences.getInstance();
      final contacts = await _loadLocalContacts();

      contacts.removeWhere((c) => c.userId == contact.userId);
      contacts.insert(0, contact);

      final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_storageKey, encoded);
    }
  }

  Future<void> removeContact(String userId) async {
    final currentUser = _auth.currentUser;

    try {
      // Remover de Firestore
      if (currentUser != null) {
        final users = [currentUser.uid, userId]..sort();
        final chatId = 'chat_${users[0]}_${users[1]}';

        await _firestore.collection('chats').doc(chatId).update({
          'participants.${currentUser.uid}': false,
        });
      }
    } catch (e) {
      print('Error removing contact from firestore: $e');
    }

    // Remover localmente
    final prefs = await SharedPreferences.getInstance();
    final contacts = await _loadLocalContacts();
    contacts.removeWhere((c) => c.userId == userId);

    final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  // Método para obtener información real del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        // Convertir explícitamente todos los valores a tipos seguros
        return {
          'name': data?['name']?.toString() ?? 'Usuario',
          'email': data?['email']?.toString() ?? '',
          'phone': data?['phone']?.toString() ?? '',
          'photoUrl': data?['photoUrl']?.toString() ?? '',
          'bio': data?['bio']?.toString() ?? '',
          'zone': data?['zone']?.toString() ?? '',
          'ratingAvg': (data?['ratingAvg'] as num?)?.toDouble() ?? 0.0,
          'ratingCount': (data?['ratingCount'] as num?)?.toInt() ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Método mejorado para crear contacto desde datos de usuario
  Future<ChatContact> createContactFromUserData(
      String userId, Map<String, dynamic> userData) async {
    return ChatContact(
      userId: userId,
      name: userData['name']?.toString() ?? 'Usuario',
      photoUrl: userData['photoUrl']?.toString() ?? '',
      bio: userData['bio']?.toString() ?? '',
      zone: userData['zone']?.toString() ?? '',
    );
  }

  // Método para iniciar chat con un usuario
  Future<String> startChatWithUser(String otherUserId, String otherUserName,
      {String? otherUserPhotoUrl, String? otherUserZone}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw 'Usuario no autenticado';

    final users = [currentUser.uid, otherUserId]..sort();
    final chatId = 'chat_${users[0]}_${users[1]}';

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
    } else {
      // Si el chat existe, asegurarse de que el usuario actual esté como participante
      await _firestore.collection('chats').doc(chatId).update({
        'participants.${currentUser.uid}': true,
      });
    }

    // Agregar a contactos locales
    final contact = ChatContact(
      userId: otherUserId,
      name: otherUserName,
      photoUrl: otherUserPhotoUrl ?? '',
      bio: '',
      zone: otherUserZone ?? '',
    );

    await addContact(contact);

    return chatId;
  }
}
