class Identity {
  final String did, pubKey;
  const Identity({required this.did, required this.pubKey});
  factory Identity.fromJson(Map<String, dynamic> j) =>
      Identity(did: j['did'] ?? '', pubKey: j['public_key'] ?? j['pub'] ?? '');
  Map<String, dynamic> toJson() => {'did': did, 'pub': pubKey};
}

class Contact {
  final String name, did;
  const Contact({required this.name, required this.did});
  factory Contact.fromJson(Map<String, dynamic> j) =>
      Contact(name: j['name'] ?? '', did: j['did'] ?? '');
  Map<String, dynamic> toJson() => {'name': name, 'did': did};
}

class Message {
  final String content;
  final bool fromMe;
  final DateTime ts;
  const Message({required this.content, required this.fromMe, required this.ts});
  factory Message.fromJson(Map<String, dynamic> j) => Message(
        content: j['content'] ?? '', fromMe: j['fromMe'] ?? false,
        ts: DateTime.fromMillisecondsSinceEpoch(j['ts'] ?? 0));
  Map<String, dynamic> toJson() =>
      {'content': content, 'fromMe': fromMe, 'ts': ts.millisecondsSinceEpoch};
}
