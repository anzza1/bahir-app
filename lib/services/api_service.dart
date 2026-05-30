import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/models.dart';

class ApiService {
  String _token = '';
  void setToken(String t) => _token = t;
  Map<String, String> get _h => {'Content-Type': 'application/json', 'X-API-Token': _token};

  Future<Identity?> createIdentity() async {
    try {
      final r = await http.post(Uri.parse('$kApiBase/identity/new'), headers: _h).timeout(kTimeout);
      final j = jsonDecode(r.body);
      if (j['ok'] == true) return Identity.fromJson(j);
    } catch (_) {}
    return null;
  }

  Future<bool> sendMessage(String from, String to, String content) async {
    try {
      final r = await http.post(Uri.parse('$kApiBase/messages/send'),
        headers: _h, body: jsonEncode({'from': from, 'to': to, 'content': content})).timeout(kTimeout);
      return jsonDecode(r.body)['ok'] == true;
    } catch (_) { return false; }
  }

  Future<bool> ping() async {
    try {
      final r = await http.get(Uri.parse('$kApiBase/status'), headers: _h).timeout(kTimeout);
      return r.statusCode == 200;
    } catch (_) { return false; }
  }
}
