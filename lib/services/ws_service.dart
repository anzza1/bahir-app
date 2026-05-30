import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants.dart';

typedef MsgCb = void Function(Map<String, dynamic> msg);
typedef VoidCb = void Function();

class WsService {
  WebSocketChannel? _ch;
  StreamSubscription? _sub;
  MsgCb? onMessage;
  VoidCb? onConnected, onDisconnected;
  String _did='', _token='';
  bool _active=false;
  Timer? _timer;

  void connect(String did, String token) {
    _did=did; _token=token; _active=true; _doConnect();
  }

  void _doConnect() {
    try {
      _ch = WebSocketChannel.connect(Uri.parse(kWsBase));
      _sub = _ch!.stream.listen((data) {
        try {
          final msg = jsonDecode(data as String) as Map<String,dynamic>;
          if (msg['type']=='authed') onConnected?.call();
          onMessage?.call(msg);
        } catch(_) {}
      }, onDone: _onDone, onError: (_) => _onDone());
      send({'type':'auth','did':_did,'token':_token});
    } catch(_) { _onDone(); }
  }

  void _onDone() {
    onDisconnected?.call();
    if (!_active) return;
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), _doConnect);
  }

  void send(Map<String,dynamic> data) {
    try { _ch?.sink.add(jsonEncode(data)); } catch(_) {}
  }

  void sendMessage(String to, String content) =>
      send({'type':'message','to':to,'content':content});

  void disconnect() {
    _active=false; _timer?.cancel();
    _sub?.cancel(); _ch?.sink.close(); _ch=null;
  }
}
