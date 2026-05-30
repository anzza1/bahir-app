import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _kDid='bahir-did', _kPub='bahir-pub', _kContacts='bahir-contacts', _kMessages='bahir-messages';

  static Future<Identity?> loadIdentity() async {
    final p = await SharedPreferences.getInstance();
    final did = p.getString(_kDid), pub = p.getString(_kPub);
    if (did == null || pub == null) return null;
    return Identity(did: did, pubKey: pub);
  }
  static Future<void> saveIdentity(Identity id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kDid, id.did); await p.setString(_kPub, id.pubKey);
  }
  static Future<void> clearIdentity() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kDid); await p.remove(_kPub);
  }
  static Future<List<Contact>> loadContacts() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kContacts);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Contact.fromJson(e)).toList();
  }
  static Future<void> saveContacts(List<Contact> c) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kContacts, jsonEncode(c.map((x) => x.toJson()).toList()));
  }
  static Future<Map<String, List<Message>>> loadMessages() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kMessages);
    if (raw == null) return {};
    final Map<String, dynamic> d = jsonDecode(raw);
    return d.map((k, v) => MapEntry(k, (v as List).map((m) => Message.fromJson(m)).toList()));
  }
  static Future<void> saveMessages(Map<String, List<Message>> messages) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMessages, jsonEncode(messages.map((k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()))));
  }
}
