import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/pending_chat_message_store.dart';

void main() {
  final values = <String, String>{};
  late PendingChatMessageStore store;
  setUp(() {
    values.clear();
    store = PendingChatMessageStore(
      read: (key) async => values[key],
      write: (key, value) async {
        values[key] = value;
      },
      delete: (key) async {
        values.remove(key);
      },
    );
  });

  PendingChatMessage message(String id, {String text = 'Hello'}) =>
      PendingChatMessage(
        ownerId: 'alice',
        roomId: 'trip',
        messageId: id,
        text: text,
        createdAtMillis: 1800000000000,
      );

  test(
    'checkpoint keeps stable IDs across reloads and separates accounts',
    () async {
      await store.enqueue(message('first'));
      await store.enqueue(message('second', text: 'Next'));
      final reloaded = PendingChatMessageStore(
        read: (key) async => values[key],
        write: (key, value) async {
          values[key] = value;
        },
        delete: (key) async {
          values.remove(key);
        },
      );
      expect(
        (await reloaded.load('alice', 'trip')).map((entry) => entry.messageId),
        ['first', 'second'],
      );
      expect(await reloaded.load('bob', 'trip'), isEmpty);
      await reloaded.remove('alice', 'trip', 'first');
      expect((await reloaded.load('alice', 'trip')).single.messageId, 'second');
      await reloaded.remove('alice', 'trip', 'second');
      expect(await reloaded.load('alice', 'trip'), isEmpty);
    },
  );

  test(
    'same-ID retries are idempotent and conflicting content is rejected',
    () async {
      await Future.wait([
        store.enqueue(message('retry')),
        store.enqueue(message('retry')),
      ]);
      expect((await store.load('alice', 'trip')).length, 1);
      await expectLater(
        store.enqueue(message('retry', text: 'Different')),
        throwsFormatException,
      );
      expect((await store.load('alice', 'trip')).single.text, 'Hello');
    },
  );

  test(
    'queue bounds and invalid inputs fail without altering saved drafts',
    () async {
      for (var index = 0; index < 20; index++) {
        await store.enqueue(message('id$index'));
      }
      await expectLater(store.enqueue(message('extra')), throwsFormatException);
      expect((await store.load('alice', 'trip')).length, 20);
      expect(() => message('bad/id'), throwsFormatException);
      expect(() => message('blank', text: '  '), throwsFormatException);
    },
  );
}
