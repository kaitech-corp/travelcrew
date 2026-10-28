import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PendingChatMessage {
  PendingChatMessage({
    required this.ownerId,
    required this.roomId,
    required this.messageId,
    required this.text,
    required this.createdAtMillis,
  }) {
    final idPattern = RegExp(r'^[A-Za-z0-9_-]{1,128}$');
    if (!idPattern.hasMatch(ownerId) ||
        !idPattern.hasMatch(roomId) ||
        !idPattern.hasMatch(messageId) ||
        text.trim().isEmpty ||
        text.length > 4000 ||
        createdAtMillis <= 0) {
      throw const FormatException('Invalid pending chat message.');
    }
  }

  final String ownerId;
  final String roomId;
  final String messageId;
  final String text;
  final int createdAtMillis;

  Map<String, Object> toJson() => {
    'id': messageId,
    'text': text,
    'createdAtMillis': createdAtMillis,
  };
}

class PendingChatMessageStore {
  PendingChatMessageStore({
    Future<String?> Function(String key)? read,
    Future<void> Function(String key, String value)? write,
    Future<void> Function(String key)? delete,
  }) : _read = read ?? ((key) => const FlutterSecureStorage().read(key: key)),
       _write =
           write ??
           ((key, value) =>
               const FlutterSecureStorage().write(key: key, value: value)),
       _delete =
           delete ?? ((key) => const FlutterSecureStorage().delete(key: key));

  final Future<String?> Function(String) _read;
  final Future<void> Function(String, String) _write;
  final Future<void> Function(String) _delete;
  Future<void> _tail = Future.value();

  String _key(String ownerId, String roomId) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(ownerId) ||
        !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(roomId)) {
      throw const FormatException('Invalid chat scope.');
    }
    final scope = base64Url.encode(utf8.encode(jsonEncode([ownerId, roomId])));
    return 'pendingChatMessages.v1.$scope';
  }

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    return result;
  }

  Future<List<PendingChatMessage>> load(String ownerId, String roomId) =>
      _serialized(() => _load(ownerId, roomId));

  Future<List<PendingChatMessage>> _load(String ownerId, String roomId) async {
    final source = await _read(_key(ownerId, roomId));
    if (source == null) return [];
    if (source.length > 100000) {
      throw const FormatException('Pending chat queue is too large.');
    }
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['version'] != 1 ||
        decoded['ownerId'] != ownerId ||
        decoded['roomId'] != roomId ||
        decoded['messages'] is! List) {
      throw const FormatException(
        'Pending chat queue belongs to another account or trip.',
      );
    }
    final raw = decoded['messages'] as List;
    if (raw.length > 20) {
      throw const FormatException('Pending chat queue is too large.');
    }
    final messages = <PendingChatMessage>[];
    final ids = <String>{};
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid pending chat message.');
      }
      final message = PendingChatMessage(
        ownerId: ownerId,
        roomId: roomId,
        messageId: entry['id'] as String,
        text: entry['text'] as String,
        createdAtMillis: entry['createdAtMillis'] as int,
      );
      if (!ids.add(message.messageId)) {
        throw const FormatException('Duplicate pending chat message.');
      }
      messages.add(message);
    }
    return messages;
  }

  Future<void> enqueue(PendingChatMessage message) => _serialized(() async {
    final messages = await _load(message.ownerId, message.roomId);
    final existing = messages.where(
      (entry) => entry.messageId == message.messageId,
    );
    if (existing.isNotEmpty) {
      if (existing.single.text != message.text) {
        throw const FormatException('Pending chat message ID conflict.');
      }
      return;
    }
    if (messages.length >= 20) {
      throw const FormatException(
        'Retry pending chat messages before sending more.',
      );
    }
    messages.add(message);
    await _write(
      _key(message.ownerId, message.roomId),
      jsonEncode({
        'version': 1,
        'ownerId': message.ownerId,
        'roomId': message.roomId,
        'messages': messages.map((entry) => entry.toJson()).toList(),
      }),
    );
  });

  Future<void> remove(String ownerId, String roomId, String messageId) =>
      _serialized(() async {
        final messages = await _load(ownerId, roomId);
        messages.removeWhere((entry) => entry.messageId == messageId);
        final key = _key(ownerId, roomId);
        if (messages.isEmpty) {
          await _delete(key);
        } else {
          await _write(
            key,
            jsonEncode({
              'version': 1,
              'ownerId': ownerId,
              'roomId': roomId,
              'messages': messages.map((entry) => entry.toJson()).toList(),
            }),
          );
        }
      });
}
