import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/views/import_trip/assistant_connection_card.dart';

void main() {
  for (final width in [375.0, 1024.0]) {
    testWidgets('assistant connection URL can be copied at width $width', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const Scaffold(
              body: SingleChildScrollView(child: AssistantConnectionCard()),
            ),
          ),
        ),
      );
      expect(find.text('Manage connections'), findsOneWidget);
      await tester.ensureVisible(find.text('Copy connection URL'));
      await tester.tap(find.text('Copy connection URL'));
      await tester.pump();
      expect(copied, '$assistantBaseUrl/mcp');
      expect(tester.takeException(), isNull);
    });
  }
}
