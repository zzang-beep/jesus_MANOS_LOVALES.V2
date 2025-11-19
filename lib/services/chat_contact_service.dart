import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_contact.dart';

class ChatContactService {
  static const _storageKey = 'chat_contacts';

  Future<List<ChatContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];

    return rawList
        .map((item) => ChatContact.fromMap(jsonDecode(item)))
        .toList();
  }

  Future<void> addContact(ChatContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];
    final contacts =
        rawList.map((item) => ChatContact.fromMap(jsonDecode(item))).toList();

    contacts.removeWhere((c) => c.userId == contact.userId);
    contacts.insert(0, contact);

    final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  Future<void> removeContact(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? <String>[];
    final contacts =
        rawList.map((item) => ChatContact.fromMap(jsonDecode(item))).toList();

    contacts.removeWhere((c) => c.userId == userId);

    final encoded = contacts.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
