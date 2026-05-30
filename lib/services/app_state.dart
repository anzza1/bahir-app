import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'ws_service.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  Identity? identity;
  List<Contact> contacts = [];
  Map<String, List<Message>> messages = {};
  Map<String, int> unread = {};
  bool wsOnline = false;
  String? activeDid;

  final api = ApiService();
  final ws  = WsService();

  Future<bool> loadSaved() async {
    identity = await StorageService.loadIdentity();
    contacts = await StorageService.loadContacts();
    messages = await StorageService.loadMessages();
    if (identity != null) { _setupWs(); notifyListeners(); return true; }
    return false;
  }

  Future<bool> createIdentity() async {
    final id = await api.createIdentity();
    if (id == null) return false;
    identity = id;
    await StorageService.saveIdentity(id);
    _setupWs(); notifyListeners(); return true;
  }

  Future<bool> importIdentity(String json) async {
    try {
      final j = jsonDecode(json) as Map<String,dynamic>;
      if (j['did']==null || j['pub']==null) return false;
      identity = Identity.fromJson(j);
      await StorageService.saveIdentity(identity!);
      _setupWs(); notifyListeners(); return true;
    } catch(_) { return false; }
  }

  String exportIdentity() => jsonEncode({'did':identity!.did,'pub':identity!.pubKey});

  Future<void> logout() async {
    ws.disconnect();
    await StorageService.clearIdentity();
    identity=null; contacts=[]; messages={}; unread={}; wsOnline=false; activeDid=null;
    notifyListeners();
  }

  void _setupWs() {
    ws.onConnected    = () { wsOnline=true;  notifyListeners(); };
    ws.onDisconnected = () { wsOnline=false; notifyListeners(); };
    ws.onMessage      = _onMsg;
    ws.connect(identity!.did, '');
  }

  void _onMsg(Map<String,dynamic> msg) {
    if (msg['type']=='message') {
      final from=msg['from'] as String, content=msg['content'] as String;
      _addMsg(from, Message(content:content, fromMe:false, ts:DateTime.now()));
      if (activeDid != from) unread[from]=(unread[from]??0)+1;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String to, String content) async {
    final msg = Message(content:content, fromMe:true, ts:DateTime.now());
    _addMsg(to, msg);
    ws.sendMessage(to, content);
    await api.sendMessage(identity!.did, to, content);
    notifyListeners();
  }

  void _addMsg(String did, Message msg) {
    messages.putIfAbsent(did, ()=>[]);
    messages[did]!.add(msg);
    if (messages[did]!.length > 200) messages[did]!.removeAt(0);
    StorageService.saveMessages(messages);
  }

  Future<bool> addContact(String name, String did) async {
    if (contacts.any((c)=>c.did==did)) return false;
    contacts.add(Contact(name:name, did:did));
    await StorageService.saveContacts(contacts);
    notifyListeners(); return true;
  }

  List<Message> messagesFor(String did) => messages[did] ?? [];
  int unreadFor(String did) => unread[did] ?? 0;
  void clearUnread(String did) { unread[did]=0; notifyListeners(); }
  String nameOf(String did) => contacts
      .firstWhere((c)=>c.did==did, orElse:()=>Contact(name:did.length>12?did.substring(0,12):did, did:did))
      .name;
}
