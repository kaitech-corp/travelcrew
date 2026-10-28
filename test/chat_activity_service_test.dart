import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/notifications/chat_activity_service.dart';

void main() {
  test('unread state preserves timestamp precision within one millisecond', () {
    final readAt = Timestamp(1800000000, 123000100);
    final newer = Timestamp(1800000000, 123000200);
    expect(
      ChatActivityService.hasUnreadMessage({
        'lastMessageAtTime': newer,
        'lastMessageAt': newer.millisecondsSinceEpoch,
        'readAt': readAt,
      }),
      isTrue,
    );
    expect(
      ChatActivityService.hasUnreadMessage({
        'lastMessageAtTime': newer,
        'readAt': newer,
      }),
      isFalse,
    );
  });

  test('unread state still recognizes existing millisecond activity', () {
    final readAt = Timestamp(1800000000, 123000000);
    expect(
      ChatActivityService.hasUnreadMessage({
        'lastMessageAt': 1800000000124,
        'readAt': readAt,
      }),
      isTrue,
    );
    expect(ChatActivityService.hasUnreadMessage(null), isFalse);
  });
}
